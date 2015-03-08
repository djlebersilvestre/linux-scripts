#!/bin/bash

update_pkgs() {
  force_update=$1

  if [ "$force_update" == "-f" ] || [ "$PROV_APT_UPDATED" != true ]; then
    echo "Updating packages list"
    sudo apt-get update
    export PROV_APT_UPDATED=true
  fi
}

install_pkgs() {
  pkgs=$1

  if [ -z "$pkgs" ]; then
    echo "The packages must be passed as argument, separated by spaces to proceed with the installation"
    exit 1
  fi

  update_pkgs

  echo "Installing packages $pkgs"
  sudo apt-get --yes --force-yes install $pkgs
}
