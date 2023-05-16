#!/bin/bash

set -euo pipefail

LAUNCH_DIR=/opt/cluster
INVENTORY_FILE=inventory.txt

REMOTE_EXEC_SCRIPT=${1}

while IFS= read -r line; do
   echo "Working on host ${line}"
   echo "Executing scp ${REMOTE_EXEC_SCRIPT} ${line}:/tmp"
   s=$(stat ${REMOTE_EXEC_SCRIPT})
   scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_EXEC_SCRIPT} ${line}:/tmp
   echo "============"
done <${LAUNCH_DIR}/${INVENTORY_FILE}
