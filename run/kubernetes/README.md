# Running Snap in Kubernetes
1. [Getting started](#1-getting-started)  
2. [Configuration of Kubernetes pod](#2-configuration-of-kubernetes-pod)  
3. [Snap in Tribe mode](#3-snap-in-tribe-mode)

### 1. Getting started
To run Snap in Kubernetes and start examples below you need to have Kubernetes cluster set up. If you do not have Kubernetes cluster you can go to [GCE section](https://github.com/intelsdi-x/snap-integration-kubernetes/run/gce/README.md) to start new Kubernetes cluster on GCE with Snap as telemetry solution.
First step is to download this repo. All of the needed files are in the `snap-integration-kubernetes` directory.
```sh
$ git clone https://github.com/intelsdi-x/snap-integration-kubernetes/
$ cd ./snap-integration-kubernetes
```

#### a) Running Snap in Kubernetes - CPU collector plugin example 
To run Snap in pod create daemonset from manifest file `snap-integration-kubernetes/run/kubernetes/snap/snap.yaml` presented below.
```sh
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: snap
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  template:
    metadata:
      name: snap
      labels:
        daemon: snapteld
    spec:
      containers:
      - name: snap
        image: intelsdi/snap4kube:0.1
        # mapping of /proc is required for CPU plugin
        volumeMounts:
          - mountPath: /proc_host
            name: proc
        ports:
        - containerPort: 8181
          hostPort: 8181
          name: snap-api
        imagePullPolicy: Always
      volumes:
        - name: proc
          hostPath:
            path: /proc
```

The manifest contains parameters `volumeMounts` and `volume`. Those fields are required for CPU collector plugin to run properly. As it is stated in the [documentation](https://github.com/intelsdi-x/snap-plugin-collector-cpu/blob/master/README.md) the plugin gathers information from the file `/proc/stat` residing in the host machine. The original host file `/proc/stat` has to be accessible inside of the container. Running this plugin inside the pod requires mapping of this file inside of the container.  This means that we have to adjust Snap daemonset manifest in order to be able to use CPU plugin inside it. This is done with the use of  `volumeMounts` and `volume` fields.

Let's create Snap daemonset:
```sh
$ kubectl create -f snap-integration-kubernetes/run/kubernetes/snap/snap.yaml
```
And verify that pods have been created:
```sh
$ kubectl get pods --namespace=kube-system
```
Log into the one of pods using the pod name returned by `kubectl get pods` command.
```sh
$ kubectl exec -ti <snap-pod-name> bash --namespace=kube-system
```
Now that you are inside the pod with running Snap daemon, you may run command to list the plugins
```sh
$ snaptel plugin list
``` 
The output should be `No plugins found. Have you loaded a plugin?` as there are no plugins loaded yet. Let's download some...
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-cpu/releases/download/6/snap-plugin-collector-cpu_linux_x86_64" -o snap-plugin-collector-cpu
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file
```
...and load them.
```sh
$ snaptel plugin load snap-plugin-collector-cpu
$ snaptel plugin load snap-plugin-publisher-file
```
Now, running the command
```sh
$ snaptel plugin list
``` 
will print information about two loaded plugins. To start the collection of metrics you can create task.
```sh
$ curl -sO https://raw.githubusercontent.com/intelsdi-x/snap-integration-kubernetes/examples/tasks/cpu-file.json
$ snaptel task create -t ./cpu-file.json
``` 
Command:
```sh
$ snaptel task list
``` 
will provide information whether the metrics collection was successfull or not. Use task watch to verify that tasks have been created correctly.
```sh
$ snaptel task watch <task-id>
```
If you want to know how to load other plugins read the section [TODO: link].

#### b) Running Snap in Kubernetes with Heapster
There is also a possibility to publish metrics gathered by Snap collector to customized Heapster (supporting Snap as data source) (https://github.com/intelsdi-x/heapster). This solution requires:
- running customized Heapster Docker image with Snap source added so that Heapster can scratch metrics directly from running Snap instances
- Snap Docker collector (https://github.com/intelsdi-x/snap-plugin-collector-docker)
- Snap Heapster publisher (https://github.com/intelsdi-x/snap-plugin-publisher-heapster)

##### Running customized Heapster with Snap source
To run the customized Heapster image you need to create Heapster service and deployment from manifest files `snap-integration-kubernetes/run/kubernetes/heapster/heapster-service.yaml` and `snap-integration-kubernetes/run/kubernetes/heapster/heapster-controller.yaml`.
```sh
$ kubectl create -f snap-integration-kubernetes/run/kubernetes/heapster/heapster-service.yaml
$ kubectl create -f snap-integration-kubernetes/run/kubernetes/heapster/heapster-controller.yaml
```

##### Snap Docker collector
Kubernetes manifest has to be adjusted to use with Snap Docker collector plugin (https://github.com/intelsdi-x/snap-plugin-collector-docker). To start Snap daemonset adjusted to use with Snap Docker collector plugin you simply run the command:
```sh
$ kubectl create -f snap-integration-kubernetes/run/kubernetes/snap/snap_docker.yaml
```
The manifest `snap-integration-kubernetes/run/kubernetes/snap/snap_docker.yaml` contains fields `volumeMounts` and `volume` that allow to map files inside of the pods. They are required because Docker collector needs access to files on the host:
- `/var/run/docker.sock`
- `/proc`
- `/usr/bin/docker`
- `/var/lib/docker`
- `/sys/fs/cgroup`

What is more, the daemonset must be created with volume security option `privileged` (http://kubernetes.io/docs/user-guide/security-context/). This is neccessary to access `/var/run/docker.sock` file.
```sh
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: snap
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  template:
    metadata:
      name: snap
      labels:
        daemon: snapteld
    spec:
      # this option is required for tribe mode
      hostNetwork: true
      containers:
      - name: snap
        image: intelsdi/snap4kube:0.1
        # mapping of dirs below is required for docker plugin
        volumeMounts:
          - mountPath: /sys/fs/cgroup
            name: cgroup
          - mountPath: /var/run/docker.sock
            name: docker-sock
          - mountPath: /var/lib/docker
            name: fs-stats
          - mountPath: /usr/local/bin/docker
            name: docker
          - mountPath: /proc_host
            name: proc
        ports:
        - containerPort: 8181
          hostPort: 8181
          name: snap-api
        - containerPort: 8777
          hostPort: 8777
          name: heapster
        imagePullPolicy: Always
        # privileged mode is required to access mounted volume
        # /var/run/docker.sock
        securityContext:
          privileged: true
      volumes:
        - name: cgroup
          hostPath:
            path: /sys/fs/cgroup
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
        - name: fs-stats
          hostPath:
            path: /var/lib/docker
        - name: docker
          hostPath:
            path: /usr/bin/docker
        - name: proc
          hostPath:
            path: /proc
```
Verify that pods have been created correctly:
```sh
$ kubectl get pods --all-namespaces -o wide
```
Now you need to log into one of the pods using the name returned by the command `kubectl get pods`:
```sh
$ kubectl exec -ti <snap-pod-name> --namespace=kube-system
```
Download and load Docker collector:
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/5/snap-plugin-collector-docker_linux_x86_64" -o snap-plugin-collector-docker
$ snaptel plugin load snap-plugin-collector-docker
```

##### Snap Heapster publisher
After you create customized Heapster deployment and Docker collector plugin you download Snap Heapster publisher plugin and load it:
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-heapster/releases/download/1/snap-plugin-publisher-heapster_linux_x86_64" -o snap-plugin-publisher-heapster
$ snaptel plugin load ./snap-plugin-publisher-heapster
```
Running:
```sh
$ snaptel plugin list
``` 
will provide information whether plugins have been loaded correctly. After that you can download an exemplary task manifest and create it:
```sh
$ curl -sO https://raw.githubusercontent.com/intelsdi-x/snap-integration-kubernetes/examples/tasks/docker-heapster.json
$ snaptel task create -t ./docker-heapster.json
``` 

##### Verification
To verify that metrics are being collected in Heapster you may check Heapster pod logs:
```
$ kubectl logs -f <heapster-pod-name> --namespace=kube-system
```

### 2. Configuration of Snap pod
Inside Kubernetes pod it is possible to load most of the Snap plugins. The list of all Snap plugins is available in plugin catalog  https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md. After you choose plugin you click the plugin name. This redirects you to the plugin repository. 

To use plugin inside the pod you need to download its binary. In order to get plugin binary URL you go to the `release` section... 
<img src="https://cloud.githubusercontent.com/assets/6523391/21221560/1c428440-c2be-11e6-9d73-6c565b88aa6e.png" width="70%">
...and copy the link for the latest plugin release.
<img src="https://cloud.githubusercontent.com/assets/6523391/21221622/69a08e6c-c2be-11e6-916f-f7179332b435.png" width="70%">

Many of the plugins require prior configuration and adjustment of Kubernetes manifest. The example of such plugin is Snap Docker collector plugin. The Docker collector allows to collect runtime metrics from Docker containers and its host machine. It gathers information about resource usage and performance characteristics. More information about docker collector can be found here: https://github.com/intelsdi-x/snap-plugin-collector-docker.

All of the plugins requirements can be found in their documentation. The documentation of the Snap Docker plugin collector can be found here: https://github.com/intelsdi-x/snap-plugin-collector-docker/blob/master/README.md. Docker plugin collector needs access to files residing in the host machine:
- `/var/run/docker.sock`
- `/proc`
- `/usr/bin/docker`
- `/var/lib/docker`
- `/sys/fs/cgroup`

This means that the original host files have to be available inside of the container. Running this plugin inside the container requires mapping of those files inside of the container. What is more, Docker collector plugin requires enviroment variable `PROCFS_MOUNT` to be set. It should point to the directory inside the container where original host directorry `/proc` is mounted. 
To run Docker collector in Kubernetes pod we need to fullfill these requirements. We have to mount directories `/var/run/docker.sock`, `/proc`, `/usr/bin/docker`, `/var/lib/docker` and `/sys/fs/cgroup` file inside of the pod and export `PROCFS_MOUNT` variable. In Kubernetes this adjustment needs to be added in the manifest file.

Mapping of the files is done with `volumeMounts` and `volume` parameters as shown below in the `snap-integration-kubernetes/run/kubernetes/snap/snap_docker.yaml`. 
```sh
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: snap
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
spec:
  template:
    metadata:
      name: snap
      labels:
        daemon: snapteld
    spec:
      # this option is required for tribe mode
      hostNetwork: true
      containers:
      - name: snap
        image: intelsdi/snap4kube:0.1
        # mapping of dirs below is required for docker plugin
        volumeMounts:
          - mountPath: /sys/fs/cgroup
            name: cgroup
          - mountPath: /var/run/docker.sock
            name: docker-sock
          - mountPath: /var/lib/docker
            name: fs-stats
          - mountPath: /usr/local/bin/docker
            name: docker
          - mountPath: /proc_host
            name: proc
        ports:
        - containerPort: 8181
          hostPort: 8181
          name: snap-api
        - containerPort: 8777
          hostPort: 8777
          name: heapster
        imagePullPolicy: Always
        # privileged mode is required to access mounted volume
        # /var/run/docker.sock
        securityContext:
          privileged: true
      volumes:
        - name: cgroup
          hostPath:
            path: /sys/fs/cgroup
        - name: docker-sock
          hostPath:
            path: /var/run/docker.sock
        - name: fs-stats
          hostPath:
            path: /var/lib/docker
        - name: docker
          hostPath:
            path: /usr/bin/docker
        - name: proc
          hostPath:
            path: /proc

```
More information about mounting of volumes can be found in Kubernetes documentation (http://kubernetes.io/docs/user-guide/volumes/). Environment variable is added with `env` parameter (http://kubernetes.io/docs/tasks/configure-pod-container/define-environment-variable-container/).  

In order to run Snap with Docker collector you have to create daemonset from `snap_docker.yaml` file.
```sh
$ kubectl create -f snap-integration-kubernetes/run/kubernetes/snap/snap_docker.yaml
```
Verify that pods have been created. 
```sh
$ kubectl get pods --namespace=kube-system
```
Log into the one of pods using the pod name returned by `kubectl get pods` command.
```sh
$ kubectl exec -ti <snap-pod-name> bash --namespace=kube-system
```
Next steps to have Docker collector plugin running are very similar to those described `Configuration of Docker container` section. Inside the container or pod we run following commands:
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/5/snap-plugin-collector-docker_linux_x86_64" -o snap-plugin-collector-docker
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file
$ snaptel plugin load snap-plugin-collector-docker
$ snaptel plugin load snap-plugin-publisher-file
$ curl -sO "curl -sO "https://raw.githubusercontent.com/intelsdi-x/snap-plugin-collector-docker/master/examples/tasks/docker-file.json"
$ snaptel task create -t ./docker-file.json
```
Command:
```sh
$ snaptel task list
``` 
will provide information whether the metrics collection was successfull or not.

This way you may download and load almost any Snap plugin inside the Kubernetes pod.

### 3. Snap in Tribe mode
Snap can be run in a tribe mode. Tribe mode causes Snap instances to form a cluster. This allows user to create agreements and add Snap instances to those agreements. When an action is taken by one Snap instance that is a member of an agreement, that action will be carried out by all other members of the agreement. When a new Snap joins an existing agreement it will retrieve plugins and tasks from the members of the agreement. As you may read in the [documentation](https://github.com/intelsdi-x/snap/blob/master/docs/TRIBE.md) tribe mode is a beta feature yet. However it has been successfully set up and tested in a configuration presented in this section.

#### a) Creating Snap tribe in Kubernetes

In order to get Snap in tribe mode up and running you simply create set of Snap pods from Kubernetes manifest:
```sh
$ kubectl create -f snap-integration-kubernetes/run/kubernetes/snap_tribe/snap_tribe.yaml
```
The command above creates [StatefulSet](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/). This kind of set allows to manage the order in which pods are created. First Snap seed is being created, and when it is ready other pods are being created and join the tribe.

Kubernetes manifest used to create Snap StatefulSet is presented below:
```sh
apiVersion: v1
kind: Service
metadata:
  labels:
    daemon: snapteld
  name: snap-seed
  namespace: kube-system
spec:
  clusterIP: None
  ports:
  - port: 6000
    protocol: TCP
    name: tribe
  - port: 8181
    name: api
  selector:
    daemon: snapteld
---
apiVersion: "apps/v1beta1"
kind: StatefulSet
metadata:
  name: snap
  namespace: kube-system
spec:
  serviceName: snap-seed
  # number of Snap tribe members
  replicas: 3
  template:
    metadata:
      labels:
        daemon: snapteld
      annotations:
        scheduler.alpha.kubernetes.io/affinity: >
          {
            "podAntiAffinity": {
              "requiredDuringSchedulingIgnoredDuringExecution": [
                {
                  "labelSelector": {
                    "matchExpressions": [
                      {
                        "key": "daemon",
                        "operator": "In",
                        "values": [
                          "snapteld"
                        ]
                      }
                    ]
                  },
                  "topologyKey": "kubernetes.io/hostname"
                }
              ]
            }
          }
    spec:
      containers:
      - name: snap
        image: intelsdi/snap4kube:tribe
        lifecycle:
          postStart:
            exec:
              command:
              - /bin/bash
              - -c
              - /tribe.sh
        readinessProbe:
          exec:
            command:
            - /bin/bash
            - -c
            - /probe.sh
        ports:
        - containerPort: 6000
          name: seed
        - containerPort: 6001
          name: tribe
        - containerPort: 8182
          name: api
        - containerPort: 8181
          name: snap-api
        env:
          - name: SEED
            value: "snap-0.snap-seed.default.svc.cluster.local"
          - name: INITIAL_MEMBER
            value: "snap-0"
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          - name: LOG_LEVEL
            value: "1"
        volumeMounts:
          - mountPath: /proc_host
            name: proc
      volumes:
        - name: proc
          hostPath:
            path: /proc
```
Using this manifest we will get tribe with 3 members. If you wish to create tribe with larger number of members set parameter `replicas` to desired number of nodes. Maximum number of Snap replicas is the number of nodes in Kubernetes cluster. Option `anti-affinity` prevents from spawning more than one Snap instance on a single node. So the maximum number of Snap instances is the number of nodes in a cluster with each Snap instance running on a separate node.

After we create StatefulSet we list Snap pods.
`$ kubectl get pods --all-namespaces -o wide`
The output should be similar to this:
```sh
NAME                               READY     STATUS    RESTARTS   AGE
snap-0                             1/1       Running   0          2h
snap-1                             1/1       Running   0          2h
snap-2                             1/1       Running   0          2h
```
After you have all Snap instances running in tribe, you may list them with command:
`$ kubectl --namespace=kube-system exec snap-0 -- snaptel member list`
The output should be similar to:
```sh
Name
snap-0
snap-1
snap-2
```
You may also check that they all are members of the agreement `all-nodes`.
`$ kubectl --namespace=kube-system exec snap-0 -- snaptel agreement list`
```sh
Name 		 Number of Members 	 plugins 	 tasks
all-nodes 	 3 			         0 		     0
```

#### b) Loading plugins in tribe
Next step is to choose one of the pods to download and load plugins for the whole tribe. 
To exec a command inside a container you do not necessarilly need to log into the container. For example, you may download plugins like this: 
```sh
$ kubectl --namespace=kube-system exec snap-0 -- curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-cpu/releases/download/6/snap-plugin-collector-cpu_linux_x86_64" -o snap-plugin-collector-cpu
$ kubectl --namespace=kube-system exec snap-0 -- curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file
```
and load them:
```sh
$ kubectl --namespace=kube-system exec snap-0 -- snaptel plugin load snap-plugin-collector-cpu
$ kubectl --namespace=kube-system exec snap-0 -- snaptel plugin load snap-plugin-publisher-file
```
We can also create task:
```sh
$ kubectl --namespace=kube-system exec snap-0 -- curl -sO "https://raw.githubusercontent.com/intelsdi-x/snap-integration-kubernetes/examples/tasks/cpu-file.json"
$ kubectl --namespace=kube-system exec snap-0 -- snaptel task create -t ./cpu-file.json
```
Now running command:
```sh
$ kubectl --namespace=kube-system exec snap-0 -- snaptel agreement list
```
will print output:
```sh
Name 		 Number of Members 	 plugins 	 tasks
all-nodes 	 3 			         2   		 1
```
To check if task runs properly you use command:
```sh
$ kubectl --namespace=kube-system exec snap-0 -- snaptel task list
```
The output shows tasks and potential errors:
```sh
ID 					 NAME 						 STATE 		 HIT 	 MISS 	 FAIL 	 CREATED 		 LAST FAILURE
20eeb0d0-f1bb-4af6-874a-45fc39697f74 	 Task-03208b37-608f-4ece-a9cd-99df3180580e 	 Running 	 191 	 0 	 0 	 2:20PM 1-23-2017 	
```
