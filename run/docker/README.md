# Running Snap in Docker container
1. [Getting started](#1-getting-started)  
2. [Configuration of Docker container](#2-configuration-of-docker-container)

### 1. Getting started
To run Snap inside Docker container you need to have Docker installed. First step is to download this repo. All of the needed files are in the `snap-integration-kubernetes` directory.
```sh
$ git clone https://github.com/intelsdi-x/snap-integration-kubernetes/
$ cd ./snap-integration-kubernetes
```

### 2. Running Snap in Docker container
In order to run Snap in a single docker containter you can pull Snap Docker image `intelsdi/snap4kube:0.1` from official Snap [repo](https://hub.docker.com/r/intelsdi/snap4kube/) on DockerHub or build it by yourself. 

#### a) Running Snap in a container using DockerHub image
To run Snap with official image `intelsdi/snap4kube:0.1` from DockerHub repo you simply run the command:
```sh
$ docker run -d --name snap -p 8181:8181 intelsdi/snap4kube:0.1
```

#### b) Running Snap in a container using your own image
However, if you prefer building Snap image on your own, you can use Dockerfile located in the directory `snap-integration-kubernetes/src/snap`. To build Snap image from Dockerfile, you run the command:
```sh
$ docker build -t <snap-image-name> snap-integration-kubernetes/src/snap
```
and when the image is ready, you may start Snap with your own image:
```sh
$ docker run -d --name snap -p 8181:8181 <snap-image-name>
```

#### c) Verification if Snap started correctly
To verify that Snap container has started correctly and perform some actions to start collection of metrics we need to log into the Snap container. Getting into the container is quite simple:
```sh
$ docker exec -ti snap bash
```
Now that you are inside the container with running Snap daemon, you may run command to list the plugins:
```sh
$ snaptel plugin list
``` 
The output should be `No plugins found. Have you loaded a plugin?` as there are no plugins loaded yet. Let's download some...

#### d) Loading Snap plugins inside running container - CPU collector plugin example 
Inside a container you may use many different Snap plugins. Most of them require configuration. All of the plugins requirements can be found in their documentation. 

In this section we show how to configure and load [CPU plugin collector](https://github.com/intelsdi-x/snap-plugin-collector-cpu) inside a container. The documentation of the Snap CPU plugin collector can be found [here](https://github.com/intelsdi-x/snap-plugin-collector-cpu/blob/master/README.md). As it is stated in the documentation, the CPU plugin collector gathers information from the file `/proc/stat` residing in the host machine. Running this plugin inside the container requires mapping of this file inside of the container. The original host file `/proc/stat` has to be available inside of the container. This means that we have to adjust Snap container in order to be able to use CPU plugin inside it.

In a Docker container mapping of the files is done with the addition of `-v` flag when running the container. 
```sh
$ docker run -d --name snap -v <path-to-file-on-host>:<path-to-file-in-container> intelsdi/snap4kube:0.1
```
So, to run Snap with CPU plugin reading resource usage from host you need to use command as below.
```sh
$ docker run -d --name snap -v /proc:/proc_host intelsdi/snap4kube:0.1
```
If you get the error `Conflict. The name "/snap" is already in use by container 0c8552a92025293b663ac458dd5f2133b5c825f1840fa4169f6957246c424503. You have to remove (or rename) that container to be able to reuse that name..` you have to remove running Snap container:
```sh
$ docker rm -f snap
```
and then create it one more time:
```sh
$ docker run -d --name snap -v /proc:/proc_host intelsdi/snap4kube:0.1
```
Now that we have Snap container configured, we may download and load CPU collector plugin...
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-cpu/releases/download/6/snap-plugin-collector-cpu_linux_x86_64" -o snap-plugin-collector-cpu
$ snaptel plugin load snap-plugin-collector-cpu
```
...and file publisher plugin:
```sh
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file
$ snaptel plugin load snap-plugin-publisher-file
```
Now, running the command:
```sh
$ snaptel plugin list
``` 
will print information about the two loaded plugins. To start the collection of metrics you can create task.
```sh
$ curl -sO https://raw.githubusercontent.com/intelsdi-x/snap-integration-kubernetes/examples/tasks/cpu-file.json
$ snaptel task create -t snap-integration-kubernetes/examples/tasks/cpu-file.json
```
Command:
```sh
$ snaptel task list
``` 
will provide information whether the metrics collection was successfull or not. Use task watch to verify that tasks have been created correctly.
```sh
$ snaptel task watch <task-id>
```

More information and examples of loading plugins is described in section [Configuration of Docker container](#2-configuration-of-docker-container).


### 2. Configuration of Docker container
Inside Docker container it is possible to load most of the Snap plugins. The list of all Snap plugins is available in [plugin catalog](https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md). After you choose plugin you click the plugin name. This redirects you to the plugin repository. 

To use plugin inside the container you need to download its binary. In order to get plugin binary URL you go to the `release` section... 

<img src="https://cloud.githubusercontent.com/assets/6523391/21221560/1c428440-c2be-11e6-9d73-6c565b88aa6e.png" width="70%">

...and copy the link for the latest plugin release.

<img src="https://cloud.githubusercontent.com/assets/6523391/21221622/69a08e6c-c2be-11e6-916f-f7179332b435.png" width="70%">


Many of the plugins require prior configuration and adjustment of container. The example of such plugin is Snap Docker collector plugin. The Docker collector allows to collect runtime metrics from Docker containers and its host machine. It gathers information about resource usage and performance characteristics. More information about docker collector can be found [here](https://github.com/intelsdi-x/snap-plugin-collector-docker).

All of the plugins requirements can be found in their documentation. The documentation of the Snap Docker plugin collector can be found [here](https://github.com/intelsdi-x/snap-plugin-collector-docker/blob/master/README.md). Docker plugin collector needs access to files residing in the host machine:
- `/var/run/docker.sock`
- `/proc`
- `/usr/bin/docker`
- `/var/lib/docker`
- `/sys/fs/cgroup`

This means that the original host files have to be available inside of the container. Running this plugin inside the container requires mapping of those files inside of the container. What is more, Docker collector plugin requires enviroment variable `PROCFS_MOUNT` to be set. It should point to the directory inside the container where original host directorry `/proc` is mounted. 

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



