#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Por favor, execute como root (sudo)."
  exit 1
fi

echo "Atualizando pacotes e instalando glibc..."
pacman -Sy --noconfirm glibc --needed

echo "Editando /etc/locale.gen para incluir pt_BR.UTF-8 e en_US.UTF-8..."
sed -i 's/^#\s*\(pt_BR.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^#\s*\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen

grep -q '^pt_BR.UTF-8 UTF-8' /etc/locale.gen || echo 'pt_BR.UTF-8 UTF-8' >>/etc/locale.gen
grep -q '^en_US.UTF-8 UTF-8' /etc/locale.gen || echo 'en_US.UTF-8 UTF-8' >>/etc/locale.gen

echo "Gerando os locales suportados..."
locale-gen

echo "Configurando idioma padrão no /etc/locale.conf..."
cat <<EOF >/etc/locale.conf
LANG=pt_BR.UTF-8
LANGUAGE=pt_BR:en_US
LC_ALL=
EOF

echo "Locale configurado!"
