#!/bin/bash

dkr_install() {
  if ! type -t update_pkgs | grep -i function > /dev/null; then
    if [ -e "${0%/*}/pkg-helper.sh" ]; then
      source "${0%/*}/pkg-helper.sh"
    else
      source <(curl https://raw.githubusercontent.com/djlebersilvestre/linux-scripts/master/pkg-helper.sh)
    fi
  fi

  update_pkgs
  install_pkgs 'docker.io'
}

dkr_setup() {
  if groups | grep -q docker; then
    echo "Group docker already exists. Skipping."
  else
    sudo groupadd docker
    echo "Group docker created."
  fi

  if groups ${USER} | grep -q docker; then
    echo "${USER} already associated to docker group. Skipping."
  else
    sudo gpasswd -a ${USER} docker
    echo "${USER} associated to docker group."
  fi

  sudo service docker.io restart
  echo "Please log out and log in so the changes can be applied."
  newgrp docker
}
