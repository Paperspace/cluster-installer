#!/bin/bash

RKE2_CONTROL_PLANE_HOST=foo
RKE2_CLUSTER_TOKEN=bar

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

systemctl enable rke2-agent.service
mkdir -p /etc/rancher/rke2/

cat << EOF > /etc/rancher/rke2/config.yaml
server: ${RKE2_CONTROL_PLANE_HOST}
token: ${RKE2_CLUSTER_TOKEN}
EOF

systemctl start rke2-agent.service

# Tail daemon logs
# journalctl -u rke2-agent -f