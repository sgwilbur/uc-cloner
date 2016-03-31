#!/bin/bash
# full_restore.sh

. ./lib.sh
wait_time=10

# data dir to restore from
#data_dir=/home/vagrant/sync-to-stage/data/F${ts}
data_dir=$1

# Stop the servers
sudo /opt/ibm-ucd/server/bin/server stop
sudo /opt/IBM/UCRelease/server/server.shutdown
echo "Stopping servers, will wait ${wait_time} for them to finish"
sleep ${wait_time}

# Restore the databases ( Full )
for db in ibm_ucd ibm_ucr
do
  /bin/bash ./restore_db.sh "$db" "${data_dir}"
done

# Restore filesystems

## UCD
dest=/opt/ibm-ucd/server/
for cur_dir in appdata conf
do
  source=${data_dir}/deploy
  sudo rsync -avz --delete ${source}/${cur_dir} ${dest}
done

## UCR
dest=/opt/IBM/UCRelease/ucrelease
source=${data_dir}/release/conf

sudo rsync -avz --delete ${source} ${dest}

# Update 
ucr_config=/opt/IBM/UCRelease/ucrelease/conf/installed.properties
# public.url
# hibernate.connection.url=
# hibernate.connection.username=
# hibernate.connection.password=
# license.server.url=
# may be turn off email in staging ?
# mail.smtp.host=


# Start the servers
sudo /opt/ibm-ucd/server/bin/server start
sudo /opt/IBM/UCRelease/server/server.startup
 

