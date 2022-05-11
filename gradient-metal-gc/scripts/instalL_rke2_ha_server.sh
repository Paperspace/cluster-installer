#!/bin/bash
# HA RKE2 Servers need to join the master pool before it can be considered a "peer"

# Locks RKE2 Release Version
export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
SYS_D_SERVICE=rke2-server.service
CONFIG_PATH=/etc/rancher/rke2/config.yaml

# These variables should be set, after the initial RKE2 master server has been created
RKE2_CONTROL_PLANE_HOST=foo
RKE2_CLUSTER_TOKEN=bar
RKE2_TLS_DOMAIN=("kubernetes.default" "kubernetes.default.svc" "kubernetes.default.svc.cluster.local")

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

curl -sfL https://get.rke2.io | sh -

systemctl enable ${SYS_D_SERVICE}
systemctl daemon-reload
systemctl start ${SYS_D_SERVICE}


# ToDo, yaml generators
cat << EOF > ${CONFIG_PATH}
server: ${RKE2_CONTROL_PLANE_HOST}
token: ${RKE2_CLUSTER_TOKEN}
tls-san:
  - ${RKE2_TLS_DOMAIN[0]}
  - ${RKE2_TLS_DOMAIN[1]}
  - ${RKE2_TLS_DOMAIN[2]}
EOF


# https://docs.rke2.io/install/install_options/server_config/
# journalctl -u rke2-server -f