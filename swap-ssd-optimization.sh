#!/bin/bash

setup_sysctl() {
  set -e
  if grep --quiet vm.swappiness=0 /etc/sysctl.conf; then
    echo No changes. Sysctl is already adjusted to keep swap at zero
  else
    sudo bash -c "sudo echo '' >> /etc/sysctl.conf"
    sudo bash -c "echo '# Forcing no swap to preserve the SSD storage' >> /etc/sysctl.conf"
    sudo bash -c "echo vm.swappiness=0 >> /etc/sysctl.conf"

    echo Sysctl adjusted to keep swap at zero
  fi
  set +e
}

setup_fstab() {
  set -e
  if grep --quiet "# SSD optimization" /etc/fstab; then
    echo No changes. Fstab is already adjusted to keep logs in memory
  else
    sudo bash -c "echo '' >> /etc/fstab"
    sudo bash -c "echo '# SSD optimization - log everything into RAM memory'        >> /etc/fstab"
    sudo bash -c "echo tmpfs   /tmp       tmpfs   defaults,noatime,mode=1777   0  0 >> /etc/fstab"
    sudo bash -c "echo tmpfs   /var/spool tmpfs   defaults,noatime,mode=1777   0  0 >> /etc/fstab"
    sudo bash -c "echo tmpfs   /var/tmp   tmpfs   defaults,noatime,mode=1777   0  0 >> /etc/fstab"
    sudo bash -c "echo tmpfs   /var/log   tmpfs   defaults,noatime,mode=0755   0  0 >> /etc/fstab"

    echo Fstab adjusted to keep logs in memory
    echo Do not forget to put noatime... in root ext4 mountpoint. This will avoid updating read access tag of files. Example:
    echo UUID=f67e5b44-423e-402c-8236-497d2ecc4f61 /               ext4    noatime,nodiratime,discard,errors=remount-ro 0       1
  fi
  set +e
}

case "$1" in
  sysctl)
    setup_sysctl
    ;;
  fstab)
    setup_fstab
    ;;
  all)
    setup_sysctl
    setup_fstab
    ;;
esac

#TODO: check if it is necessary > SSD optimization - sudo swapoff -a
