#!/bin/bash

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

if [ "$INITIAL_MEMBER" == "$HOSTNAME" ];then
    echo "snaptel agreement create all-nodes"
    snaptel agreement create all-nodes
fi

for i in {1..60}
do
    curl localhost:8181/v1/plugins
	if [[ $? == "0" ]]
	    then
                break
        else
                sleep 1
        fi
done

echo "snaptel agreement join all-nodes $HOSTNAME"
snaptel agreement join all-nodes $HOSTNAME
echo "Done"
echo $(snaptel member list | grep $HOSTNAME)
