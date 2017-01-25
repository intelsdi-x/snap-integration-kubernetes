#! /bin/bash

if [ "$(snaptel agreement list | grep all-nodes | awk '{print $1}')" != "all-nodes" ]; then
    if [[ $DEBUG ]]; then
        echo "Not connected";
    fi
    exit 1;
else
    if [[ $DEBUG ]]; then
      echo "Connected";
    fi
    exit 0;
fi
