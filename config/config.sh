#!/bin/bash

# Obter o usuário não-root (assumindo que é o primeiro usuário no grupo wheel além do root)
TARGET_USER=$(getent group wheel | cut -d: -f4 | tr ',' '\n' | grep -v "^$" | head -1)

if [ -z "$TARGET_USER" ]; then
    echo "❌ Usuário não encontrado no grupo wheel"
    exit 1
fi

TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
    echo "❌ Diretório home do usuário $TARGET_USER não encontrado"
    exit 1
fi

echo "📁 Configurando para usuário: $TARGET_USER (home: $TARGET_HOME)"

# Criar diretórios necessários
mkdir -p "$TARGET_HOME/.config"
mkdir -p "$TARGET_HOME/.local/share/firearchwsl/config"
mkdir -p "$TARGET_HOME/.local/share/firearchwsl/default"

# Copiar arquivos de configuração
cp -R ../config_files/* "$TARGET_HOME/.local/share/firearchwsl/config/"

# Copiar configurações padrão
cp ../default/* "$TARGET_HOME/.local/share/firearchwsl/default/"

# Configurar Fish shell
mkdir -p "$TARGET_HOME/.config/fish"
cp "$TARGET_HOME/.local/share/firearchwsl/default/config.fish" "$TARGET_HOME/.config/fish/"

# Configurar bashrc
cp "$TARGET_HOME/.local/share/firearchwsl/default/bashrc" "$TARGET_HOME/.bashrc"

# Ajustar permissões para o usuário correto
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"

echo "✅ Configurações aplicadas para $TARGET_USER"
