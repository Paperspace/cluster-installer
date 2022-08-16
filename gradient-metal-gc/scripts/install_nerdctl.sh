#!/bin/bash

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

function install_nerdctl(){
  VERSION=0.19.0
  VVERSION=v${VERSION}
  DOWNLOAD_DIR=/tmp
  ARTIFACT=nerdctl.download
  DL_URL=https://github.com/containerd/nerdctl/releases/download/${VVERSION}/nerdctl-${VERSION}-linux-amd64.tar.gz
  printf "Downlading from URL [%s]\n" "${DL_URL}"
  wget -q -O ${DOWNLOAD_DIR}/${ARTIFACT} "${DL_URL}"
  tar --no-overwrite-dir -C /usr/local/bin -xzf ${DOWNLOAD_DIR}/${ARTIFACT}
}

install_nerdctl