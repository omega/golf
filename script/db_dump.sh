#!/bin/sh
FILE=db.yml
if [ -n "$1" ]; then
    FILE=$1
fi
perl -MDateTime::Format::Strptime `which kioku` dump -D 'bdb-gin:dir=db/' --file $FILE --force
