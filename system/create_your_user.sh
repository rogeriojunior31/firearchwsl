#!/bin/bash

# Carregar utilitários de UI
source "$(dirname "$0")/../install/utils/ui.sh" 2>/dev/null || {
    # Fallback se não encontrar o arquivo
    msg() { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
    warn() { printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
    die() { printf '\e[1;31m[ERRO]\e[0m %s\n' "$*"; exit 1; }
}

if [[ $EUID -ne 0 ]]; then
  warn "Este script deve ser executado como root (sudo)."
  exit 1
fi

section_header "👤 CRIAÇÃO DE USUÁRIO" "Configurando novo usuário do sistema"

step "Instalando sudo..."
pacman -S --noconfirm --needed sudo

# Prompt interativo com validação
while true; do
    usuario=$(interactive_prompt "Digite o nome do novo usuário" "" "username")
    
    if id "$usuario" &>/dev/null; then
        warn "O usuário '$usuario' já existe. Escolha outro nome."
        continue
    else
        break
    fi
done

step "Criando usuário: $usuario"
loading_animation "Configurando usuário" 2

useradd -m -G wheel -s /bin/bash "$usuario"

user_msg "Configurando senha para o usuário: $usuario"
echo "Digite a senha para o usuário $usuario:"
passwd "$usuario"

if id "$usuario" &>/dev/null; then
  success "Usuário '$usuario' criado com sucesso e adicionado ao grupo wheel!"
else
  die "Falha ao criar o usuário."
fi

step "Habilitando permissões de sudo para o grupo wheel..."
sed -i '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers

success "Usuário '$usuario' configurado com permissões de sudo!"
success "Configuração de usuário concluída!"
