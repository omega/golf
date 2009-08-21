#!/bin/sh

DSN=`cat golf.yml golf_local.yml | grep dsn | tail -n 1 | awk '{ print $2 }' | sed 's/"//g'`
DIR=` cat golf.yml golf_local.yml | grep dsn | tail -n 1 | awk '{ print $2 }' | sed 's/bdb-gin:dir=//' | sed 's/"//g'`
echo "reseting : $DSN in $DIR"

rm -rf $DIR
./script/golf_deploy.pl
if [ -z "$1" ]; then
    echo "loading db.yml"
    kioku load -D $DSN --file db.yml
fi