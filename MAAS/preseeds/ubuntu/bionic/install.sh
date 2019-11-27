#!/bin/bash
#
#   Installationsscript Ubuntu 18.04
#

HOST=$(hostname | cut -d- -f 1)
NO=$(hostname | cut -d- -f 2)

if      [ -f ${HOST}.sh ]
then
        exec ${HOST}.sh

elif    [ ${HOST} = "docker" ]
then
        bash scripts/docker.sh

elif    [ ${HOST} = "k8sworker" ]
then
        bash scripts/docker.sh
        bash scripts/k8sbase.sh

elif    [ ${HOST} = "k8smaster" ]
then
        bash scripts/docker.sh
        bash scripts/k8sbase.sh
        bash scripts/k8smaster.sh
fi
