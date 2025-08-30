#!/bin/bash

## Firearchwsl - install.sh
## Author: Rogerio Junior

# Exit immediately if a non-zero status
set -eE

# Carregar utilitários de UI
source ./install/utils/ui.sh 2>/dev/null || {
    # Fallback básico se não encontrar o arquivo
    echo "⚠️ Arquivo ui.sh não encontrado, usando interface básica"
    msg() { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
    success() { printf '\e[1;32m[SUCCESS]\e[0m %s\n' "$*"; }
    warn() { printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
    die() { printf '\e[1;31m[ERRO]\e[0m %s\n' "$*"; exit 1; }
}

# Paths
FIREARCH_INSTALL=./install
FIREARCH_SYSTEM=./system
FIREARCH_CONFIG=./config

# Scripts de instalação na ordem correta
INSTALL_SCRIPTS=(
    "$FIREARCH_INSTALL/preflights/trap-errors.sh"
    "$FIREARCH_SYSTEM/create_your_user.sh"
    "$FIREARCH_SYSTEM/configure_locale.sh"
    "$FIREARCH_SYSTEM/wsl_config.sh"
    "$FIREARCH_INSTALL/preflights/essentials_pkgs.sh"
    "$FIREARCH_SYSTEM/configure_git_user.sh"
    "$FIREARCH_INSTALL/preflights/repositories.sh"
    "$FIREARCH_INSTALL/preflights/install-mise.sh"
    "$FIREARCH_INSTALL/pkgs/good-tools.sh"
    "$FIREARCH_INSTALL/pkgs/tuis.sh"
    "$FIREARCH_INSTALL/pkgs/install_langs.sh"
    "$FIREARCH_INSTALL/pkgs/editors.sh"
    "$FIREARCH_CONFIG/config.sh"
    "$FIREARCH_CONFIG/docker.sh"
)

# Nomes descritivos para cada script
SCRIPT_NAMES=(
    "Configuração de tratamento de erros"
    "Criação de usuário"
    "Configuração de locale"
    "Configuração WSL"
    "Pacotes essenciais"
    "Configuração Git"
    "Repositórios AUR"
    "Instalação Mise"
    "Ferramentas de desenvolvimento"
    "Aplicações TUI"
    "Linguagens de programação"
    "Editores de código"
    "Configurações de usuário"
    "Configuração Docker"
)

main() {
    # Banner de boas-vindas
    welcome_banner
    
    # Verificar se está executando como root
    if [[ $EUID -ne 0 ]]; then
        die "Este script deve ser executado como root (sudo ./install.sh)"
    fi

    # Mostrar informações do sistema
    system_info
    
    # Confirmação para continuar
    if ! confirm_action "Deseja continuar com a instalação?" "y"; then
        warn "Instalação cancelada pelo usuário."
        exit 0
    fi

    # Sync inicial do pacman
    step "Sincronização inicial do pacman..."
    loading_animation "Atualizando sistema base" 3
    pacman -Syu --noconfirm >/dev/null 2>&1
    success "Sistema base atualizado!"

    # Executar scripts de instalação
    local total_scripts=${#INSTALL_SCRIPTS[@]}
    local current_script=0
    
    for i in "${!INSTALL_SCRIPTS[@]}"; do
        local script="${INSTALL_SCRIPTS[$i]}"
        local script_name="${SCRIPT_NAMES[$i]}"
        ((current_script++))
        
        echo
        section_header "ETAPA $current_script/$total_scripts: $script_name"
        
        # Mostrar progresso geral
        progress_bar "$current_script" "$total_scripts" "Progresso da instalação"
        echo
        
        if [[ -f "$script" ]]; then
            step "Executando: $script_name"
            
            if source "$script"; then
                success "✅ $script_name concluído!"
            else
                error "❌ Erro na execução: $script_name"
                if confirm_action "Deseja continuar mesmo assim?" "n"; then
                    warn "Continuando instalação..."
                else
                    die "Instalação interrompida."
                fi
            fi
        else
            warn "Script não encontrado: $script"
        fi
        
        # Pequena pausa entre scripts
        sleep 1
    done

    # Finalização com estilo
    final_summary
    
    # Logo final se disponível
    if command -v tte >/dev/null 2>&1 && [[ -f ./logo.txt ]]; then
        echo
        info "Exibindo logo final..."
        tte -i ./logo.txt --frame-rate 920 laseretch 2>/dev/null || true
    fi
    
    success "🎉 FireArch WSL instalado com sucesso! 🎉"
}

# Trap para limpeza em caso de erro
cleanup() {
    echo
    error "Instalação interrompida por erro ou sinal."
    warn "Verifique os logs acima para identificar o problema."
}

trap cleanup ERR INT TERM

# Executar instalação
main "$@"
