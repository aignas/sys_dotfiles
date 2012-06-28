#!/bin/bash

if [ ! "x${UID}"=="x0" ]; then
   echo 'This script can only be run by root.'
   exit 1
fi

echo "Modules which are going to be rebuilt:"
LIST=`module-rebuild list | sed '/Packages/d' | sed 's/^[\t]*=.\+\///' | sed 's/-[0-9].*//'`
echo "${LIST}"
cd /usr/src
for I in linux-*
do
    if find /lib/modules/ | egrep ${LIST} | grep -q $I; then
        continue
    fi
    echo "Symlinking $I with linux"
    ln -sfn $I linux
    module-rebuild rebuild
done

echo -e "Success"
exit 0
