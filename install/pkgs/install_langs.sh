#!/bin/bash

set -Eeuo pipefail

: "${TARGET_USER:?TARGET_USER não definido — rode via install.sh}"

install_lang() {
  local lang="$1"
  echo "Instalando $lang..."
  as_user mise use -g "${lang}@latest" || warn "Falha ao instalar $lang — seguindo."
}

install_lang python
install_lang node
install_lang bun
install_lang rust
install_lang go
