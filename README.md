<!--
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
-->

# Running Snap in various environments

Snap can be deployed to collect metrics in various environments including Docker containers and Kubernetes. It can be run in a Docker container to gather metrics i.e. from host and other containers. Deployment of Snap in Kubernetes cluster gives a possibility to monitor pods in the cluster.
In this repo you will find information on how to run Snap in those environments.

1. [Running Snap](#1-running-snap) 
  * [Snap in Docker container](#snap-in-docker-container)
  * [Snap in Kubernetes](#snap-in-kubernetes)
2. [Customization and configuration](#2-customization-and-configuration)
3. [Contributing](#3-contributing)
4. [License](#4-license)

### 1. Running Snap
First step is to download this repo. All of the needed files are in the `snap-integration-kubernetes` directory.
```sh
$ git clone https://github.com/intelsdi-x/snap-integration-kubernetes/
$ cd ./snap-integration-kubernetes
```
#### Snap in Docker container
To learn about running Snap in a Docker container run example [Running Snap in Docker container](https://github.com/intelsdi-x/snap-integration-kubernetes/tree/master/run/docker/README.md).

#### Snap in Kubernetes
To learn about running Snap in Kubernetes run example [Running Snap in Kubernetes pod](https://github.com/intelsdi-x/snap-integration-kubernetes/tree/master/run/kubernetes/README.md).

Here you'll find an example of running [Snap with Kubernetes on Google Compute Engine](https://github.com/intelsdi-x/snap-integration-kubernetes/tree/master/run/gce/README.md).

### 2. Customization and configuration 
Inside Docker container it is possible to load most of the Snap plugins. The list of all Snap plugins is available in [plugin catalog](https://github.com/intelsdi-x/snap/blob/master/docs/PLUGIN_CATALOG.md). After you choose plugin you click the plugin name. This redirects you to the plugin repository. 

To use plugin inside the container you need to download its binary. In order to get plugin binary URL you go to the `release` section... 

<img src="https://cloud.githubusercontent.com/assets/6523391/21221560/1c428440-c2be-11e6-9d73-6c565b88aa6e.png" width="70%">

...and copy the link for the latest plugin release.

<img src="https://cloud.githubusercontent.com/assets/6523391/21221622/69a08e6c-c2be-11e6-916f-f7179332b435.png" width="70%">


Many of the plugins require prior configuration and adjustment of container or Kubernetes manifest. The example of such plugin is Snap Docker collector plugin. The Docker collector allows to collect runtime metrics from Docker containers and its host machine. It gathers information about resource usage and performance characteristics. More information about docker collector can be found [here](https://github.com/intelsdi-x/snap-plugin-collector-docker).

All of the plugins requirements can be found in their documentation. The documentation of the Snap Docker plugin collector can be found [here](https://github.com/intelsdi-x/snap-plugin-collector-docker/blob/master/README.md). Docker plugin collector needs access to files residing in the host machine:
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
### 3. Contributing
We love contributions!

There's more than one way to give back, from examples to blogs to code updates. See our recommended process in [CONTRIBUTING.md](CONTRIBUTING.md).

### 4. License
[Snap](http://github.com/intelsdi-x/snap), along with this plugin, is an Open Source software released under the Apache 2.0 [License](LICENSE).
