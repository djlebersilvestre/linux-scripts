#!/bin/bash

add_repo_google_chrome() {
  if [ -e "/etc/apt/sources.list.d/google.list" ]; then
    echo "Google Chrome repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Google Chrome"
    wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | sudo apt-key add -
    sudo bash -c "echo deb http://dl.google.com/linux/chrome/deb/ stable main >> /etc/apt/sources.list.d/google.list"
    should_update_pkgs=true
  fi
}
