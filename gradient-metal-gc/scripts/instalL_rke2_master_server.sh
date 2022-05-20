#!/bin/bash

set -euo pipefail

install_rke2() {
  # Locks RKE2 Release Version
  export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
  SYS_D_SERVICE=rke2-server.service
  CONFIG_PATH=/etc/rancher/rke2/
  CONFIG_FILE=config.yaml
  # Pro Tip: Run as root
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
  fi

  curl -sfL https://get.rke2.io | sh -

mkdir -p ${CONFIG_PATH}

  # ToDo, yaml generators
cat << EOF > ${CONFIG_PATH}/${CONFIG_FILE}
disable:
  - rke2-ingress-nginx
EOF

  echo "Enabling and starting RKE2 Master Daemon"
  systemctl enable ${SYS_D_SERVICE}
  systemctl daemon-reload
  systemctl start ${SYS_D_SERVICE}
  systemctl check rke2-server
}


while getopts ":r:l" option; do
   case $option in
      r) # install remote
         echo "Attempting to install RKE2 master server remotely on host ${OPTARG}"
         nc -zv ${OPTARG} 22 2>&1
         echo "Executing scp ${0} ${OPTARG}:/tmp"
         scp -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${0} ${OPTARG}:/tmp
         echo "Executing ssh -n -t -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${OPTARG} sudo chmod /tmp/${0} && sudo /tmp/${0}"
         ssh -t -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${OPTARG} "sudo chmod +x /tmp/${0} && sudo /tmp/${0} -l"
         exit;;
      l) # install locally
         echo "Attempting to install RKE2 master server locally"
         install_rke2
         exit;;
      *) echo "usage: $0 [-h help] [-r remote install]" >&2
         exit 1;;
   esac
done


# journalctl -u rke2-server -f

# References:
# https://docs.rke2.io/install/install_options/server_config/