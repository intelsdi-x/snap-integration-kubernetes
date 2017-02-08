#!/bin/bash

# If there is file with plugin URLs, download those plugins to autoload directory.
if [ -f /etc/snap/plugins.yaml ]
  then
    echo "-----------------------Downloading plugins-----------------------"
    while read plugin_address; do
      plugin=`echo $plugin_address | rev | cut -d / -f 1 | rev`
      if [ "$plugin" == "" ]
        then
          continue
      fi
      echo "wget $plugin_address -O /opt/snap/autoload/$plugin"
      wget $plugin_address -O /opt/snap/autoload/$plugin
    done </etc/snap/plugins.yaml 
    chmod -R +x /opt/snap/autoload
fi

echo "-----------------------Starting Snap-----------------------"
snapteld -t 0
