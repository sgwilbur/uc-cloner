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

## Config updates on filesystem
## /opt/ibm-ucd/server/conf/server/installed.properties

# hibernate.connection.url=jdbc\:mysql\://uc1\:3306/ibm_ucd
# hibernate.connection.username=ibm_uc
# hibernate.connection.password=pbe{KFaeen9jelj6cUBKznHbXaaWzCRnCRHdBfViGcGemxQ\=}

# install.server.web.host=uc1.prod
# server.external.web.url=https\://uc1\:443

## After startup
## System Settings
# Home > Settings > System
# External Agent URL
# External User URL
# Disable email if enabled
# Accessible via /rest/system/configuration
# https://www.ibm.com/support/knowledgecenter/SS4GSP_6.1.0/com.ibm.udeploy.api.doc/topics/rest_cli_systemconfiguration.html


## UCR
dest=/opt/IBM/UCRelease/ucrelease
source=${data_dir}/release/conf

sudo rsync -avz --delete ${source} ${dest}

# Update configurations on filesystem
ucr_config=/opt/IBM/UCRelease/ucrelease/conf/installed.properties

# public.url=https\://uc1.prod\:8443/
# hibernate.connection.password=pbe{flRLbyNjNV/8Z+ty0ViKSgXtc9AAfxKB9K7k1Q1oBXY\=}
# hibernate.connection.url=jdbc\:mysql\://localhost\:3306/ibm_ucr
# hibernate.connection.username=ibm_uc
# license.server.url=27000@localhost
# may be turn off email in staging ?
# mail.smtp.host=

# update in database
# Disable ucr integration
# tables ur_integration_provider
# select id, name, prop_sheet_id from ur_integration_provider where name = "uc1.prod";
# this will give you the integration id
# from the prop_sheet_id you can find your properties
# update your url property

echo "1. File and db restore is complete."

echo "2. Run the SQL against ibm_ucr"
echo <<EOI
update ur_integration_provider
  set name = 'uc2'
  where id = '160c1ec6-14da-4e90-8918-170240e11e6f'
  ;

# disable the integration
# update ur_integration_provider
#  set frequency = '0'
#  where id = '160c1ec6-14da-4e90-8918-170240e11e6f'
#  ;
# or just update the value
 update ps_prop_value
  set value = 'https://uc2'
  where id = '3f1b2e4e-b4fe-4717-bfb1-f4f0c5d6259f'
 ;
EOI

echo " 3. Run the configuration file replacement."
read -p "Press [Enter] when you are ready to restart the servers..."

# Start the servers
sudo /opt/ibm-ucd/server/bin/server start
sudo /opt/IBM/UCRelease/server/server.startup
