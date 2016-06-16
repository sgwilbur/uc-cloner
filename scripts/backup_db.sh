#!/bin/sh

. ../env.sh

db=$1
data_dir=$2

mysqldump -u ${DB_USER} -p${DB_PASS} ${db} > ${data_dir}/${db}.dump
