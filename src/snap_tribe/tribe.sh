#!/bin/bash
if [ "$INITIAL_MEMBER" == "$HOSTNAME" ];then
    echo "snaptel agreement create all-nodes"
    snaptel agreement create all-nodes
fi

for i in {1..1000}
do
    curl localhost:8181/v1/plugins
	if [[ $? == "7" ]]
	    then
                sleep 1
        fi
done

echo "snaptel agreement join all-nodes $HOSTNAME"
snaptel agreement join all-nodes $HOSTNAME
echo "Done"
echo $(snaptel member list | grep $HOSTNAME)
