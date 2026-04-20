#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "⚠️ Este script deve ser executado como root (sudo)."
  return 1 2>/dev/null || exit 1
fi

pacman -S --noconfirm --needed sudo

if [[ -f /etc/firearchwsl/target_user ]]; then
  usuario="$(cat /etc/firearchwsl/target_user)"
  echo "ℹ️  Usuário alvo já registrado: $usuario"
else
  read -rp "Digite o nome do novo usuário: " usuario
fi

if id "$usuario" &>/dev/null; then
  echo "ℹ️  Usuário '$usuario' já existe — seguindo."
else
  useradd -m -G wheel -s /bin/bash "$usuario"

  echo "Digite a senha para o usuário $usuario:"
  passwd "$usuario"

  if ! id "$usuario" &>/dev/null; then
    echo "❌ Falha ao criar o usuário."
    return 1 2>/dev/null || exit 1
  fi
  echo "Usuário '$usuario' criado com sucesso e adicionado ao grupo wheel!"
fi

sed -i '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers
if ! visudo -c -f /etc/sudoers >/dev/null 2>&1; then
  echo "❌ /etc/sudoers inválido após edição — abortando."
  return 1 2>/dev/null || exit 1
fi
echo "Usuário adicionado para ter permissão de sudo!"

mkdir -p /etc/firearchwsl
printf '%s\n' "$usuario" >/etc/firearchwsl/target_user

export TARGET_USER="$usuario"
TARGET_HOME="$(getent passwd "$usuario" | cut -d: -f6)"
export TARGET_HOME
