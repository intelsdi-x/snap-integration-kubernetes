FROM ubuntu
MAINTAINER mateusz.kleina@intel.com

RUN apt-get update
RUN apt-get -y install wget curl make git vim netcat gcc mysql-client

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.12.4
ENV DOCKER_SHA256 f7cb7bb55d6ceba3ba3d24d62027e84799763b4c41b0bda5d8d5b9ba31ed0f2f

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

# get golang for building snap and plugins
ENV GOLANG_VERSION 1.7.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 508028aac0654e993564b6e2014bf2d4a9751e3b286661b0b0040046cf18028e

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV GOMAXPROCS=1

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# build snap
RUN git clone https://github.com/intelsdi-x/snap.git /go/src/github.com/intelsdi-x/snap
WORKDIR /go/src/github.com/intelsdi-x/snap
RUN git reset --hard 15bb174ce750e5f9c27b400510e05352564623ab
RUN make && make install

# build heapster publisher
COPY snap-plugin-publisher-heapster /go/src/github.com/intelsdi-x/snap-plugin-publisher-heapster
WORKDIR /go/src/github.com/intelsdi-x/snap-plugin-publisher-heapster
RUN make

# build docker collector
COPY snap-plugin-collector-docker /go/src/github.com/intelsdi-x/snap-plugin-collector-docker
WORKDIR /go/src/github.com/intelsdi-x/snap-plugin-collector-docker
RUN make

# create directory for snap plugins and task autoload
RUN mkdir -p /opt/snap/plugins
RUN mkdir -p /opt/snap/tasks
RUN mkdir -p /proc_host

# build start_snap binary
COPY start_snap /go/src/start_snap
WORKDIR /go/src/start_snap
RUN go build -o start_snap
RUN cp -a /go/src/start_snap/start_snap /usr/local/bin/start_snap 

# copy task
COPY tasks /opt/snap/tasks

# Install plugins in autoload directory
RUN cp -a /go/src/github.com/intelsdi-x/snap-plugin-publisher-heapster/build/linux/x86_64/snap-plugin-publisher-heapster /opt/snap/plugins
RUN cp -a /go/src/github.com/intelsdi-x/snap-plugin-collector-docker/build/linux/x86_64/snap-plugin-collector-docker /opt/snap/plugins
RUN cp -a /go/src/github.com/intelsdi-x/snap/build/linux/x86_64/plugins/snap-plugin-publisher-mock-file /opt/snap/plugins

# start snap daemon
ENV SNAPTELD_BIN /usr/local/sbin/snapteld
ENV SNAPTEL_BIN /usr/local/bin/snaptel
ENV PLUGINS_AUTOLOAD_DIR /opt/snap/plugins 
ENV PLUGINS_TO_LOAD 3
ENV TASK_AUTOLOAD_FILE /opt/snap/tasks/heapster-docker.json
ENV PROCFS_MOUNT /proc_host
EXPOSE 8181 8777
ENTRYPOINT ["/usr/local/bin/start_snap"]
