#!/bin/sh
# Wrapper around a MySQL db restore

. ../env.sh

db=$1
data_dir=$2

mysql -u ${DB_USER} -p${DB_PASS} ${db} < ${data_dir}/${db}.dump
