#!/bin/bash

catch_errors() {
  local ec=$?
  echo -e "\n\e[31mFireArchWsl installation failed!\e[0m"
  echo
  echo "Exit code: $ec"
  echo "At: ${BASH_SOURCE[1]:-?}:${BASH_LINENO[0]:-?}"
  echo "Command: $BASH_COMMAND"
  echo
  echo "Re-run com: bash ./install.sh"
}

trap catch_errors ERR
