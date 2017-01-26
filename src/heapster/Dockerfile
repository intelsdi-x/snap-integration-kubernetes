#
# http://www.apache.org/licenses/LICENSE-2.0.txt
# Copyright 2016 Intel Corporation
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

FROM golang:1.7.4

RUN apt-get install -y git
RUN git clone https://github.com/intelsdi-x/heapster.git /go/src/k8s.io/heapster
RUN cd /go/src/k8s.io/heapster && git checkout remotes/origin/snap

ENV GOMAXPROCS=1
RUN cd /go/src/k8s.io/heapster && make && mv heapster /heapster && mv eventer /eventer

ENTRYPOINT ["/heapster"]
