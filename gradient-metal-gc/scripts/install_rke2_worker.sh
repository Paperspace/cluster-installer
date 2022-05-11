#!/bin/bash

# Locks RKE2 Release Version
export INSTALL_RKE2_VERSION=v1.21.12+rke2r2

#
RKE2_CONTROL_PLANE_HOST=foo
RKE2_CLUSTER_TOKEN=bar
CONFIG_PATH=/etc/rancher/rke2/config.yaml
SYS_D_SERVICE=rke2-agent.service

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable ${SYS_D_SERVICE}
systemctl daemon-reload

# Create Rancher Agent Configuration Directory
mkdir -p /etc/rancher/rke2/

cat << EOF > ${CONFIG_PATH}
server: ${RKE2_CONTROL_PLANE_HOST}
token: ${RKE2_CLUSTER_TOKEN}
EOF

chmod 700 ${CONFIG_PATH}
systemctl start ${SYS_D_SERVICE}

# Tail daemon logs
# journalctl -u rke2-agent -f