#!/bin/bash


# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
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

  curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE="agent" sh -

  rke2_unit="/usr/local/lib/systemd/system/rke2-agent.service"
  grep -q '^LimitMEMLOCK' "$rke2_unit" && sed -i 's/^LimitMEMLOCK.*/LimitMEMLOCK=infinity/' "$rke2_unit" || echo 'LimitMEMLOCK=infinity' >> "$rke2_unit"

  systemctl enable ${SYS_D_SERVICE}
  systemctl daemon-reload

  # Create Rancher Agent Configuration Directory
  mkdir -p /etc/rancher/rke2/

cat << EOF > ${CONFIG_PATH}
server: https://${RKE2_CONTROL_PLANE_HOST}:9345
token: ${RKE2_CLUSTER_TOKEN}
EOF

  chmod 700 ${CONFIG_PATH}
  systemctl start ${SYS_D_SERVICE}
}


# Tail daemon logs
# journalctl -u rke2-agent -f



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
