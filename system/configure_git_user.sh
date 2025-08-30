#!/bin/bash

set -euo pipefail

# Carregar utilitários de UI
source "$(dirname "$0")/../install/utils/ui.sh" 2>/dev/null || {
    # Fallback se não encontrar o arquivo
    msg() { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
    success() { printf '\e[1;32m[SUCCESS]\e[0m %s\n' "$*"; }
    step() { printf '\e[1;35m[STEP]\e[0m %s\n' "$*"; }
}

section_header "🔧 CONFIGURAÇÃO DO GIT" "Definindo identidade global do Git"

# Prompts interativos com validação
git_name=$(interactive_prompt "Digite seu nome para o Git (user.name)" "" "not_empty")
git_email=$(interactive_prompt "Digite seu email para o Git (user.email)" "" "email")

step "Configurando identidade do Git..."
loading_animation "Aplicando configurações" 2

git config --global user.name "$git_name"
git config --global user.email "$git_email"

success "Nome e Email configurados: $git_name <$git_email>"

step "Aplicando configurações adicionais do Git..."

# Basic configs
git config --global init.defaultBranch main
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true

success "Configurações adicionais aplicadas ao ~/.gitconfig"

info "Aliases configurados:"
printf "  ${COLORS[CYAN]}git co${COLORS[RESET]} → git checkout\n"
printf "  ${COLORS[CYAN]}git br${COLORS[RESET]} → git branch\n"
printf "  ${COLORS[CYAN]}git ci${COLORS[RESET]} → git commit\n"
printf "  ${COLORS[CYAN]}git st${COLORS[RESET]} → git status\n"

success "Git configurado com sucesso! ✨"
