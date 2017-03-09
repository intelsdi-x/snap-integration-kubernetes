#!/bin/bash
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

if [[ -z "$INFLUXDB_USER" ]]; then
    export INFLUXDB_USER=admin
fi
if [[ -z "$INFLUXDB_PASS" ]]; then
    export INFLUXDB_PASS=admin
fi
sed -i "s/user.*/user: $INFLUXDB_USER/" /opt/snap/autoload/kubestate.yml
sed -i "s/password.*/password: $INFLUXDB_PASS/" /opt/snap/autoload/kubestate.yml
sed -i "s/user.*/user: $INFLUXDB_USER/" /opt/snap/autoload/docker.yml
sed -i "s/password.*/password: $INFLUXDB_PASS/" /opt/snap/autoload/docker.yml
sed -i "s/user.*/user: $INFLUXDB_USER/" /opt/snap/autoload/snapstats.yml
sed -i "s/password.*/password: $INFLUXDB_PASS/" /opt/snap/autoload/snapstats.yml

snapteld 
