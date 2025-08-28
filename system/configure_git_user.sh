#!/bin/bash

set -euo pipefail

echo "==== Configuração do Git ===="

read -rp "Digite seu nome para o Git (user.name): " git_name
read -rp "Digite seu email para o Git (user.email): " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"

echo "✅ Nome e Email configurados com sucesso no Git."

# Basic configs
git config --global init.defaultBranch main
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

echo "✅ Configurações adicionais aplicadas ao ~/.gitconfig"
echo "✨ Git configurado com sucesso!"
