#!/bin/bash

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


sudo apt-get update
sudo apt-get install -y nfs-common nfs-kernel-server
