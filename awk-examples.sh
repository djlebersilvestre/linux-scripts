#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 FUNCTION"
  echo "Calls the desired function that exists inside the script."
  echo
  echo "  FUNCTION: desired function"

  exit 1
fi

# Ex1: remove all docker debian images
ex1() {
  echo "Removing all docker debian images"
  imgs=`sudo docker images | grep -v REPOSITORY | awk '{ print $3 }'`

  for i in $imgs; do
    sudo docker rmi $i;
  done
}

$@

