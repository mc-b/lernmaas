#!/bin/bash
#
#   Exportiert VM Name und IP-Adresse ins CSV Format, z.B. um es mit Excel weiterverarbeiten zu koennen.
#

maas $PROFILE machines read | jq -r ".[] | select (.pool.name==\"$1\") | [.hostname, .ip_addresses] | flatten | @csv " | sort

