#!/bin/bash

set -Eeuo pipefail

: "${TARGET_USER:?TARGET_USER não definido — rode via install.sh}"

echo "==== Configuração do Git ===="

read -rp "Digite seu nome para o Git (user.name): " git_name
read -rp "Digite seu email para o Git (user.email): " git_email

as_user git config --global user.name "$git_name"
as_user git config --global user.email "$git_email"

echo "✅ Nome e Email configurados com sucesso no Git."

# Basic configs
as_user git config --global init.defaultBranch main
as_user git config --global alias.co checkout
as_user git config --global alias.br branch
as_user git config --global alias.ci commit
as_user git config --global alias.st status
as_user git config --global pull.rebase true

echo "✅ Configurações aplicadas a ~${TARGET_USER}/.gitconfig"
echo "✨ Git configurado com sucesso!"
