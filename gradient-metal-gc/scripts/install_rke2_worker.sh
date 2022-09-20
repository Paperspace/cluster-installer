#!/usr/bin/env bash
set -euo pipefail

# Pro Tip: Run as root
if [ "${EUID:-}" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

setup_cgroups() {
  mkdir -p /sys/fs/cgroup/pids/podruntime.slice
  mkdir -p /sys/fs/cgroup/hugetlb/podruntime.slice
  mkdir -p /sys/fs/cgroup/cpuset/podruntime.slice
  mkdir -p /sys/fs/cgroup/cpu/podruntime.slice
  mkdir -p /sys/fs/cgroup/memory/podruntime.slice
  mkdir -p /sys/fs/cgroup/systemd/podruntime.slice
}

setup_mounts() {
  containerd_data='/var/lib/docker/containerd'
  containerd='/var/lib/rancher/rke2/agent/containerd'

  mkdir -p "$containerd_data"
  mkdir -p "$containerd"

  grep -q 'containerd-data' /etc/fstab || \
    printf "# containerd-data\n%s    %s    none    defaults,bind    0    2\n" \
      "$containerd_data" \
      "$containerd" \
      >> /etc/fstab

  mount -a
}

install_rke2() {
  # Locks RKE2 Release Version
  export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
  CONFIG_PATH=/etc/rancher/rke2/
  SYS_D_SERVICE=rke2-agent.service

  RKE2_CONTROL_PLANE_HOST=${1}
  RKE2_CLUSTER_TOKEN=${2}
  CLUSTER_DOMAIN=${3}
  POOL_NAME=${4}

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

  cat << EOF > "${CONFIG_PATH}/config.yaml"
server: https://${RKE2_CONTROL_PLANE_HOST}:9345
token: ${RKE2_CLUSTER_TOKEN}
kubelet-arg:
  - kube-reserved="cpu=500m,memory=256Mi,ephemeral-storage=10Gi"
  - kube-reserved-cgroup=/podruntime.slice
  - system-reserved=cpu=500m,memory=256Mi,ephemeral-storage=5Gi
  - system-reserved-cgroup=/system.slice
node-label:
  - paperspace.com/pool-name=${POOL_NAME}
EOF

  cat <<EOF > "${CONFIG_PATH}/registries.yaml"
mirrors:
  docker.io:
    endpoint:
      - "https://container-registry-mirror.${CLUSTER_DOMAIN}"
      - "https://index.docker.io"
EOF

  chmod 700 ${CONFIG_PATH}
  systemctl start ${SYS_D_SERVICE}
}


# Tail daemon logs
# journalctl -u rke2-agent -f


usage() {
  echo "usage: install_rke2_worker.sh <control-plane-host> <cluster-token> <cluster-domain> <pool-name>"
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

POOL_NAME=${4}
if [ -z "${POOL_NAME:-}" ]; then
  usage
  exit 1
fi

setup_mounts
setup_cgroups
install_rke2 "${CONTROLPLANE_HOST}" "${CLUSTER_TOKEN}" "${CLUSTER_DOMAIN}" "${POOL_NAME}"
