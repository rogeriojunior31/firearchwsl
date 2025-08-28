#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "⚠️ Este script deve ser executado como root (sudo)."
  exit 1
fi

pacman -S --noconfirm --needed sudo

read -rp "Digite o nome do novo usuário: " usuario

if id "$usuario" &>/dev/null; then
  echo "⚠️ O usuário '$usuario' já existe."
  exit 1
fi

useradd -m -G wheel -s /bin/bash "$usuario"

echo "Digite a senha para o usuário $usuario:"
passwd "$usuario"

if id "$usuario" &>/dev/null; then
  echo "Usuário '$usuario' criado com sucesso e adicionado ao grupo wheel!"
else
  echo "❌ Falha ao criar o usuário."
fi

sed -i '/^# %wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers
echo "Usuário adicionado para ter permissão de sudo!"
