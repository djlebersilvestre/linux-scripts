#!/bin/bash

base_dir=$1
desired_file=$2
silent_mode=$3

if [ ! -d "$base_dir" ] || [ -z "$desired_file" ]; then
  echo "Usage: $0 DIR FILE [OPTION]"
  echo "Delete recursively files and directories."
  echo
  echo "  DIR:  main directory to start the recursive search"
  echo "  FILE: desired file or directory do delete (wildcards may apply)"
  echo "  OPTIONS:"
  echo "    -s, silent mode - never prompt"

  exit 1
fi

should_run=y
if [ "$silent_mode" != "-s" ]; then
  echo "This operation will delete all files and diretories named '$2' inside the base directory '$1'."
  echo "Are you sure that you want to proceed? [y/N]"
  read should_run
fi

if [ "$should_run" == "y" ]; then
  for f in $(find $1 -name "$2"); do rm -vrf $f; done
else
  echo "Execution cancelled."
fi

exit 0
