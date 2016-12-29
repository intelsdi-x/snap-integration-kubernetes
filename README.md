# Running Snap in various environments
1. [Running Snap](1#-running-snap) 
2. [Getting started](#2-getting-started)  
3. [Customization and Configuration](#3-customization-and-configuration)

### 1. Running Snap
Snap can be deployed to collect metrics in various environments including Docker containers and Kubernetes. It can be run in a Docker container to gather metrics i.e. from host and other containers. Deployment of Snap in Kubernetes cluster gives a possibility to monitor pods in the cluster.
In this repo you will find information on how to run Snap in those environments.

### 2. Getting started
First step is to download Snap repo. All of the needed files are in the `snap/integration` directory.
```sh
$ git clone https://github.com/intelsdi-x/snap-integration-kubernetes/
$ cd ./snap-integration-kubernetes
```

To learn about running Snap in a Docker container and run an example you should go to https://github.com/intelsdi-x/snap-integration-kubernetes/run/docker/README.md.
To learn about running Snap in Kubernetes pod and run an example you should go to https://github.com/intelsdi-x/snap-integration-kubernetes/run/kubernetes/README.md.
You may also find an example of running Snap with Kubernetes on Google Compute Engine here https://github.com/intelsdi-x/snap-integration-kubernetes/run/gce/README.md.

### 3. Customization and configuration
Inside Docker container it is possible to load most of the Snap plugins. The list of all Snap plugins is available in plugin catalog  https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md. After you choose plugin you click the plugin name. This redirects you to the plugin repository. 

To use plugin inside the container you need to download its binary. In order to get plugin binary URL you go to the `release` section... 

<img src="https://cloud.githubusercontent.com/assets/6523391/21221560/1c428440-c2be-11e6-9d73-6c565b88aa6e.png" width="70%">

...and copy the link for the latest plugin release.

<img src="https://cloud.githubusercontent.com/assets/6523391/21221622/69a08e6c-c2be-11e6-916f-f7179332b435.png" width="70%">


Many of the plugins require prior configuration and adjustment of container or Kubernetes manifest. The example of such plugin is Snap Docker collector plugin. The Docker collector allows to collect runtime metrics from Docker containers and its host machine. It gathers information about resource usage and performance characteristics. More information about docker collector can be found here: https://github.com/intelsdi-x/snap-plugin-collector-docker.

All of the plugins requirements can be found in their documentation. The documentation of the Snap Docker plugin collector can be found here: https://github.com/intelsdi-x/snap-plugin-collector-docker/blob/master/README.md. Docker plugin collector needs access to files residing in the host machine:
- `/var/run/docker.sock`
- `/proc`
- `/usr/bin/docker`
- `/var/lib/docker`
- `/sys/fs/cgroup`

This means that the original host files have to be available inside of the container. Running this plugin inside the container requires mapping of those files inside of the container. What is more, Docker collector plugin requires enviroment variable `PROCFS_MOUNT` to be set. It should point to the directory inside the container where original host directorry `/proc` is mounted. This has to be done in both cases: Docker container and Kubernetes pod.

##### Reconfiguration

The default Snap images are using [autoload feature](https://github.com/intelsdi-x/snap/blob/master/docs/SNAPTELD_CONFIGURATION.md#restarting-snapteld-to-pick-up-configuration-changes) to simplify re-configuration of running Snap instance. The default autoload directory is `/opt/snap/autoload`, and can be chaged in `snapteld.conf` file - please refer to Snap [configuration documentation](https://github.com/intelsdi-x/snap/blob/master/docs/SNAPTELD_CONFIGURATION.md) for details. It is recommended to store plugins and tasks in autoload directory, so that plugins are automatically loaded, and tasks are automatically started, after snapteld restart.

To change configuration of running Snap follow this steps (inside Snap container).
- edit config file `/etc/snap/snapteld.conf`
- restart snapteld:
```bash
$ kill -HUP `pidof snapteld`
```

#### a) Configuration of Docker container
In a Docker container mapping of the files is done with the addition of `-v` flag when running the container. 
```sh
$ docker run -d --name snap -v <path-to-file-on-host>:<path-to-file-in-container> intelsdi/snap4kube:0.1
```
The enviroment variable `PROCFS_MOUNT` must also be set. In Docker this is done with the use of `-e` flag when running the container.
```sh
$ docker run -d --name snap -v <path-to-file-on-host>:<path-to-file-in-container> -e PROCFS_MOUNT=<path-to-file-in-container> intelsdi/snap4kube:0.1
```
So, to run Snap with Docker collector plugin gathering metrics from host you need to use command as below.
```sh
$ docker run -d --name snap -v /proc/host:/proc_host -e PROCFS_MOUNT=/proc_host intelsdi/snap4kube:0.1
```
To verify that Snap container has started correctly and load Docker collector plugin we need to log into the Snap container. Getting into the container is quite simple:
```sh
$ docker exec -ti snap bash
```
Now that you are inside the container with running Snap daemon, you may download and load Docker collector plugin using plugin binary URL from `release` section in plugin's repository.
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/5/snap-plugin-collector-docker_linux_x86_64" -o snap-plugin-collector-docker
$ snaptel plugin load snap-plugin-collector-docker
```
Load file publisher:
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file
$ snaptel plugin load snap-plugin-publisher-file
```
Running command:
```sh
$ snaptel plugin list
```
will print information about the two loaded plugins. To start the collection of metrics you can create task.
```sh
$ curl -sO https://raw.githubusercontent.com/intelsdi-x/snap-plugin-collector-docker/master/examples/docker-file.json
$ snaptel task create -t ./docker-file.json
``` 
Command:
```sh
$ snaptel task list
``` 
will provide information whether the metrics collection was successfull or not.

This way you may download and load almost any Snap plugin inside the Docker container.

#### b) Configuration of Kubernetes pod
To run Docker collector in Kubernetes pod we need to fullfill the same requirements. We have to mount directories `/var/run/docker.sock`, `/proc`, `/usr/bin/docker`, `/var/lib/docker` and `/sys/fs/cgroup` file inside of the pod and export `PROCFS_MOUNT` variable. In Kubernetes this adjustment needs to be added in the manifest file.

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
