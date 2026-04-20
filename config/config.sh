#!/bin/bash

set -Eeuo pipefail

: "${TARGET_USER:?TARGET_USER não definido — rode via install.sh}"
: "${TARGET_HOME:?TARGET_HOME não definido — rode via install.sh}"

# Raiz do repo — via FIREARCH_ROOT (exportado por install.sh) com fallback
FIREARCH_ROOT="${FIREARCH_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# FORCE_CONFIG=1 sobrescreve edits locais do user em rcfiles. Default: preserva.
cp_flag="-n"
[[ "${FORCE_CONFIG:-}" == "1" ]] && cp_flag=""

echo "📁 Configurando para usuário: $TARGET_USER (home: $TARGET_HOME)"

# Criar diretórios necessários
mkdir -p "$TARGET_HOME/.config"
mkdir -p "$TARGET_HOME/.local/share/firearchwsl/config"
mkdir -p "$TARGET_HOME/.local/share/firearchwsl/default"

# Payloads versionados — sempre sobrescreve (é o contrato do repo ser fonte)
cp -R "$FIREARCH_ROOT/config_files/"* "$TARGET_HOME/.local/share/firearchwsl/config/"
cp "$FIREARCH_ROOT/default/"* "$TARGET_HOME/.local/share/firearchwsl/default/"

# rcfiles — preserva edits locais por default (FORCE_CONFIG=1 para sobrescrever)
mkdir -p "$TARGET_HOME/.config/fish"
cp $cp_flag "$TARGET_HOME/.local/share/firearchwsl/default/config.fish" "$TARGET_HOME/.config/fish/config.fish" || true
cp $cp_flag "$TARGET_HOME/.local/share/firearchwsl/default/bashrc" "$TARGET_HOME/.bashrc" || true

# Starship: symlink para o toml versionado (caminho canônico que starship lê)
ln -sf "$TARGET_HOME/.local/share/firearchwsl/config/starship.toml" "$TARGET_HOME/.config/starship.toml"

# Ajustar permissões para o usuário correto
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config"
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local"
chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/starship.toml"
[[ -e "$TARGET_HOME/.bashrc" ]] && chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"

echo "✅ Configurações aplicadas para $TARGET_USER"
