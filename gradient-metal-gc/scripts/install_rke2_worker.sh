#!/usr/bin/env bash
set -euo pipefail


# Pro Tip: Run as root
if [ "${EUID:-}" -ne 0 ]
  then echo "Please run as root"
  exit
fi

install_rke2() {
  # Locks RKE2 Release Version
  export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
  CONFIG_PATH=/etc/rancher/rke2/config.yaml
  SYS_D_SERVICE=rke2-agent.service

  RKE2_CONTROL_PLANE_HOST=${1}
  RKE2_CLUSTER_TOKEN=${2}
  CLUSTER_DOMAIN=${3}

  curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

  rke2_unit="/usr/local/lib/systemd/system/rke2-agent.service"
  if grep -q '^LimitMEMLOCK' "$rke2_unit"; then
    sed -i 's/^LimitMEMLOCK.*/LimitMEMLOCK=infinity/' "$rke2_unit"
  else
    echo 'LimitMEMLOCK=infinity' >> "$rke2_unit"
  fi

  systemctl enable ${SYS_D_SERVICE}
  systemctl daemon-reload

  # Create Rancher Agent Configuration Directory
  mkdir -p /etc/rancher/rke2/

cat << EOF > ${CONFIG_PATH}
server: https://${RKE2_CONTROL_PLANE_HOST}:9345
token: ${RKE2_CLUSTER_TOKEN}
mirrors:
  docker.io:
    endpoint:
      - "https://docker-registry-mirror.${CLUSTER_DOMAIN}"
EOF

  chmod 700 ${CONFIG_PATH}
  systemctl start ${SYS_D_SERVICE}
}


# Tail daemon logs
# journalctl -u rke2-agent -f


usage() {
  echo "usage: install_rke2_worker.sh <control-plane-host> <cluster-token> <cluster-domain>"
}

CONTROLPLANE_HOST=${1}
if [ -z "${CONTROLPLANE_HOST:-}" ]; then
  usage
  exit 1
fi

CLUSTER_TOKEN=${2}
if [ -z "${CLUSTER_TOKEN:-}" ]; then
  usage
  exit 1
fi

CLUSTER_DOMAIN=${3}
if [ -z "${CLUSTER_DOMAIN:-}" ]; then
  usage
  exit 1
fi

install_rke2 "${CONTROLPLANE_HOST}" "${CLUSTER_TOKEN}" "${CLUSTER_DOMAIN}"
