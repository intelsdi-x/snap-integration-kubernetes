# Snap
<img src="https://cloud.githubusercontent.com/assets/1744971/20331694/e07e9148-ab5b-11e6-856a-e4e956540077.png" width="70%">

[Snap](https://github.com/intelsdi-x/snap) is a powerful open source telemetry framework. It allows to collect, process and publish system data gathered from various environments. Deployment of Snap in Kubernetes cluster gives a possibilty to monitor pods and nodes in the cluster. It can collect metrics i.e. from host and other containers. To learn more please go to [Snap documentation](https://github.com/intelsdi-x/snap/blob/master/README.md) and [Snap integrations repo](https://github.com/intelsdi-x/snap-integration-kubernetes).

1. [Quick Start](#1-quick-start)
2. [Introduction](#2-introduction)
3. [Prerequisites](#3-prerequisites)
4. [Installing the Chart](#4-installing-the-chart)
5. [Uninstalling the Chart](#5-uninstalling-the-chart)
6. [Configuration](#6-configuration)
7. [Loading Snap Plugins](#7-loading-snap-plugins)
8. [Deep Dive](#8-deep-dive)

## 1. Quick Start

`$ helm install stable/snap`

## 2. Introduction

This chart bootstraps Snap on all nodes in your Kubernetes Cluster via DaemonSet using Helm package manager. It uses official Snap for Kubernetes Docker image [intelsdi/snap4kube](https://hub.docker.com/r/intelsdi/snap4kube/).

As you may read in [Snap documentation](https://github.com/intelsdi-x/snap#overview) the framework consists of two main components: `snapteld` daemon and plugins. This chart deploys and evokes only Snap daemon `snapteld`. In order to begin collection of any metrics we need some plugins. It is up to the user which plugin they wish to use. The list of all plugins is available in [Plugin Catalog](https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md). The user needs to download and load plugins. More information on how to configure and load Snap plugins can be found in [Loading Snap Plugins](#7-loading-snap-plugins) and [Deep Dive](#8-deep-dive) sections.

## 3. Prerequisites

* Kubernetes 1.4+ with Beta APIs enabled

## 4. Installing the Chart

To install the chart with the release name my-snap use command:

`$ helm install --name my-snap stable/snap`

This command deploys Snap on the Kubernetes cluster in the default configuration. To learn how to override the default configuration see section [Configuration](#6-configuration).

## 5. Uninstalling the Chart

To uninstall/delete the my-snap daemonset use command:

`$ helm delete my-snap`

The command removes all the Kubernetes components associated with the chart and deletes the release.

## 6. Configuration

To see the default configuration of Snap chart run:

`$ helm inspect values stable/snap`

To override any of these settings create your own YAML formatted file and pass it during installation:
```
$ echo 'host_plugins: /opt/snap' > new_values.yaml
$ helm  install -f new_values.yaml stable/snap
```
or use `set` flag to specify custom values on the command line like this:

`$ helm install --set host_plugins=/opt/snap stable/snap`

You will find more information in Helm Guide section [Customizing the Chart Before Installing](https://github.com/kubernetes/helm/blob/master/docs/using_helm.md#customizing-the-chart-before-installing).

| Parameter                 | Description                                         | Default                           |
|---------------------------|-----------------------------------------------------|-----------------------------------|
| `image.repo`              | docker image                                        | intelsdi/snap4kube                |
| `image.tag`               | docker image tag                                    | latest                            |
| `image.pullPolicy`        | image pull policy                                   | IfNotPresent                      |
| `mounts`                  | list of volumes to mount inside the Snap container  | /proc:/proc_host                  |
| `host_autoload`           | host path to the directory with plugins and tasks   | /opt/autoload                     |
| `privileged`              | security context needed to access files on the host | false                             |
| `config.log_level`        | log level of Snap, (1=debug, 5=error)               | 3                                 |
| `config.log_path`         | container path to Snap logs                         | /snap                             |
| `config.autodiscover_path`| list of volumes to mount inside the Snap container  | /opt/snap/autoload                |
| `autoload`                | list of Snap plugins/tasks URLs to download and load| empty                             |

## 7. Loading Snap plugins

The easiest way to download and load Snap plugins is to specify plugins binaries URL in the `autoload` parameter in `values.yaml` file.

Here is a simple example of using [CPU collector plugin](https://github.com/intelsdi-x/snap-plugin-collector-cpu) with [file publisher plugin](https://github.com/intelsdi-x/snap-plugin-publisher-file).

```
$ cat <<EOF >> new_values.yaml
autoload:
  - https://github.com/intelsdi-x/snap-plugin-collector-cpu/releases/download/6/snap-plugin-collector-cpu_linux_x86_64
  - https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64
  - https://raw.githubusercontent.com/intelsdi-x/snap-integration-kubernetes/master/examples/tasks/cpu-file.json
EOF
```

With the command above we override default values adding list of URLs of two plugin binaries `snap-plugin-collector-cpu_linux_x86_64` and `snap-plugin-publisher-file_linux_x86_64`.
The third URL downloads exemplary task for CPU plugin.

Now running command:

`$ helm install -f new_values.yaml stable/snap`

will create your very own Snap release!

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

Now running the command:

`
$ kubectl exec -ti <snap_pod> -- snaptel plugin list
`

will print information about two loaded plugins. And command:

`$ kubectl exec -ti <snap_pod> -- snaptel task list`

will provide information whether the metrics collection was successful or not. Use task watch to verify that tasks have been created correctly.
`$ kubectl exec -ti <snap_pod> -- snaptel task watch <task_id>`

To get more information on how to configure Snap plugins, please go to [Deep Dive](#8-deep-dive) section below.

## 8. Deep dive

There are two aspects to consider when running Snap in Kubernetes:

* [Configuration of Snap Plugins](#configuration-of-snap-plugins)
* [Preparing Snap Task](#preparing-snap-task)

### Configuration of Snap Plugins

Some of the plugins require more advanced configuration then those presented in the section above. Good example of such plugin is [Docker collector](https://github.com/intelsdi-x/snap-plugin-collector-docker).  The Docker collector allows to collect runtime metrics from Docker containers and its host machine. It gathers information about resource usage and performance characteristics. In order to configure this plugin we need to follow steps described below.

#### Step 1. Loading plugin binary

In order to get plugin binary you need to go to the plugin repo. The list of all Snap plugins is available in [Plugin Catalog](https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md). After you choose plugin you click the plugin name. This redirects you to the plugin repository.

In order to get plugin binary URL you go to the `release` section... 

<img src="https://cloud.githubusercontent.com/assets/6523391/21221560/1c428440-c2be-11e6-9d73-6c565b88aa6e.png" width="70%">

...and copy the link for the latest plugin release.

<img src="https://cloud.githubusercontent.com/assets/6523391/21221622/69a08e6c-c2be-11e6-916f-f7179332b435.png" width="70%">
  
Then you add this link to the `autoload` parameter of `values.yaml` file.

```
$ cat <<EOF >> new_values.yaml
autoload:
  - https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/6/snap-plugin-collector-docker_linux_x86_64
  - https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64
EOF
```

You need to do the same with file publisher plugin.

#### Step 2. Configuration of plugin

Docker collector reads values from files residing on the host, therefore those files need to be mounted inside a container in which Snap is running. Docker collector needs access to files on the host:
- `/var/run/docker.sock`
- `/proc`
- `/usr/bin/docker`
- `/var/lib/docker`
- `/sys/fs/cgroup`

Usually you would add `volumeMounts` and `volumes` parameters to the Kubernetes manifest, but this Snap chart handles volumes mounting for you. The only thing to change is `mounts` parameter of chart values file.

```
$ cat <<EOF >> new_values.yaml
mounts:
  /var/run/docker.sock: /var/run/docker.sock
  /proc: /proc_host
  /usr/bin/docker: /usr/local/bin/docker
  /var/lib/docker: /var/lib/docker
  /sys/fs/cgroup: /sys/fs/cgroup
privileged: true
EOF
```

Format of mounts parameter is:
```
mounts:
 <host_path_a>: <container_path_a>
 <host_path_b>: <container_path_b>
```

We will also need privileged mode to access those files residing on the host.

### Preparing Snap Task 

The last thing to prepare is task manifest that will specify what metrics should be collected. If you want to use an exemplary task from this repo you can specify task URL the same way we provided plugins URL, simply by adding third element to the `autoload` list in `values.yaml` file so that final `new_values.yaml` file looks like this:

```
mounts:
  /var/run/docker.sock: /var/run/docker.sock
  /proc: /proc_host
  /usr/bin/docker: /usr/local/bin/docker
  /var/lib/docker: /var/lib/docker
  /sys/fs/cgroup: /sys/fs/cgroup
privileged: true
autoload:
  - https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/6/snap-plugin-collector-docker_linux_x86_64
  - https://github.com/intelsdi-x/snap-plugin-publisher-file/releases/download/2/snap-plugin-publisher-file_linux_x86_64
  - https://raw.githubusercontent.com/mkuculyma/snap-integration-kubernetes/helm/examples/tasks/docker-file.yaml
```

The other way is to create and `/opt/snap` directory in the nodes on which Snap pods will run and place there task manifests. Everything that resides in this dir will be automatically loaded at the start of the container. Note: You need to copy the `/opt/snap` directory to all of the cluster nodes on which you wish to run Snap.

Last thing is to install Snap chart with new values:

```
$ helm install -f new_values.yaml stable/snap.
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

will provide information whether the metrics collection was successful or not. Use task watch to verify that tasks have been created correctly.
`$ kubectl exec -ti <snap_pod> -- snaptel task watch <task_id>`

