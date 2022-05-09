#!/bin/bash

"""
Usage get_rke2_master_token.sh {{ ip or host name of RKE2 master}}
assumed ssh forwarding
"""

MASTER_SERVER=${1}
if [ -z "${MASTER_SERVER}" ]; then
  printf "RKE Master Cannot Be Null\n"
  exit 1
fi

TOKEN_PATH=/var/lib/rancher/rke2/server/node-token
MASTER_TOKEN=$(ssh -t -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${MASTER_SERVER}" "sudo cat ${TOKEN_PATH}")

echo "${MASTER_TOKEN}"