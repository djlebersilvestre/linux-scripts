#!/bin/bash

add_repo_netflix_desktop() {
  if [ -e "/etc/apt/sources.list.d/pipelight-stable-trusty.list" ]; then
    echo "Netflix repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Netflix Desktop"
    sudo apt-add-repository ppa:pipelight/stable
    should_update_pkgs=true
  fi
}

install_netflix_dependencies() {
  sudo apt-get --purge --reinstall --yes --force-yes install ttf-mscorefonts-installer
}
