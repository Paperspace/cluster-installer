#!/bin/bash

FLAG_CREATE_KEYS="${1:-0}"

# Pro Tip: Run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

p_user=upaperspace
p_group=gpaperspace

if [[ ! $(id "${p_user}") ]]; then
    printf 'Creating %s user\n', ${p_user}
    useradd ${p_user}
fi

if [[ ! $(getent group "${p_group}") ]]; then
    printf 'Creating %s group\n', ${p_group}
    groupadd ${p_group}
fi

usermod -a -G ${p_group} ${p_user}

p_sudoers_file_sudoers_file=/etc/sudoers.d/100-paperspaced
if [[ ! $(stat ${p_sudoers_file_sudoers_file}) ]]; then
  printf 'Creating paperspace group sudoers file at [%s]\n', ${p_sudoers_file_sudoers_file}
  echo "%${p_group} ALL=(ALL) NOPASSWD:ALL" > ${p_sudoers_file_sudoers_file}
fi

chsh -s /bin/bash ${p_user}

if [ "${FLAG_CREATE_KEYS}" -eq 1 ] ; then
  ssh-keygen -t rsa -N "" -f clustercreds.key
  mkdir -p ~/.ssh
  chown ${p_user} ~
  mv ./clustercreds.key ~/.ssh/id_rsa
  stat ./clustercreds.key.pub
else
  printf 'Not creating ssh keys this execution\n'
fi

printf 'User setup complete\n'