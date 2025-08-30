#!/bin/bash

set -Eeuo pipefail

# Carregar utilitários de UI
source "$(dirname "$0")/../utils/ui.sh" 2>/dev/null || {
    # Fallback se não encontrar o arquivo
    msg() { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
    warn() { printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
    die() { printf '\e[1;31m[ERRO]\e[0m %s\n' "$*"; exit 1; }
}

# Organizando pacotes por categoria
DEVELOPMENT_TOOLS=(
  "jq" "yq" "fx" "fd" "ripgrep"
)

PRODUCTIVITY_TOOLS=(
  "stow" "task" "zellij" "glow" "tldr"
  "asciinema" "dust" "zoxide"
)

EDITORS_AND_TEXT=(
  "neovim" "emacs" "harper"
)

COMPRESSION_TOOLS=(
  "7zip" "zip" "unzip"
)

DOCKER_TOOLS=(
  "docker" "docker-buildx" "docker-compose"
)

SYSTEM_TOOLS=(
  "less" "man" "starship" "bash-completion"
  "fastfetch"
)

PACKAGE_MANAGERS=(
  "yay" "paru"
)

PROGRAMMING_TOOLS=(
  "tree-sitter-cli" "cargo" "python-poetry-core"
  "python-terminaltexteffects" "luarocks"
)

FONTS=(
  "ttf-cascadia-mono-nerd" "ttf-jetbrains-mono"
  "ttf-hack-nerd"
)

VISUAL_TOOLS=(
  "figlet"
)

# Consolidar todos os pacotes
ALL_PACMAN_PKGS=(
  "${DEVELOPMENT_TOOLS[@]}"
  "${PRODUCTIVITY_TOOLS[@]}"
  "${EDITORS_AND_TEXT[@]}"
  "${COMPRESSION_TOOLS[@]}"
  "${DOCKER_TOOLS[@]}"
  "${SYSTEM_TOOLS[@]}"
  "${PACKAGE_MANAGERS[@]}"
  "${PROGRAMMING_TOOLS[@]}"
  "${FONTS[@]}"
  "${VISUAL_TOOLS[@]}"
)

need_cmd() { command -v "$1" &>/dev/null; }

ensure_sudo() {
  if ((EUID != 0)); then
    sudo -v || die "Permissão de superusuário necessária."
  fi
}

install_package_category() {
    local category_name="$1"
    shift
    local packages=("$@")
    local total=${#packages[@]}
    local current=0
    local failed_packages=()
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi
    
    step "Instalando $category_name (${#packages[@]} pacotes)..."
    
    for package in "${packages[@]}"; do
        ((current++))
        
        package_install_status "$package" "installing"
        progress_bar "$current" "$total" "$category_name"
        
        if sudo pacman -S --needed --noconfirm "$package" >/dev/null 2>&1; then
            echo # Nova linha após a barra de progresso
            package_install_status "$package" "success"
        else
            echo # Nova linha após a barra de progresso
            package_install_status "$package" "error"
            failed_packages+=("$package")
        fi
        
        sleep 0.3
    done
    
    echo
    if [[ ${#failed_packages[@]} -eq 0 ]]; then
        success "✅ $category_name: Todos os pacotes instalados!"
    else
        warn "⚠️  $category_name: ${#failed_packages[@]} pacotes falharam:"
        for pkg in "${failed_packages[@]}"; do
            printf "    ${COLORS[RED]}✗${COLORS[RESET]} %s\n" "$pkg"
        done
    fi
}

show_installation_summary() {
    section_header "📋 RESUMO DA INSTALAÇÃO"
    
    # Mostrar resumo direto por categoria
    if [[ ${#DEVELOPMENT_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas de desenvolvimento (${#DEVELOPMENT_TOOLS[@]} pacotes)"
        for pkg in "${DEVELOPMENT_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#PRODUCTIVITY_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas de produtividade (${#PRODUCTIVITY_TOOLS[@]} pacotes)"
        for pkg in "${PRODUCTIVITY_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#EDITORS_AND_TEXT[@]} -gt 0 ]]; then
        info "Editores de texto (${#EDITORS_AND_TEXT[@]} pacotes)"
        for pkg in "${EDITORS_AND_TEXT[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#COMPRESSION_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas de compressão (${#COMPRESSION_TOOLS[@]} pacotes)"
        for pkg in "${COMPRESSION_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#DOCKER_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas Docker (${#DOCKER_TOOLS[@]} pacotes)"
        for pkg in "${DOCKER_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#SYSTEM_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas de sistema (${#SYSTEM_TOOLS[@]} pacotes)"
        for pkg in "${SYSTEM_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#PACKAGE_MANAGERS[@]} -gt 0 ]]; then
        info "Gerenciadores de pacotes (${#PACKAGE_MANAGERS[@]} pacotes)"
        for pkg in "${PACKAGE_MANAGERS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#PROGRAMMING_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas de programação (${#PROGRAMMING_TOOLS[@]} pacotes)"
        for pkg in "${PROGRAMMING_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#FONTS[@]} -gt 0 ]]; then
        info "Fontes (${#FONTS[@]} pacotes)"
        for pkg in "${FONTS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
    
    if [[ ${#VISUAL_TOOLS[@]} -gt 0 ]]; then
        info "Ferramentas visuais (${#VISUAL_TOOLS[@]} pacotes)"
        for pkg in "${VISUAL_TOOLS[@]}"; do
            printf "  ${COLORS[GREEN]}✓${COLORS[RESET]} %s\n" "$pkg"
        done
        echo
    fi
}

main() {
    section_header "🛠️  FERRAMENTAS DE DESENVOLVIMENTO" "Instalando pacotes avançados e utilitários"
    
    ensure_sudo
    
    step "Atualizando repositórios..."
    loading_animation "Sincronizando com repositórios" 2
    sudo pacman -Syu --noconfirm >/dev/null 2>&1
    success "Repositórios atualizados!"
    
    echo
    info "Total de pacotes a instalar: ${#ALL_PACMAN_PKGS[@]}"
    
    if ! confirm_action "Continuar com a instalação?" "y"; then
        warn "Instalação cancelada."
        exit 0
    fi
    
    # Instalar por categoria
    install_package_category "Ferramentas de desenvolvimento" "${DEVELOPMENT_TOOLS[@]}"
    install_package_category "Ferramentas de produtividade" "${PRODUCTIVITY_TOOLS[@]}"
    install_package_category "Editores de texto" "${EDITORS_AND_TEXT[@]}"
    install_package_category "Ferramentas de compressão" "${COMPRESSION_TOOLS[@]}"
    install_package_category "Ferramentas Docker" "${DOCKER_TOOLS[@]}"
    install_package_category "Ferramentas de sistema" "${SYSTEM_TOOLS[@]}"
    install_package_category "Gerenciadores de pacotes" "${PACKAGE_MANAGERS[@]}"
    install_package_category "Ferramentas de programação" "${PROGRAMMING_TOOLS[@]}"
    install_package_category "Fontes" "${FONTS[@]}"
    install_package_category "Ferramentas visuais" "${VISUAL_TOOLS[@]}"
    
    # Resumo final
    show_installation_summary
    
    success "🎉 Instalação de ferramentas concluída!"
}

main "$@"
