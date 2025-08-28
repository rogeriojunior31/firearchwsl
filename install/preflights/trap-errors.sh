#!/bin/bash

catch_errors() {
  echo -e "\n\e[31mFireArchWsl installation failed!\e[0m"
  echo
  echo "This command halted with exit code $?:"
  echo "$BASH_COMMAND"
  echo

  echo "You can retry by running: bash ./install.sh"
}

trap catch_errors ERR
