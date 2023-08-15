#!/bin/bash
scontrol update nodename=$1 state=RESUME
if [ $? != 0 ];then
  logger "scontrol resume failed for node $1"
else 
  logger "node $1 resumed successfully or already resumed"
fi
