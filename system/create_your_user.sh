#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "⚠️ Este script deve ser executado como root (sudo)."
  exit 1
fi

read -rp "Digite o nome do novo usuário: " usuario

if id "$usuario" &>/dev/null; then
  echo "⚠️ O usuário '$usuario' já existe."
  exit 1
fi

useradd -m -G wheel -s /bin/bash "$usuario"

echo "Digite a senha para o usuário $usuario:"
passwd "$usuario"

if id "$usuario" &>/dev/null; then
  echo "✅ Usuário '$usuario' criado com sucesso e adicionado ao grupo wheel!"
  echo "Lembre-se de garantir que no seu /etc/sudoers o grupo wheel tenha acesso ao sudo."
else
  echo "❌ Falha ao criar o usuário."
fi
