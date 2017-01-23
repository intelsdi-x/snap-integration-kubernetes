#! /bin/bash

if [ "$(snaptel agreement list | awk '{print $1}' | tail -1)" != "all-nodes" ]; then
    if [[ $DEBUG ]]; then
        echo "Not connected";
    fi
    exit 1;
else
    if [[ $DEBUG ]]; then
      echo "Conneted";
    fi
    exit 0;
fi
