# Snap
<img src="https://cloud.githubusercontent.com/assets/1744971/20331694/e07e9148-ab5b-11e6-856a-e4e956540077.png" width="70%">

[Snap](https://github.com/intelsdi-x/snap) is a powerful open source telemetry framework. It allows to collect, process and publish system data gathered from various environments. Deployment of Snap in Kubernetes cluster gives a possibilty to monitor pods and nodes in the cluster. It can collect metrics i.e. from host and other containers. To learn more please go to [Snap documentation](https://github.com/intelsdi-x/snap/blob/master/README.md) and [Snap integrations repo](https://github.com/intelsdi-x/snap-integration-kubernetes).

1. [QuickStart](#1-quick-start)
2. [Introduction](#2-introduction)
3. [Prerequisites](#3-prerequisites)
4. [Installing the Chart](#4-installing-the-chart)
5. [Uninstalling the Chart](#5-uninstalling-the-chart)
6. [Configuration](#6-configuration)
7. [Loading Snap plugins](#7-loading-snap-plugins)

## 1. Quick Start

`$ helm install stable/snap`

## 2. Introduction

This chart bootstraps Snap on all nodes in your Kubernetes Cluster via DaemonSet using Helm package manager. It uses official Snap for Kubernetes Docker image [intelsdi/snap4kube](https://hub.docker.com/r/intelsdi/snap4kube/).

As you may read in [Snap documentation](https://github.com/intelsdi-x/snap#overview) the framework consists of two main components: `snapteld` daemon and plugins. This chart deploys and evokes only Snap daemon `snapteld`. In order to begin collection of any metrics we need some plugins. It is up to the user which plugin they wish to use. The list of all plugins is available in [Plugin Catalog](https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md). The user needs to download and load plugins. More information on how to configure and load Snap plugins can be found in [Loading Snap plugins](#7-loading-snap-plugins) section of this document as well as in Snap integration repo in section [Running Snap in Kubernetes](https://github.com/intelsdi-x/snap-integration-kubernetes/tree/master/run/kubernetes).

## 3. Prerequisites

* Kubernetes 1.4+ with Beta APIs enabled

## 4. Installing the Chart

To install the chart with the release name my-snap use command:

`$ helm install --name my-snap stable/snap`

This command deploys Snap on the Kubernetes cluster in the default configuration. To learn how to override the default configuration see section [Configuration](#6-configuration).

## 5. Uninstalling the Chart

To uninstall/delete the my-snap daemonset use command:

`$ helm delete my-snap --purge`

The command removes all the Kubernetes components associated with the chart and deletes the release.

## 6. Configuration

To see the default configuration of Snap chart run:

`$ helm inspect values stable/snap`

To override any of these settings create your own YAML formatted file and pass it during installation:
```
$ echo 'namespace: default' > values.yaml
$ helm  install -f values.yaml stable/snap
```
or use `set` flag to specify custom values on the command line like this:

`$ helm install --set namespace=default stable/snap`

You will find more information in Helm Guide section [Customizing the Chart Before Installing](https://github.com/kubernetes/helm/blob/master/docs/using_helm.md#customizing-the-chart-before-installing).

| Parameter                 | Description                                         | Default                           |
|---------------------------|-----------------------------------------------------|-----------------------------------|
| `namespace`               | namespace for the release                           | kube-system                       |
| `image.repo`              | docker image                                        | intelsdi/snap4kube                |
| `image.tag`               | docker image tag                                    | latest                            |
| `image.pullPolicy`        | image pull policy                                   | IfNotPresent                      |
| `mounts`                  | list of volumes to mount inside the Snap container  | /proc:/proc_host                  |
| `host_plugins`            | host path to the directory with plugins and tasks   | /opt/plugins                      |
| `privileged`              | security context needed to access files on the host | false                             |
| `config.log_level`        | log level of Snap, (1=debug, 5=error)               | 3                                 |
| `config.log_path`         | container path to Snap logs                         | /snap                             |
| `config.autodiscover_path`| list of volumes to mount inside the Snap container  | /opt/snap/autoload                |

## 7. Loading Snap plugins

In this section we present two ways of loading Snap plugins:

* [Loading plugins manually](#loading-plugins-manually)
* [Automation of loading plugins](#automation-of-loading-plugins)

First section presents simple example of using [CPU collector plugin](https://github.com/intelsdi-x/snap-plugin-collector-cpu) and [file publisher plugin](https://github.com/intelsdi-x/snap-plugin-publisher-file)). It illustrates how Snap framework works and allows to get familiar with basic concept of Snap. However it is not recommended to setup the collection of metrics this way because the configuration won't survive pod restart.

To configure this Snap chart properly please refer to the section [Automation of loading plugins](#automation-of-loading-plugins).

### Loading plugins manually

After creating Snap daemonset from the chart with command:

`$ helm install stable/snap`

you can list all the pods in order to verify if Snap pods are running correctly:

`$ kubectl get pods --all-namespaces`

The output should contain Snap pods:

```
NAMESPACE     NAME                                    READY     STATUS    RESTARTS   AGE
default       snap-1kc54                              1/1       Running   0          1m
default       snap-mshwn                              1/1       Running   0          1m
default       snap-q0mkc                              1/1       Running   0          1m
default       snap-q51xc                              1/1       Running   0          1m
default       snap-rqk45                              1/1       Running   0          1m
default       snap-wcklm                              1/1       Running   0          1m

```

This means that we have `snapteld` daemon running inside each pod. What we need now to start monitoring of the nodes are Snap plugins.
The example below shows the use of Snap [CPU collector plugin](https://github.com/intelsdi-x/snap-plugin-collector-cpu) and [file publisher plugin](https://github.com/intelsdi-x/snap-plugin-publisher-file). 

First we need to download plugin binaries:

```
$ kubectl exec -ti <snap_pod> -- curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-cpu/releases/download/6/snap-plugin-collector-cpu_linux_x86_64" -o snap-plugin-collector-cpu
$ kubectl exec -ti <snap_pod> -- curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file
``` 

and load them using snaptel command:

```
$ kubectl exec -ti <snap_pod> -- snaptel plugin load snap-plugin-collector-cpu
$ kubectl exec -ti <snap_pod> -- snaptel plugin load snap-plugin-publisher-file
```

Now running the command:

`
$ kubectl exec -ti <snap_pod> -- snaptel plugin list
`

will print information about two loaded plugins. To start the actual collection of metrics you create task.

```
$ kubectl exec -ti <snap_pod> -- curl -s0 https://raw.githubusercontent.com/intelsdi-x/snap-integration-kubernetes/master/examples/tasks/cpu-file.json
$ kubectl exec -ti <snap_pod> -- snaptel task create -t cpu-file.json
```

Command:
`$ kubectl exec -ti <snap_pod> -- snaptel task list`

will provide information whether the metrics collection was successfull or not. Use task watch to verify that tasks have been created correctly.
`$ kubectl exec -ti <snap_pod> -- snaptel task watch <task_id>`

### Automation of loading plugins

Download Snap chart to home directory:
```
$ git clone https://github.com/intelsdi-x/snap-integration-kubernetes
$ cd ~/snap-integration-kubernetes/run/helm/snap
```

First step is to choose plugins to load from [Plugin Catalog](https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md). Let's say that we want to monitor all of the containers in Kubernetes cluster and publish results to the file. This means that we need [Docker collector](https://github.com/intelsdi-x/snap-plugin-collector-docker) and [file publisher](https://github.com/intelsdi-x/snap-plugin-publisher-file) plugins.

Create directory on the host to store plugin binaries, download selected plugins binaries to this directory and override default value of `host_plugins` parameter.
```
$ echo "host_plugins: /opt/snap" > new_values.yaml
$ mkdir -p /opt/snap
$ cd /opt/snap
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/6/snap-plugin-collector-docker_linux_x86_64" -o snap-plugin-collector-docker
$ curl -fsL "https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64" -o snap-plugin-publisher-file 
$ chmod -R +x /opt/snap 
```

Docker collector reads values from files residing on the host, therefore those files need to be mounted inside a container in which Snap is running. Docker collector needs access to files on the host:
- `/var/run/docker.sock`
- `/proc`
- `/usr/bin/docker`
- `/var/lib/docker`
- `/sys/fs/cgroup`

Usually you would add `volumeMounts` and `volumes` parameters to the Kubernetes manifest, but this Snap chart handles volumes mounting for you. The only thing to change is `mounts` parameter of chart values file.

```
$ cd ~/snap-integration-kubernetes/run/helm/snap
$ cat <<EOF >> new_values.yaml
mounts:
  "/var/run/docker.sock":"/var/run/docker.sock"
  "/proc":"/proc_host"
  "/usr/bin/docker":"/usr/local/bin/docker"
  "/var/lib/docker":"/var/lib/docker"
  "/sys/fs/cgroup":"/sys/fs/cgroup"
privileged: true
EOF
```

Format of mounts parameter is:
```
mounts:
 "<host_path_a>":"<container_path_a>"
 "<host_path_b>":"<container_path_b>"
```

We will also need privileged mode to access those files residing on the host.

The last thing to prepare is task manifest that will specify what metrics should be collected. It should be in `/opt/snap` directory along with plugins. Everything that resides in this dir will be automatically loaded at the start of the container.
 
```
$ cd /opt/snap
$ curl -sO https://raw.githubusercontent.com/mkuculyma/snap-integration-kubernetes/helm/examples/tasks/docker-file.yaml 
```

You need to copy the `/opt/snap` directory to all of the cluster nodes on which you wish to run Snap.

Last thing is to install Snap chart with new values:

```
$ cd ~/snap-integration-kubernetes/run/helm/snap
$ helm install -f new_values.yaml --set namespace=default .
```

Now you can list all the pods in order to verify if Snap pods are running correctly:

`$ kubectl get pods --all-namespaces`

The output should contain Snap pods:

```
NAMESPACE     NAME                                    READY     STATUS    RESTARTS   AGE
default       snap-1kc54                              1/1       Running   0          1m
default       snap-mshwn                              1/1       Running   0          1m
default       snap-q0mkc                              1/1       Running   0          1m
default       snap-q51xc                              1/1       Running   0          1m
default       snap-rqk45                              1/1       Running   0          1m
default       snap-wcklm                              1/1       Running   0          1m

```

Command:
`$ kubectl exec -ti <snap_pod> -- snaptel task list`

will provide information whether the metrics collection was successfull or not. Use task watch to verify that tasks have been created correctly.
`$ kubectl exec -ti <snap_pod> -- snaptel task watch <task_id>`

