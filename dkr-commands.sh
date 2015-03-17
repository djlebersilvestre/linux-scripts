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
  sudo groupadd docker || true
  sudo gpasswd -a ${USER} docker || true
  newgrp docker

  echo "Restarting docker service"
  sudo service docker.io restart
  echo "Please log out and log in so the changes can be applied."
}
