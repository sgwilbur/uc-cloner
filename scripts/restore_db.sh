#!/bin/sh
# db restore

db=$1
data_dir=$2

mysql -u root -proot ${db} < ${data_dir}/${db}.dump
