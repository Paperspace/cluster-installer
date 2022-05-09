#!/bin/bash

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

curl -sfL https://get.rke2.io | sh -

systemctl enable rke2-server.service

systemctl start rke2-server.service
# https://docs.rke2.io/install/install_options/server_config/
# journalctl -u rke2-server -f