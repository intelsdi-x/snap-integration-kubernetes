FROM ubuntu:16.04
MAINTAINER Maria Rolbiecka maria.a.rolbiecka@intel.com

RUN apt-get update && apt-get -y install git curl

ENV SNAP_VERSION 1.0.0
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


# get golang for building start_snap script

ENV GOLANG_VERSION 1.7.3
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 508028aac0654e993564b6e2014bf2d4a9751e3b286661b0b0040046cf18028e

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
        && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
        && tar -C /usr/local -xzf golang.tar.gz \
        && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

# build start_snap binary
RUN go get -v "github.com/tools/godep"

# from docs of k8s.io/client-go dependencies section
WORKDIR /go/src/k8s.io
RUN git clone https://github.com/kubernetes/client-go
WORKDIR /go/src/k8s.io/client-go
RUN git checkout release-1.5
WORKDIR /go/src/k8s.io/client-go/1.5
RUN godep restore -v
RUN rm -rf vendor

COPY start_snap /go/src/start_snap
WORKDIR /go/src/start_snap
RUN go build -o start_snap
RUN cp -a /go/src/start_snap/start_snap /usr/local/bin/start_snap

# start snap daemon
ENV SNAPTELD_BIN /usr/local/sbin/snapteld
ENV SNAPTEL_BIN /usr/local/bin/snaptel
EXPOSE 8181 8777 6000 8182
COPY ./start.sh /
ENTRYPOINT ["/start.sh"]

