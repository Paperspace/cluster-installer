#!/bin/bash

# Locks RKE2 Release Version
export INSTALL_RKE2_VERSION=v1.21.12+rke2r2
SYS_D_SERVICE=rke2-server.service
# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

curl -sfL https://get.rke2.io | sh -

systemctl enable ${SYS_D_SERVICE}
systemctl daemon-reload
systemctl start ${SYS_D_SERVICE}
# journalctl -u rke2-server -f

# References:
# https://docs.rke2.io/install/install_options/server_config/