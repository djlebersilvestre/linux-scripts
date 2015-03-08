#!/bin/bash

add_repo_oracle_java() {
  if [ -e "/etc/apt/sources.list.d/webupd8team-java-trusty.list" ]; then
    echo "Oracle Java 8 repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Oracle Java 8"
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    sudo add-apt-repository ppa:webupd8team/java
    should_update_pkgs=true
  fi
}
