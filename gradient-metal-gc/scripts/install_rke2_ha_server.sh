#!/bin/bash
# HA RKE2 Servers need to join the master pool before it can be considered a "peer"

install_rke2() {
# Locks RKE2 Release Version
export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
SYS_D_SERVICE=rke2-server.service
CONFIG_PATH=/etc/rancher/rke2/config.yaml

# These variables should be set, after the initial RKE2 master server has been created
RKE2_CONTROL_PLANE_HOST=${1}
RKE2_CLUSTER_TOKEN=${2}
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
server: https://${RKE2_CONTROL_PLANE_HOST}:9345
token: ${RKE2_CLUSTER_TOKEN}
tls-san:
  - kubernetes.local.com
disable:
  - rke2-ingress-nginx
EOF
}

# https://docs.rke2.io/install/install_options/server_config/
# journalctl -u rke2-server -f

MASTER_SERVER=${1}
if [ -z "${MASTER_SERVER}" ]; then
  printf "MASTER_SERVER Cannot Be Null"
  exit 1
fi

CLUSTER_TOKEN=${2}
if [ -z "${CLUSTER_TOKEN}" ]; then
  printf "CLUSTER_TOKEN Cannot Be Null\n"
  exit 1
fi


install_rke2 "${MASTER_SERVER}" "${CLUSTER_TOKEN}"