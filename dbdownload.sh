#!/bin/bash
set -e
var_path_conf=$2
CONF="${var_path_conf}dbdownload.${1}.conf"
OPTIONS="" # --ignore-table=default.search_statistics
if [ ! -f "$CONF" ]; then
  echo "$CONF not found"
  exit 4
fi
. $CONF
printf "%28s %s\n" var_ssh_host: $var_ssh_host
printf "%28s %s\n" var_mysql_database_host: $var_mysql_database_host
printf "%28s %s\n" var_mysql_database_name: $var_mysql_database_name
printf "%28s %s\n" var_mysql_database_user: $var_mysql_database_user
printf "%28s %s\n" var_mysql_database_password: $var_mysql_database_password
printf "%28s %s\n" var_mysql_options: $var_mysql_options # --ignore-table=default.search_statistics
# usage as follows
# && mysqldump -h"${var_mysql_database_host}" -u"${var_mysql_database_user}" -p"${var_mysql_database_password}" "${var_mysql_database_name}" "${var_mysql_options}" | gzip > "${dir_remote_tmp}/${var_remote_filename}.dumping" \
var_timestamp=$(date +%s)
#var_date=$(date '+%Y%m%d.%H%M%S')
var_date=$(date '+%Y%m%d')
var_remote_filename="${var_date}.${var_mysql_database_name}.sql.gz"
var_local_filename="${var_date}.${var_ssh_host}.${var_mysql_database_name}.sql.gz"
dir_remote_tmp='tmp'
dir_local_tmp=tmp/download
if [ -z "$var_mysql_options" ]
then
  echo "\$var_mysql_options not set"
else
  var_mysql_database_name="$var_mysql_database_name $var_mysql_options"
fi

#echo 'test'
#echo mysqldump -h"${var_mysql_database_host}" -u"'""${var_mysql_database_user}""'" -p"'""${var_mysql_database_password}""'" $var_mysql_database_name
#exit 0

#cat << HERE
#  mkdir -p "${dir_remote_tmp}" \
#  && touch "${dir_remote_tmp}/${var_remote_filename}.dumping" \
#  && mysqldump -h"${var_mysql_database_host}" -u"${var_mysql_database_user}" -p'${var_mysql_database_password}' $var_mysql_database_name | gzip > "${dir_remote_tmp}/${var_remote_filename}.dumping" \
#  && mv "${dir_remote_tmp}/${var_remote_filename}.dumping" "${dir_remote_tmp}/${var_remote_filename}.downloading"
#HERE
#exit 0

mkdir -p "${dir_local_tmp}"
ssh -q $var_ssh_host << HERE
  mkdir -p "${dir_remote_tmp}" \
  && touch "${dir_remote_tmp}/${var_remote_filename}.dumping" \
  && echo mysqldump -h"${var_mysql_database_host}" -u"${var_mysql_database_user}" -p'${var_mysql_database_password}' $var_mysql_database_name \
  && mysqldump -h"${var_mysql_database_host}" -u"${var_mysql_database_user}" -p'${var_mysql_database_password}' $var_mysql_database_name | gzip > "${dir_remote_tmp}/${var_remote_filename}.dumping" \
  && mv "${dir_remote_tmp}/${var_remote_filename}.dumping" "${dir_remote_tmp}/${var_remote_filename}.downloading"
HERE
scp "${var_ssh_host}":"${dir_remote_tmp}/${var_remote_filename}.downloading" "${dir_local_tmp}/${var_local_filename}"
ssh -q $var_ssh_host << HERE
  mv "${dir_remote_tmp}/${var_remote_filename}.downloading" "${dir_remote_tmp}/${var_remote_filename}.delete" \
  && rm $dir_remote_tmp/*.delete
HERE
