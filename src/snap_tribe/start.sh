#!/bin/bash
LOG_LEVEL=${LOG_LEVEL:-3} 
if [ "$INITIAL_MEMBER" == "$HOSTNAME" ];then
    echo "snapteld --tribe -t 0 -l $LOG_LEVEL" 
    snapteld --tribe -t 0 -l $LOG_LEVEL
else
    echo "snapteld --tribe --tribe-addr $POD_IP --tribe-seed $SEED -l $LOG_LEVEL"
    snapteld --tribe -t 0 --tribe-addr $POD_IP --tribe-seed $SEED -l $LOG_LEVEL
fi
