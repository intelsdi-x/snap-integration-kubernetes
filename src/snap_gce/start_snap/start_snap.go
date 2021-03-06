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

import "os"
import "os/exec"
import "net/http"
import "sync"
import "time"
import "io/ioutil"
import "encoding/json"
import "strconv"
import "fmt"
import "bufio"

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
                plugins = append(plugins, path + "/" + p.Name())
        }
        return plugins
}

func main() {
	f, _ := os.Create("/tmp/start_snap.log")
	defer f.Close()
	w := bufio.NewWriter(f)

        pluginsDir := os.Getenv("PLUGINS_AUTOLOAD_DIR")
        pluginsToLoad := os.Getenv("PLUGINS_TO_LOAD")
        snapteld := os.Getenv("SNAPTELD_BIN")
        snaptel := os.Getenv("SNAPTEL_BIN")
        task := os.Getenv("TASK_AUTOLOAD_FILE")
        tribeSeed := os.Getenv("SNAP_SEED_IP")
        numTribeNodes := os.Getenv("SNAP_TRIBE_NODES")
        myPodIP := os.Getenv("MY_POD_IP")
	agreement := "all-nodes"

	fmt.Fprintf(w, "tribe seed IP: %s, my POD IP: %s, expcted number of Tribe members: %s\n", tribeSeed, myPodIP, numTribeNodes)

        plugins := Plugins{}
        tribeNodes := Tribe{}
        var wg sync.WaitGroup

        wg.Add(2)
        if myPodIP != tribeSeed {
	fmt.Fprintf(w, "I'm NOT a tribe seed... waiting for tribe seed.\n")
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
	         fmt.Fprintf(w, "Listing tribe members not successful - waiting for tribe seed\n")
                 time.Sleep(time.Second)
                 continue
            }
	    fmt.Fprintf(w, "Starting snapteld with tribe seed: %s\n", tribeSeed)
	    w.Flush()
            go exec.Command(snapteld, "-l", "1", "-o", "/tmp", "-t", "0", "--tribe", "--tribe-seed", tribeSeed).Run()
            wg.Wait()
	}
	fmt.Fprintf(w, "I'm a tribe seed. Discovering tribe members.\n")
        go exec.Command(snapteld, "-l", "1", "-o", "/tmp", "-t", "0", "--tribe").Run()
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
                                numNodes, _ := strconv.Atoi(numTribeNodes)
                                if len(tribeNodes.Body.Members) < numNodes {
	                                fmt.Fprintf(w, "Too few tribe members. Got: %v (%+v), Need: %v\n", len(tribeNodes.Body.Members), tribeNodes, numNodes)
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
                for true {
		        w.Flush()
	                fmt.Fprintf(w, "Loading plugins...\n")
                        resp, err := http.Get("http://localhost:8181/v1/plugins")
                        if err != nil {
	                        fmt.Fprintf(w, "Error listing plugins - is snapteld ready?\n")
                                time.Sleep(time.Second)
                                continue
                        }
                        if resp.StatusCode == 200 {
                                body, err := ioutil.ReadAll(resp.Body)
                                defer resp.Body.Close()
                                if err != nil {
	                                fmt.Fprintf(w, "Cannot parse response body for plugins list - exiting\n")
                                        return
                                }
                                json.Unmarshal(body, &plugins)
                                numPlugins, _ := strconv.Atoi(pluginsToLoad)
                                if len(plugins.Body.LoadedPlugins) < numPlugins {
	                                fmt.Fprintf(w, "Too few plugins loaded...\n")
                                        for _, p := range getPlugins(pluginsDir ) {
	                                        fmt.Fprintf(w, "Loading plugin: %+v\n", p)
                                                exec.Command(snaptel, "plugin", "load", p).Run()
                                        }
                                        time.Sleep(time.Second)
                                        continue
                                }
	                        fmt.Fprintf(w, "All plugins loaded -  starting task\n")
				w.Flush()
                                // account for plugins loaded on remote nodes
                                // TODO improve this
                                time.Sleep(3 * time.Second)
                                exec.Command(snaptel, "task", "create", "-t", task).Run()
                                return
                        }
	                fmt.Fprintf(w, "Listing plugins not successful - waiting\n")
			w.Flush()
                        continue
                }
        }()
        wg.Wait()
}
