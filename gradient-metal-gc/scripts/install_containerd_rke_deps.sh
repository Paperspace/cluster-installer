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

  modprobe overlay -v
  modprobe br_netfilter -v

  # Setup required sysctl params, these persist across reboots.
  cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

  sysctl --system
}

install_container_d_kube_reqs