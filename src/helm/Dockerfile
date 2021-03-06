#
# http://www.apache.org/licenses/LICENSE-2.0.txt
# Copyright 2017 Intel Corporation
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM ubuntu:16.04
MAINTAINER Maria Rolbiecka maria.a.rolbiecka@intel.com

RUN apt-get update && apt-get install -y curl

ENV SNAP_VERSION 1.2.0
ENV SNAP_DOWNLOAD_URL https://github.com/intelsdi-x/snap/releases/download/${SNAP_VERSION}/snap-${SNAP_VERSION}-linux-amd64.tar.gz
ENV SNAP_DIR /snap

WORKDIR ${SNAP_DIR}

RUN curl -sfL "$SNAP_DOWNLOAD_URL" -o snap-telemetry.tar.gz \
    && tar xf snap-telemetry.tar.gz \
    && rm snap-telemetry.tar.gz \
    && cp snapteld /usr/local/sbin \
    && cp snaptel /usr/local/bin

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.12.4
ENV DOCKER_SHA256 f7cb7bb55d6ceba3ba3d24d62027e84799763b4c41b0bda5d8d5b9ba31ed0f2f 

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

RUN mkdir -p /var/log/snap /opt/snap/autoload /proc_host

RUN cd /opt/snap/autoload \
    && curl -fSL "https://github.com/raintank/snap-plugin-collector-snapstats/releases/download/v0.0.1/snap-plugin-collector-snapstats" -o snap-plugin-collector-snapstats \
    && curl -fSL "https://github.com/intelsdi-x/snap-plugin-publisher-influxdb/releases/download/22/snap-plugin-publisher-influxdb_linux_x86_64" -o snap-plugin-publisher-influxdb \
    && curl -fSL "https://github.com/raintank/snap-plugin-collector-kubestate/releases/download/1/snap-plugin-collector-kubestate_linux_x86_64" -o snap-plugin-collector-kubestate \
    && curl -fSL "https://github.com/intelsdi-x/snap-plugin-collector-docker/releases/download/7/snap-plugin-collector-docker_linux_x86_64" -o snap-plugin-collector-docker \
    && curl -fSL "https://github.com/intelsdi-x/snap-plugin-collector-psutil/releases/download/10/snap-plugin-collector-psutil_linux_x86_64" -o snap-plugin-collector-psutil

RUN chmod -R +x /opt/snap/autoload

EXPOSE 8181 8777

COPY tasks/* /opt/snap/autoload/
COPY snapteld.conf /etc/snap/snapteld.conf
COPY start.sh /
ENTRYPOINT ["/start.sh"]    
