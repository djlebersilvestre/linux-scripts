#!/bin/bash

RETVAL=0

ssd_step() {
  scriptPath=${0%/*}
  source $scriptPath/swap-ssd-optimization.sh all
}


is_copy_working() {
  if [ ! -d "$HOME/Copy" ] || [ ! -d "$HOME/Copy/ssh" ] || [ ! -d "$HOME/Copy/ssh/vpn" ]; then
    return 1
  else
    return 0
  fi
}

check_copy() {
  if ! is_copy_working; then
    echo "The Copy (cloud storage) is not configured or initialized. Aborting the process"
    exit 1
  fi
}

update_pkgs() {
  force_update=$1

  if [ "$force_update" = true ] || [ "$PROV_APT_UPDATED" != true ]; then
    echo "Atualizando lista de pacotes"
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

first_step() {
  if [ "$PROV_FIRST_ROOT_PASS" = true ]; then
    echo "The root password has already been set"
  else
    exit_code=1
    while [ $exit_code != 0 ]; do
      echo "Please, set up your new root password"
      sudo passwd root
      exit_code=$?
    done

    export PROV_FIRST_ROOT_PASS=true
    echo 'export PROV_FIRST_ROOT_PASS=true' >> ~/.bashrc
  fi

  if [ "$PROV_FIRST_UPDATE" = true ]; then
    echo "The packages are up to date"
  else
    echo "First time running this script. Updating all packages"
    sudo apt-get update
    sudo apt-get --yes --force-yes upgrade

    export PROV_FIRST_UPDATE=true
    echo 'export PROV_FIRST_UPDATE=true' >> ~/.bashrc

    echo "Rebooting to apply all updates"
    sudo reboot
  fi
}

git_step() {
  echo "Updating and installing git"
  install_pkgs 'git meld gitk'

  echo "Configuring git"
  sudo rm -f /usr/local/bin/git-diff.sh
  echo '#!/bin/bash' >> git-diff.sh
  echo 'meld "$2" "$5" > /dev/null 2>&1' >> git-diff.sh
  sudo mv git-diff.sh /usr/local/bin/
  sudo chmod +x /usr/local/bin/git-diff.sh

  rm -f ~/.gitconfig
  git config --global user.name "Daniel Silvestre"
  git config --global user.email djlebersilvestre@gmail.com
  git config --global credential.helper cache
  git config --global credential.helper 'cache --timeout=3600'
  git config --global color.ui true
  git config --global diff.external /usr/local/bin/git-diff.sh

  echo "Configuring bash and vimrc"
  git clone git@github.com:djlebersilvestre/vim.git ~/.vim
  git clone git@github.com:djlebersilvestre/bash.git ~/.bash
  rm -f ~/.bashrc ~/.bash_profile ~/.profile ~/.vimrc
  ln -s ~/.bash/bashrc ~/.bashrc
  ln -s ~/.bash/bash_profile ~/.bash_profile
  ln -s ~/.vim/vimrc ~/.vimrc
}

ssh_step() {
  check_copy

  echo "Copying ssh keys and configuring at home directory"
  mkdir -p ~/.ssh
  cp -R ~/Copy/ssh/* ~/.ssh
  chmod 600 ~/.ssh/vpn/*
  chmod 600 ~/.ssh/*
  chmod 700 ~/.ssh/vpn/
}

packages_step() {
  should_update_pkgs=false

  if [ -e "/etc/apt/sources.list.d/pipelight-stable-trusty.list" ]; then
    echo "Netflix repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Netflix Desktop"
    sudo apt-add-repository ppa:pipelight/stable
    should_update_pkgs=true
  fi

  if [ -e "/etc/apt/sources.list.d/google.list" ]; then
    echo "Google Chrome repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Google Chrome"
    wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | sudo apt-key add -
    sudo bash -c "echo deb http://dl.google.com/linux/chrome/deb/ stable main >> /etc/apt/sources.list.d/google.list"
    should_update_pkgs=true
  fi

  if [ -e "/etc/apt/sources.list.d/webupd8team-java-trusty.list" ]; then
    echo "Oracle Java 8 repository already exists. Bypassing this install"
  else
    echo "Adding repository to install Oracle Java 8"
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
    sudo add-apt-repository ppa:webupd8team/java
    should_update_pkgs=true
  fi

  if [ -e "/lib/x86_64-linux-gnu/libudev.so.0" ]; then
    echo "Lib already linked, bypassing PopcornTime fix"
  else
    echo "Applying PopcornTime fix"
    sudo ln -s /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0
  fi

  if $should_update_pkgs; then
    update_pkgs true
  fi

  echo "Updating and installing all desired packages"
  install_pkgs 'vim apache2-utils xbacklight curl screen htop pdfshuffler gimp google-chrome-stable netflix-desktop whois oracle-java8-installer docker.io'
  # standing by: powertop radiotray filezilla https://code.google.com/p/gitinspector/downloads/list
  # TODO: http://download.skype.com/linux/skype-ubuntu-precise_4.3.0.37-1_i386.deb
  # TODO: http://remarkableapp.net/files/remarkable_1.25_all.deb

  # Dependencies for Netflix
  sudo apt-get --purge --reinstall --yes --force-yes install ttf-mscorefonts-installer

  echo "Do not forget to:"
  echo " - Setup into Startup Applications the brightness of the display (/usr/bin/xbacklight -set 70)"
  echo " - Run Netflix for the first time to setup account and password"
  echo " - Add apps into the launcher: Chrome, Netflix"
}

copy_step() {
  if ! is_copy_working; then
    echo "Installing Copy (cloud storage)"

    cd ~
    rm -f ~/Copy.tg*
    wget https://copy.com/install/linux/Copy.tgz

    tar xvzf Copy.tgz
    mv ~/copy/ ~/.copy

    .copy/x86_64/CopyAgent
    rm ~/Copy.tgz
  else
    echo "Copy is already installed"
  fi
}

rvm_step() {
  echo "Installing rvm"
  gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
  \curl -sSL https://get.rvm.io | bash -s stable
  rm -f ~/.profile
  source ~/.bash_profile
  type rvm | head -n 1
  rvm install 2.2.1
  rvm use 2.2.1 --default

  #TODO: check if it is already updated
  echo "Installing vim plugins"
  cd ~/.vim/
  chmod +x update_bundles
  ./update_bundles
}

virtualbox_step() {
  if grep -q "download.virtualbox.org" /etc/apt/sources.list; then
    echo "VirtualBox repository already exists. Bypassing this install"
  else
    echo "Adding repository to install VirtualBox"
    wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
    sudo bash -c "echo deb http://download.virtualbox.org/virtualbox/debian trusty contrib >> /etc/apt/sources.list"
  fi

  install_pkgs 'virtualbox-4.3'

  echo "Downloading VirtualBox Extension Pack"
  #TODO: auto find the version
  VBOX_EXT_PATH=4.3.24
  VBOX_EXT_BUILD=98716
  VBOX_EXT_VERSION=Oracle_VM_VirtualBox_Extension_Pack-$VBOX_EXT_PATH-$VBOX_EXT_BUILD.vbox-extpack

  cd ~
  wget http://download.virtualbox.org/virtualbox/$VBOX_EXT_PATH/$VBOX_EXT_VERSION

  echo "Now you must setup VirtualBox (install the additionals in $HOME/$VBOX_EXT_VERSION and import the base VMs)..."
  /usr/bin/virtualbox

  rm $VBOX_EXT_VERSION
}

vagrant_step() {
  echo "Run this script only after VirtualBox setup. It will install Vagrant"

  #TODO: auto find the version
  VAGRANT_VERSION=vagrant_1.7.2_x86_64.deb

  cd ~
  wget https://dl.bintray.com/mitchellh/vagrant/$VAGRANT_VERSION
  sudo dpkg -i ~/$VAGRANT_VERSION

  rm ~/$VAGRANT_VERSION
  VBOX_DIR=$HOME/Copy/vbox/
  cd $VBOX_DIR

  if [ -d "$VBOX_DIR/debian_7.0.0-amd64-base/" ] && [ -e "$VBOX_DIR/debian-wheezy-amd64-base.box" ]; then
    vagrant box add debian-wheezy-amd64-base debian-wheezy-amd64-base.box
  fi
}

case "$1" in
  first)
    first_step
    ;;
  git)
    git_step
    ;;
  packages)
    packages_step
    ;;
  copy)
    copy_step
    ;;
  ssh)
    ssh_step
    ;;
  rvm)
    rvm_step
    ;;
  ssd)
    ssd_step
    ;;
  virtualbox)
    virtualbox_step
    ;;
  vagrant)
    vagrant_step
    ;;
  setup)
    STEPS_NUM=6
    echo "Step 1 / $STEPS_NUM"
    first_step
    echo "Step 2 / $STEPS_NUM"
    git_step
    echo "Step 3 / $STEPS_NUM"
    packages_step
    echo "Step 4 / $STEPS_NUM"
    copy_step
    echo "Step 5 / $STEPS_NUM"
    ssh_step
    echo "Step 6 / $STEPS_NUM"
    rvm_step
    #virtualbox_step
    #vagrant_step
    echo "Finished all steps!"
    ;;
  *)
    echo "Usage: $0 {setup|first|git|packages|copy|ssh|rvm|ssd|virtualbox|vagrant}"
    echo ""
    echo "Details"
    echo "  setup:      RECOMMENDED - triggers all: first > packages > git > copy > ssh > rvm > virtualbox > vagrant"
    echo "  first:      first update on packages and setup of root password"
    echo "  git:        configure git, merger and installs the default bash and vim scripts"
    echo "  packages:   install all basic packages such as vim, screen and so on"
    echo "  copy:       install and setup the Copy Cloud Storage"
    echo "  ssh:        configure default SSH keys (depends on Copy)"
    echo "  rvm:        install and set rvm to use ruby, also updates the vim bundles"
    echo "  ssd:        applies SSD optimization - no swapping, logs in memory and no update on reading files"
    echo "  virtualbox: install VirtualBox (requires manual steps)"
    echo "  vagrant:    install vagrant"
    echo ""
    RETVAL=1
esac

#TODO: divide this script in multiple files (similar to SSD)
#TODO: use set -e to control the flow on errors (similar to SSD

exit $RETVAL

