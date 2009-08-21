#!/bin/sh

DSN=`cat golf.yml golf_local.yml | grep dsn | tail -n 1 | awk '{ print $2 }' | sed 's/"//g'`

FILE=db.yml
if [ -n "$1" ]; then
    FILE=$1
fi
perl -MDateTime::Format::Strptime `which kioku` dump -D $DSN --file $FILE --force
