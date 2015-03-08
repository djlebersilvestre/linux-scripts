#!/bin/bash

add_repo_samsung_tools() {
  if [ -e "/etc/apt/sources.list.d/voria-ppa-trusty.list" ]; then
    echo "Samsung Tools repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Samsung Tools"
    sudo apt-add-repository ppa:voria/ppa
    # TODO: return values from function
    should_update_pkgs=true
  fi
}

