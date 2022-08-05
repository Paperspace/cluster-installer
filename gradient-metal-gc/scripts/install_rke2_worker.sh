#!/usr/bin/env bash
set -euo pipefail
set -x


# Pro Tip: Run as root
if [ "${EUID:-}" -ne 0 ]
  then echo "Please run as root"
  exit
fi

install_estargz() {
  arch="amd64"
  version="v0.12.0"

  apt-get install fuse
  modprobe fuse
  tar_file="stargz-snapshotter-${version}-linux-${arch}.tar.gz"
  wget -O "${tar_file}" "https://github.com/containerd/stargz-snapshotter/releases/download/${version}/${tar_file}"
  tar -C /usr/local/bin -xvf "$tar_file" stargz-snapshotter
  wget -O /etc/systemd/system/stargz-snapshotter.service https://raw.githubusercontent.com/containerd/stargz-snapshotter/main/script/config/etc/systemd/system/stargz-snapshotter.service
  systemctl disable stargz-store
  systemctl enable --now stargz-snapshotter

  ESTARGZ_CONFIG="/etc/containerd-stargz-grpc/config.toml"
  mkdir -p "$(dirname "${ESTARGZ_CONFIG}")"
  cat <<EOF > "${ESTARGZ_CONFIG}"
# Append configurations for Stargz Snapshotter in TOML format.

# Enables CRI-based keychain
# Stargz Snapshotter works as a proxy of CRI.
# kubelet MUST listen stargz snapshotter's socket (unix:///run/containerd-stargz-grpc/containerd-stargz-grpc.sock)
# instead of containerd for image service.
# i.e. add `--image-service-endpoint=unix:///run/containerd-stargz-grpc/containerd-stargz-grpc.sock` option to kubelet.
[cri_keychain]
enable_keychain = true
image_service_path = "/run/k3s/containerd/containerd.sock"
EOF

  CONTAINERD_CONFIG=/var/lib/rancher/rke2/agent/etc/containerd/config.toml.tmpl
  cat <<EOF > "${CONTAINERD_CONFIG}"
version = 2

# Plug stargz snapshotter into containerd
# Containerd recognizes stargz snapshotter through specified socket address.
# The specified address below is the default which stargz snapshotter listen to.
[proxy_plugins]
  [proxy_plugins.stargz]
    type = "snapshot"
    address = "/run/containerd-stargz-grpc/containerd-stargz-grpc.sock"

# Use stargz snapshotter through CRI
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "stargz"
  disable_snapshot_annotations = false
EOF

#  CONTAINER_STORAGE=/etc/containers/storage.conf
#  cat <<EOF > "${CONTAINER_STORAGE}"
#[storage]
#driver = "overlay"
#graphroot = "/var/lib/containers/storage"
#runroot = "/run/containers/storage"
#
#[storage.options]
#additionallayerstores = ["/var/lib/stargz-store/store:ref"]
#EOF
}

install_rke2() {
  # Locks RKE2 Release Version
  export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
  CONFIG_PATH=/etc/rancher/rke2/
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
  install_estargz

  cat << EOF > "${CONFIG_PATH}/config.yaml"
server: https://${RKE2_CONTROL_PLANE_HOST}:9345
token: ${RKE2_CLUSTER_TOKEN}
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
