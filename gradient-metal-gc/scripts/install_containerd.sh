#!/bin/bash

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function install_container_d_kube_reqs() {
  cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

  modprobe overlay
  modprobe br_netfilter

  # Setup required sysctl params, these persist across reboots.
  cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

  sysctl --system
}

function install_container_d_sys_d() {
  if [[ $(stat /etc/systemd/system/containerd.service) ]]; then
    printf "Containerd is already installed\n"
    return 0
  fi
  CONTAINER_D_VERSION=1.6.1
  CD_DL_SUFFIX=v${CONTAINER_D_VERSION}/cri-containerd-cni-${CONTAINER_D_VERSION}-linux-amd64.tar.gz
  DOWNLOAD_DIR=/tmp
  CONTAINER_D_ARTIFACT=containerd.tar.gz
  DL_URL=https://github.com/containerd/containerd/releases/download/${CD_DL_SUFFIX}
  printf "Downlading from URL [%s]\n" "${DL_URL}"
  wget -q -O ${DOWNLOAD_DIR}/${CONTAINER_D_ARTIFACT} ${DL_URL}
  tar --no-overwrite-dir -C / -xzf ${DOWNLOAD_DIR}/${CONTAINER_D_ARTIFACT}
  printf "Reloading the Systemd Daemon\n"
  systemctl daemon-reload
  systemctl enable --now containerd
}

function install_container_d_deps() {

 if [[ ! -d /etc/containerd/ ]]; then
   printf "/etc/containerd does not exist, creating it\n"
   mkdir -p /etc/containerd
   containerd config default > /etc/containerd/config.toml
 fi

 printf "Enabling SystemDCgroups\n"
 sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
 if [[ ! $(grep "https://mirror.gcr.io" /etc/containerd/config.toml) ]]; then
  awk '/plugins."io.containerd.grpc.v1.cri".registry.mirrors/ { print; print "        \[plugins.\"io.containerd.grpc.v1.cri\".registry.mirrors.\"gcr.io\"\]"; print "          endpoint = \[\"https://mirror.gcr.io\"\]"; next }1' /etc/containerd/config.toml \
 > /tmp/config.toml
 mv /tmp/config.toml /etc/containerd/config.toml
 fi
 systemctl restart containerd
}

install_container_d_kube_reqs
install_container_d_sys_d
install_container_d_deps