#!/bin/bash
# firearchwsl shared library.
# Sourced by install.sh before anything else. Not an entry point.

_lib_dir="$(dirname "${BASH_SOURCE[0]}")"
# Translations: t, i18n_load, i18n_choose
# shellcheck source=install/preflights/i18n.sh
source "$_lib_dir/i18n.sh"
# Interface: msg/ok/warn/skip/die, step, run, pac_install, ask_*
# shellcheck source=install/preflights/ui.sh
source "$_lib_dir/ui.sh"
unset _lib_dir

# Optional components: tuis, langs, lazyvim, doom, docker.
# FIREARCH_SKIP is a comma- or space-separated list (e.g. "doom,docker").
component_enabled() {
  local c
  for c in ${FIREARCH_SKIP//,/ }; do
    [[ "$c" == "$1" ]] && return 1
  done
  return 0
}

# Resolve the target user. Priority:
#   1. State file /etc/firearchwsl/target_user (written by create_your_user.sh)
#   2. First non-empty member of the wheel group
resolve_target_user() {
  local state=/etc/firearchwsl/target_user user
  if [[ -r "$state" ]]; then
    user="$(tr -d '[:space:]' <"$state")"
    if [[ -n "$user" ]] && id "$user" &>/dev/null; then
      printf '%s' "$user"
      return 0
    fi
  fi
  user="$(getent group wheel | cut -d: -f4 | tr ',' '\n' | grep -v '^$' | head -1)" || true
  [[ -n "$user" ]] || return 1
  printf '%s' "$user"
}

# Export TARGET_USER and TARGET_HOME unless they are already set.
ensure_target_user() {
  if [[ -z "${TARGET_USER:-}" ]]; then
    TARGET_USER="$(resolve_target_user)" || die "Could not determine TARGET_USER"
    export TARGET_USER
  fi
  if [[ -z "${TARGET_HOME:-}" ]]; then
    TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
    [[ -n "$TARGET_HOME" && -d "$TARGET_HOME" ]] || die "Invalid HOME for $TARGET_USER: $TARGET_HOME"
    export TARGET_HOME
  fi
}

# Run a command as TARGET_USER. Root → user, so no password prompt.
# Usage: as_user <cmd> [args...]
as_user() {
  [[ -n "${TARGET_USER:-}" && -n "${TARGET_HOME:-}" ]] ||
    die "as_user: TARGET_USER/TARGET_HOME not set — call ensure_target_user first"
  sudo -Hu "$TARGET_USER" env \
    HOME="$TARGET_HOME" \
    PATH="$TARGET_HOME/.local/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin" \
    "$@"
}
