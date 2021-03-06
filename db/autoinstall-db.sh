#!/bin/sh

# xargs to trim
is_standby=`sudo -u postgres psql -t -c "SELECT pg_is_in_recovery();"|xargs`

echo "is_standby=$is_standby"
if [ $is_standby = "t" ]; then
  echo "skipping because is standby"
  exit
fi


export PSQL=psql


# set kloopzcm pass
export PGPASSWORD=kloopzcm

# create schema in the database
$PSQL -U kloopzcm -h localhost -d kloopzdb -f kloopzcm-schema.sql
RETVAL=$?
[ $RETVAL -ne 0 ] && echo create schema failed && exit 1

# create tables in the schema
$PSQL -U kloopzcm -h localhost -d kloopzdb -f kloopzcm-tables.ddl
RETVAL=$?
[ $RETVAL -ne 0 ] && echo create tables failed && exit 1

# create partition tables in the schema
$PSQL -U kloopzcm -h localhost -d kloopzdb -f kloopzcm-partition.ddl
RETVAL=$?
[ $RETVAL -ne 0 ] && echo create partition tables failed && exit 1

$PSQL -U kloopzcm -h localhost -d kloopzdb -f kloopzcm-postprocess.sql
RETVAL=$?
[ $RETVAL -ne 0 ] && echo post process failed && exit 1

$PSQL -U kloopzcm -h localhost -d kloopzdb -f kloopzcm-functions.sql
RETVAL=$?
[ $RETVAL -ne 0 ] && echo functions failed && exit 1

exit 0
