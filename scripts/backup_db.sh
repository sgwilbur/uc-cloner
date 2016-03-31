#!/bin/sh

db=$1
data_dir=$2

mysqldump -u root -proot ${db} > ${data_dir}/${db}.dump
