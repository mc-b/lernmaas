#!/bin/bash
#
#       Kopiert die Container Images von einer VM in den Container Cache
#

[ $# -lt 2 ] && { echo ccopy dir ip-vm; exit 1; }

cd $1

for i in $(ssh $2 docker images | cut -d ' ' -f 1 | grep -v REPOSITORY )
do
        ssh $2 docker save $i | cat - >$(echo $i | tr / _).tar
done
