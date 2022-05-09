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
   --cluster-cidr value                          (networking) IPv4/IPv6 network CIDRs to use for pod IPs (default: 10.42.0.0/16)
   --service-cidr value
#journalctl -u rke2-server -f