#!/bin/bash

set -Eeuo pipefail

# Carregar utilitários de UI
source "$(dirname "$0")/../utils/ui.sh" 2>/dev/null || {
    # Fallback se não encontrar o arquivo
    msg() { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
    warn() { printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
    die() { printf '\e[1;31m[ERRO]\e[0m %s\n' "$*"; exit 1; }
}

PACMAN_PKGS=(
  "sudo"
  "base-devel"
  "git"
  "fish"
  "btop"
  "curl"
  "wget"
  "just"
  "make"
  "eza"
  "bat"
  "openssh"
  "vim"
)

need_cmd() { command -v "$1" &>/dev/null; }

ensure_sudo() {
  if ((EUID != 0)); then
    sudo -v || die "Permissão de superusuário necessária."
  fi
}

install_packages_with_progress() {
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    
    for package in "${packages[@]}"; do
        ((current++))
        
        package_install_status "$package" "installing"
        progress_bar "$current" "$total" "Instalando pacotes essenciais"
        
        if sudo pacman -S --needed --noconfirm "$package" >/dev/null 2>&1; then
            echo # Nova linha após a barra de progresso
            package_install_status "$package" "success"
        else
            echo # Nova linha após a barra de progresso
            package_install_status "$package" "error"
            warn "Falha ao instalar $package, continuando..."
        fi
        
        sleep 0.5 # Pequena pausa para visualização
    done
    
    echo # Linha final
}

main() {
  section_header "📦 PACOTES ESSENCIAIS" "Instalando ferramentas fundamentais do sistema"
  
  step "Atualizando repositórios do pacman..."
  ensure_sudo
  
  loading_animation "Sincronizando repositórios" 3
  sudo pacman -Syu --noconfirm >/dev/null 2>&1

  success "Repositórios atualizados!"

  step "Instalando pacotes essenciais..."
  info "Total de pacotes: ${#PACMAN_PKGS[@]}"
  
  install_packages_with_progress "${PACMAN_PKGS[@]}"

  success "Todos os pacotes essenciais foram instalados! 🎉"
  
  echo
  info "Pacotes instalados:"
  for pkg in "${PACMAN_PKGS[@]}"; do
      printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
  done
}

main "$@"
