/*
http://www.apache.org/licenses/LICENSE-2.0.txt
Copyright 2016 Intel Corporation
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package main

import (
        "bufio"
        "encoding/json"
        "fmt"
        "io/ioutil"
        "net/http"
        "os"
        "os/exec"
        "sort"
        "sync"
        "time"

        "k8s.io/client-go/1.5/kubernetes"
        "k8s.io/client-go/1.5/rest"
)

const (
        minNodeCount = 6
        timeout      = 5
        interval     = 10
)

type Plugins struct {
        Body Body `json:"body"`
}

type Body struct {
        LoadedPlugins []interface{} `json:"loaded_plugins"`
}

type Tribe struct {
        Body Members `json:"body"`
}

type Members struct {
        Members []string `json:"members"`
}

func getPlugins(path string) []string {
        var plugins []string
        files, _ := ioutil.ReadDir(path)
        for _, p := range files {
                plugins = append(plugins, path+"/"+p.Name())
        }
        return plugins
}

type Client struct {
        namespace   string
        snapService string
        client      *kubernetes.Clientset
}

func NewClient() (*Client, error) {
        c := new(Client)
        config, err := rest.InClusterConfig()
        if err != nil {
                return nil, fmt.Errorf("Cannot get cluster config: %v", err)
        }

        c.client, err = kubernetes.NewForConfig(config)
        if err != nil {
                return nil, fmt.Errorf("Cannot initialize client: %v", err)
        }

        c.namespace = os.Getenv("NAMESPACE")
        if c.namespace == "" {
                c.namespace = "kube-system"
        }

        c.snapService = os.Getenv("SNAP_SERVICE")
        if c.snapService == "" {
                c.snapService = "snap-tribe"
        }

        return c, nil

}

func GetTribeEndpoints(c *Client) ([]string, error) {

        s, err := c.client.Services(c.namespace).Get(c.snapService)
        if err != nil {
                return nil, fmt.Errorf("Cannot get svc: %s :%v", s.GetName(), err)
        }
        endpoints, err := c.client.Endpoints(c.namespace).Get(s.GetName())
        if err != nil {
                return nil, fmt.Errorf("Cannot get endpoints for %s: %v", s.GetName(), err)
        }

        //sort the results
        addresses := make([]string, 0, len(endpoints.Subsets[0].Addresses))
        for _, addr := range endpoints.Subsets[0].Addresses {
                addresses = append(addresses, addr.IP)
        }
        sort.Strings(addresses)

        return addresses, nil
}

func GetTribeNodesCount(c *Client) (int, error) {
        endpoints, err := GetTribeEndpoints(c)
        if err != nil {
                return 0, err
        }
        return len(endpoints), err
}


func GetTribeSeed(c *Client) (string, error) {

        for t := time.Now(); time.Since(t) < timeout*time.Minute; time.Sleep(interval * time.Second) {
                endpoints, err := GetTribeEndpoints(c)
                if err != nil {
                        return "", err
                }
                fmt.Printf("our endpoint list: %+v", endpoints)
                if len(endpoints) >= minNodeCount {
                       return endpoints[0], nil

                }
                fmt.Printf("Waiting for endpoints, current number:%v", len(endpoints[0]))
        }

        return "", fmt.Errorf("Timeout waiting for snap tribe endpoints")
}

func main() {
        f, _ := os.Create("/tmp/start_snap.log")
        defer f.Close()
        w := bufio.NewWriter(f)

        snapteld := os.Getenv("SNAPTELD_BIN")
        snaptel := os.Getenv("SNAPTEL_BIN")

        client, err := NewClient()
        fmt.Fprintf(w, "Client created")
        if err != nil {
                fmt.Fprintf(w, "Error creating client: %v", err)
                os.Exit(1)
        }

        tribeSeed, err := GetTribeSeed(client)
        if err != nil {
                fmt.Fprintf(w, "Error getting tribeSeed: %v", err)
                os.Exit(1)
        }

        numTribeNodes, err := GetTribeNodesCount(client)
        fmt.Fprintf(w, "Discovered %v nodes\n", numTribeNodes)
        if err != nil {
                fmt.Fprintf(w, "Cannot get endpoint size: %v", err)
        }

        if numTribeNodes < minNodeCount {
                numTribeNodes = minNodeCount
        }

        endpoints, _ := GetTribeEndpoints(client)
        fmt.Fprintf(w, "Endpoint list: %v\n", endpoints)
        myPodIP := os.Getenv("MY_POD_IP")
        agreement := "all-nodes"
        fmt.Fprintf(w, "tribe seed IP: %s, my POD IP: %s, expcted number of Tribe members: %d\n", tribeSeed, myPodIP, numTribeNodes)

        tribeNodes := Tribe{}
        var wg sync.WaitGroup

        wg.Add(2)
        if myPodIP != tribeSeed {
                fmt.Fprintf(w, "I'm NOT a tribe seed... \n")
                for true {
                        w.Flush()
                        resp, err := http.Get("http://" + tribeSeed + ":8181/v1/tribe/members")
                        if err != nil {
                                fmt.Fprintf(w, "Error listing tribe members - is seed ready?\n")
                                time.Sleep(time.Second)
                                continue
                        }
                        if resp.StatusCode == 200 {
                                _, err := ioutil.ReadAll(resp.Body)
                                defer resp.Body.Close()
                                if err != nil {
                                        fmt.Fprintf(w, "Cannot parse response body for tribe members - exiting\n")
                                        return
                                }
                                fmt.Fprintf(w, "Response body for tribe members is valid - about to start snapteld\n")
                                break
                        }
                       fmt.Fprintf(w, "Listing tribe members not successful - waiting\n")
                        time.Sleep(time.Second)
                        continue
                }
                fmt.Fprintf(w, "Starintg snapteld with tribe seed: %s\n", tribeSeed)
                w.Flush()
                go exec.Command(snapteld, "-l", "1", "-t", "0", "--tribe", "--tribe-seed", tribeSeed, "--tribe-addr", myPodIP, "--tribe-port", "6000").Run()
                wg.Wait()
        }
        fmt.Fprintf(w, "I'm a tribe seed\n")
        go exec.Command(snapteld, "-l", "1", "-t", "0", "--tribe", "--tribe-addr", myPodIP, "--tribe-port", "6000").Run()
        fmt.Fprintf(w, "Snapteld started\n")
        go func() {
                defer wg.Done()
                for true {
                        w.Flush()
                        resp, err := http.Get("http://localhost:8181/v1/tribe/members")
                        if err != nil {
                                fmt.Fprintf(w, "Error listing tribe members - is snapteld ready?\n")
                                time.Sleep(time.Second)
                                continue
                        }
                        if resp.StatusCode == 200 {
                                body, err := ioutil.ReadAll(resp.Body)
                                defer resp.Body.Close()
                                if err != nil {
                                        fmt.Fprintf(w, "Cannot parse response body for tribe members - exiting\n")
                                        return
                                }
                                json.Unmarshal(body, &tribeNodes)
                                numNodes := numTribeNodes
                                if len(tribeNodes.Body.Members) < numNodes {
                                        fmt.Fprintf(w, "Too few tribe members. Got: %v (%+v), :Need: %v\n", len(tribeNodes.Body.Members), tribeNodes, numNodes)
                                        time.Sleep(time.Second)
                                        continue
                                }
                                fmt.Fprintf(w, "Got all tribe members (%+v) - creating agreement: %s\n", tribeNodes, agreement)
                                exec.Command(snaptel, "agreement", "create", agreement).Run()
                                fmt.Fprintf(w, "Attaching all nodes to agreeement... \n")
                                for _, n := range tribeNodes.Body.Members {
                                        fmt.Fprintf(w, "Attaching node (%+v) to agreeement: %s\n", n, agreement)
                                        exec.Command(snaptel, "agreement", "join", agreement, n).Run()
                                        time.Sleep(time.Second)
                                        w.Flush()
                                }
                                break
                        }
                        fmt.Fprintf(w, "Listing tribe members not successful - waiting\n")
                        w.Flush()
                        continue
                }
        }()
        wg.Wait()
}

