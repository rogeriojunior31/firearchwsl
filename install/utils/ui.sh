#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# FireArchWSL - UI Utils
# Funções para interface visual aprimorada
# Author: Rogerio Junior
# ═══════════════════════════════════════════════════════════════════════════════

# Cores e estilos
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [CYAN]='\033[0;36m'
    [WHITE]='\033[1;37m'
    [GRAY]='\033[0;90m'
    [RESET]='\033[0m'
    [BOLD]='\033[1m'
    [DIM]='\033[2m'
    [UNDERLINE]='\033[4m'
)

# Símbolos Unicode
declare -A SYMBOLS=(
    [CHECK]='✅'
    [CROSS]='❌'
    [WARNING]='⚠️ '
    [INFO]='ℹ️ '
    [ROCKET]='🚀'
    [GEAR]='⚙️ '
    [PACKAGE]='📦'
    [USER]='👤'
    [KEY]='🔑'
    [FOLDER]='📁'
    [STAR]='⭐'
    [FIRE]='🔥'
    [SPARKLES]='✨'
    [ARROW_RIGHT]='➜'
    [LOADING]='⏳'
    [SUCCESS]='🎉'
    [SHIELD]='🛡️'
)

# Função para imprimir com cores e ícones
print_message() {
    local type="$1"
    local message="$2"
    local timestamp="$(date '+%H:%M:%S')"
    
    case "$type" in
        "success")
            printf "${COLORS[GREEN]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[CHECK]} ${COLORS[GREEN]}%s${COLORS[RESET]}\n" "$message"
            ;;
        "error")
            printf "${COLORS[RED]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[CROSS]} ${COLORS[RED]}%s${COLORS[RESET]}\n" "$message"
            ;;
        "warning")
            printf "${COLORS[YELLOW]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[WARNING]}${COLORS[YELLOW]}%s${COLORS[RESET]}\n" "$message"
            ;;
        "info")
            printf "${COLORS[CYAN]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[INFO]}${COLORS[CYAN]}%s${COLORS[RESET]}\n" "$message"
            ;;
        "step")
            printf "${COLORS[PURPLE]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[GEAR]}${COLORS[PURPLE]}%s${COLORS[RESET]}\n" "$message"
            ;;
        "package")
            printf "${COLORS[BLUE]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[PACKAGE]} ${COLORS[BLUE]}%s${COLORS[RESET]}\n" "$message"
            ;;
        "user")
            printf "${COLORS[YELLOW]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[USER]} ${COLORS[YELLOW]}%s${COLORS[RESET]}\n" "$message"
            ;;
        *)
            printf "${COLORS[WHITE]}${COLORS[BOLD]}[${timestamp}]${COLORS[RESET]} ${SYMBOLS[ARROW_RIGHT]} %s\n" "$message"
            ;;
    esac
}

# Funções específicas para cada tipo
msg() { print_message "info" "$*"; }
success() { print_message "success" "$*"; }
error() { print_message "error" "$*"; }
warn() { print_message "warning" "$*"; }
step() { print_message "step" "$*"; }
package_msg() { print_message "package" "$*"; }
user_msg() { print_message "user" "$*"; }

# Função para criar separadores decorativos
separator() {
    local char="${1:-═}"
    local length="${2:-80}"
    local color="${3:-CYAN}"
    
    printf "${COLORS[$color]}"
    printf "%*s\n" "$length" | tr ' ' "$char"
    printf "${COLORS[RESET]}"
}

# Função para criar cabeçalhos de seção
section_header() {
    local title="$1"
    local subtitle="${2:-}"
    
    echo
    separator "═" 80 "PURPLE"
    printf "${COLORS[PURPLE]}${COLORS[BOLD]}%s${COLORS[RESET]}\n" "  $title"
    
    if [[ -n "$subtitle" ]]; then
        printf "${COLORS[GRAY]}%s${COLORS[RESET]}\n" "  $subtitle"
    fi
    
    separator "═" 80 "PURPLE"
    echo
}

# Função para barra de progresso
progress_bar() {
    local current="$1"
    local total="$2"
    local message="${3:-Processando}"
    local width=50
    
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r${COLORS[CYAN]}${message}${COLORS[RESET]} ["
    printf "${COLORS[GREEN]}%*s${COLORS[RESET]}" "$completed" | tr ' ' '█'
    printf "${COLORS[GRAY]}%*s${COLORS[RESET]}" "$remaining" | tr ' ' '░'
    printf "] ${COLORS[BOLD]}%d%%${COLORS[RESET]}" "$percentage"
}

# Função para animação de loading
loading_animation() {
    local message="$1"
    local duration="${2:-3}"
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local end_time=$((SECONDS + duration))
    
    while [ $SECONDS -lt $end_time ]; do
        for frame in "${frames[@]}"; do
            printf "\r${COLORS[CYAN]}${frame} %s${COLORS[RESET]}" "$message"
            sleep 0.1
        done
    done
    printf "\r${COLORS[GREEN]}${SYMBOLS[CHECK]} %s${COLORS[RESET]}\n" "$message"
}

# Função para prompt interativo melhorado
interactive_prompt() {
    local prompt="$1"
    local default_value="${2:-}"
    local validation_type="${3:-}"
    local response
    
    while true; do
        if [[ -n "$default_value" ]]; then
            printf "${COLORS[CYAN]}${SYMBOLS[ARROW_RIGHT]} %s${COLORS[RESET]} ${COLORS[GRAY]}[%s]${COLORS[RESET]}: " "$prompt" "$default_value"
        else
            printf "${COLORS[CYAN]}${SYMBOLS[ARROW_RIGHT]} %s${COLORS[RESET]}: " "$prompt"
        fi
        
        read -r response
        
        # Usar valor padrão se vazio
        [[ -z "$response" && -n "$default_value" ]] && response="$default_value"
        
        # Validação
        case "$validation_type" in
            "username")
                if [[ "$response" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; then
                    echo "$response"
                    return 0
                else
                    warn "Nome de usuário inválido. Use apenas letras minúsculas, números, - e _"
                fi
                ;;
            "email")
                if [[ "$response" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
                    echo "$response"
                    return 0
                else
                    warn "Email inválido. Digite um email válido."
                fi
                ;;
            "not_empty")
                if [[ -n "$response" ]]; then
                    echo "$response"
                    return 0
                else
                    warn "Este campo não pode estar vazio."
                fi
                ;;
            *)
                echo "$response"
                return 0
                ;;
        esac
    done
}

# Função para confirmação com estilo
confirm_action() {
    local message="$1"
    local default="${2:-n}"
    
    local prompt_text
    if [[ "$default" == "y" ]]; then
        prompt_text="[Y/n]"
    else
        prompt_text="[y/N]"
    fi
    
    while true; do
        printf "${COLORS[YELLOW]}${SYMBOLS[WARNING]}%s${COLORS[RESET]} %s: " "$message" "$prompt_text"
        read -r response
        
        [[ -z "$response" ]] && response="$default"
        
        case "${response,,}" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) warn "Por favor, responda 'y' para sim ou 'n' para não." ;;
        esac
    done
}

# Função para mostrar status de pacotes sendo instalados
package_install_status() {
    local package_name="$1"
    local status="$2" # installing, success, error
    
    case "$status" in
        "installing")
            printf "${COLORS[BLUE]}${SYMBOLS[LOADING]} Instalando %s...${COLORS[RESET]}\n" "$package_name"
            ;;
        "success")
            printf "${COLORS[GREEN]}${SYMBOLS[CHECK]} %s instalado com sucesso${COLORS[RESET]}\n" "$package_name"
            ;;
        "error")
            printf "${COLORS[RED]}${SYMBOLS[CROSS]} Erro ao instalar %s${COLORS[RESET]}\n" "$package_name"
            ;;
    esac
}

# Função para mostrar informações do sistema
system_info() {
    section_header "${SYMBOLS[FIRE]} FIREARCH WSL - INFORMAÇÕES DO SISTEMA"
    
    info "Sistema: $(uname -s) $(uname -r)"
    info "Arquitetura: $(uname -m)"
    info "Usuário atual: $(whoami)"
    info "Diretório: $(pwd)"
    
    if command -v fastfetch >/dev/null 2>&1; then
        echo
        fastfetch --config none --logo small
    fi
    
    echo
}

# Função para banner de boas-vindas
welcome_banner() {
    clear
    
    # Se temos figlet, usar ele para o título
    if command -v figlet >/dev/null 2>&1; then
        printf "${COLORS[PURPLE]}"
        figlet -f small "FireArch WSL"
        printf "${COLORS[RESET]}"
    else
        section_header "${SYMBOLS[FIRE]} FIREARCH WSL" "Sistema de Configuração Arch Linux para WSL"
    fi
    
    printf "${COLORS[CYAN]}${SYMBOLS[SPARKLES]} Bem-vindo ao FireArch WSL Setup${COLORS[RESET]}\n"
    printf "${COLORS[GRAY]}   Configurando seu ambiente de desenvolvimento...${COLORS[RESET]}\n\n"
}

# Função para mostrar resumo final
final_summary() {
    clear
    section_header "${SYMBOLS[SUCCESS]} INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    
    success "Todos os componentes foram instalados e configurados"
    info "Shell padrão configurado: Fish"
    info "Prompt configurado: Starship"
    info "Editor configurado: Neovim (LazyVim)"
    
    echo
    printf "${COLORS[YELLOW]}${SYMBOLS[STAR]} Próximos passos:${COLORS[RESET]}\n"
    printf "  1. Reinicie o terminal ou execute: ${COLORS[CYAN]}exec fish${COLORS[RESET]}\n"
    printf "  2. Execute: ${COLORS[CYAN]}nvim${COLORS[RESET]} para configurar o Neovim\n"
    printf "  3. Personalize suas configurações em: ${COLORS[CYAN]}~/.config/${COLORS[RESET]}\n"
    
    echo
    separator "═" 80 "GREEN"
    printf "${COLORS[GREEN]}${COLORS[BOLD]}%s${COLORS[RESET]}\n" "  ${SYMBOLS[FIRE]} FireArch WSL está pronto para uso! ${SYMBOLS[FIRE]}"
    separator "═" 80 "GREEN"
    echo
}

# Função die personalizada
die() {
    error "$*"
    exit 1
}