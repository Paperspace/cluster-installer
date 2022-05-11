#!/bin/bash
# ToDo, revise this as RKE2 does its own containerd wrangling

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

containerd_user=containerd
containerd_group=containerd

if [[ ! $(id "${containerd_user}") ]]; then
    printf 'Creating %s user\n', ${containerd_user}
    useradd ${containerd_user}
fi

if [[ ! $(getent group "${containerd_group}") ]]; then
    printf 'Creating %s group\n', ${containerd_group}
    groupadd ${containerd_group}
fi

containerd_sudoers_file=/etc/sudoers.d/100-containerd
if [[ ! $(stat ${containerd_sudoers_file}) ]]; then
  printf 'Creating conatinerd group sudoers file at [%s]\n', ${containerd_sudoers_file}
  echo "%${containerd_group} ALL=(ALL) NOPASSWD:ALL" > ${containerd_sudoers_file}
fi
