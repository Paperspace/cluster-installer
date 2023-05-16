#!/bin/bash

set -euo pipefail

LAUNCH_DIR=/opt/cluster
INVENTORY_FILE=inventory.txt

REMOTE_EXEC_SCRIPT="$1"
shift

while IFS= read -r line; do
   echo "Working on host ${line}"
   echo "Executing scp ${REMOTE_EXEC_SCRIPT} ${line}:/tmp"
   s=$(stat ${REMOTE_EXEC_SCRIPT})
   scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${REMOTE_EXEC_SCRIPT} ${line}:/tmp
   REMOTE_SCRIPT_PATH=/tmp/${REMOTE_EXEC_SCRIPT}
   echo "Executing script ${line}${REMOTE_SCRIPT_PATH}"
   ssh -n -t -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${line} "chmod +x ${REMOTE_SCRIPT_PATH} && sudo ${REMOTE_SCRIPT_PATH} $@"
   echo "============"
done <${LAUNCH_DIR}/${INVENTORY_FILE}
