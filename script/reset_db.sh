#!/bin/sh

rm -rf db/
./script/golf_deploy.pl
if [ -z "$1" ]; then
    echo "loading db.yml"
    kioku load -D 'bdb-gin:dir=db/' --file db.yml
fi