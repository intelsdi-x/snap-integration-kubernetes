#!/bin/bash
if [ "$INITIAL_MEMBER" == "`hostname`" ];then
    echo "snapteld --tribe -t 0 &" 
    snapteld --tribe -t 0 &
    echo "sleep 3"
    sleep 3
    echo "snaptel agreement create all-nodes"
    snaptel agreement create all-nodes
else
    echo "snapteld --tribe --tribe-addr $POD_IP --tribe-seed $SEED"
    snapteld --tribe -t 0 --tribe-addr $POD_IP --tribe-seed $SEED &
fi
echo "sleep 3"
sleep 3
snaptel agreement join all-nodes $HOSTNAME
echo "Done"
echo $(snaptel member list | grep $HOSTNAME)

while true
do
    sleep 100000
done
