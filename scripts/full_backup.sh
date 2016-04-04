#!/bin/bash

. ./lib.sh

wait_time=10
ts=$( timestamp )

# data dir to create
data_dir=/home/vagrant/sync-to-stage/data/F${ts}

mkdir -p ${data_dir}

# Stop the servers
sudo /opt/ibm-ucd/server/bin/server stop
sudo /opt/IBM/UCRelease/server/server.shutdown
echo "Stopping servers, will wait ${wait_time} for them to finish"
sleep ${wait_time}

# Backup the databases ( Full )
for db in ibm_ucd ibm_ucr
do
  /bin/bash ./backup_db.sh "$db" "${data_dir}"
done

# Backup filesystems

## UCD
source=/opt/ibm-ucd/server/
for cur_dir in appdata conf
do
  dest=${data_dir}/deploy
  rsync -avz --delete ${source}/${cur_dir} ${dest}
done

## UCR
source=/opt/IBM/UCRelease/ucrelease
# add plugins
dest=${data_dir}/release

rsync -avz ${source} ${dest}


# Start the servers
sudo /opt/ibm-ucd/server/bin/server start
sudo /opt/IBM/UCRelease/server/server.startup

# Helper
echo "Backups created in ${data_dir}"
