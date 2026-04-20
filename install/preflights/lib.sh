#!/bin/bash
# firearchwsl shared library.
# Sourced por install.sh após create_your_user.sh, antes de qualquer
# script user-scoped. Não é entry-point — requer install.sh como orquestrador.

# Log helpers unificados
msg()  { printf '\e[1;32m[INFO]\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m[WARN]\e[0m %s\n' "$*"; }
die()  { printf '\e[1;31m[ERRO]\e[0m %s\n' "$*"; exit 1; }

# Descobre o usuário alvo. Prioridade:
#   1. Arquivo de estado /etc/firearchwsl/target_user (escrito em create_your_user.sh)
#   2. Primeiro membro não-vazio do grupo wheel
resolve_target_user() {
  local state=/etc/firearchwsl/target_user user
  if [[ -r "$state" ]]; then
    user="$(tr -d '[:space:]' <"$state")"
    if [[ -n "$user" ]] && id "$user" &>/dev/null; then
      printf '%s' "$user"
      return 0
    fi
  fi
  user="$(getent group wheel | cut -d: -f4 | tr ',' '\n' | grep -v '^$' | head -1)"
  [[ -n "$user" ]] || return 1
  printf '%s' "$user"
}

# Exporta TARGET_USER e TARGET_HOME se ainda não estiverem setados.
ensure_target_user() {
  if [[ -z "${TARGET_USER:-}" ]]; then
    TARGET_USER="$(resolve_target_user)" || die "Não foi possível determinar TARGET_USER"
    export TARGET_USER
  fi
  if [[ -z "${TARGET_HOME:-}" ]]; then
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
    [[ -n "$TARGET_HOME" && -d "$TARGET_HOME" ]] || die "HOME de $TARGET_USER inválido: $TARGET_HOME"
    export TARGET_HOME
  fi
}

# Executa comandos no contexto do TARGET_USER. Root → user sem prompt de senha.
# Uso: as_user <cmd> [args...]
as_user() {
  [[ -n "${TARGET_USER:-}" && -n "${TARGET_HOME:-}" ]] \
    || die "as_user: TARGET_USER/TARGET_HOME não setados — chame ensure_target_user antes"
  sudo -Hu "$TARGET_USER" env \
    HOME="$TARGET_HOME" \
    PATH="$TARGET_HOME/.local/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin" \
    "$@"
}
