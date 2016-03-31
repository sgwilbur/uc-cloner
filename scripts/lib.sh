#!/bin/bash

function timestamp()
{
  format=$1
  : ${format:='+%Y%m%d-%H%M'}
  echo `date ${format}`
}

function stop_servers()
{
wait_time=$0
# Stop the servers
sudo /opt/ibm-ucd/server/bin/server stop
sudo /opt/IBM/UCRelease/server/server.shutdown
echo "Stopping servers, will wait ${wait_time} for them to finish"
sleep ${wait_time}
}

