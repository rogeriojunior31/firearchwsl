#!/bin/bash
# WSL-specific tweaks: /etc/wsl.conf (default user, systemd) and shims.

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"

# wsl_conf_set <section> <key> <value> — idempotent edit of /etc/wsl.conf that
# keeps whatever else is already in the file.
wsl_conf_set() {
  local section=$1 key=$2 value=$3 file=/etc/wsl.conf
  local header="^\\[${section}\\]"
  touch "$file"
  if ! grep -q "$header" "$file"; then
    [[ -s "$file" ]] && echo >>"$file"
    printf '[%s]\n%s=%s\n' "$section" "$key" "$value" >>"$file"
  elif sed -n "/${header}/,/^\\[/p" "$file" | grep -q "^${key}[[:space:]]*="; then
    sed -i "/${header}/,/^\\[/ s|^${key}[[:space:]]*=.*|${key}=${value}|" "$file"
  else
    sed -i "/${header}/a ${key}=${value}" "$file"
  fi
}

# Log in straight as the created user (otherwise WSL keeps opening as root)
wsl_conf_set user default "$TARGET_USER"
ok "$(t wsl.default_user "$TARGET_USER")"

# Hostname: only pinned when it differs from the default (the Windows machine
# name), so keeping the default keeps following Windows. WSL applies it and
# regenerates /etc/hosts on the next start.
if [[ -n "${FIREARCH_HOSTNAME:-}" && "$FIREARCH_HOSTNAME" != "$(uname -n)" ]]; then
  wsl_conf_set network hostname "$FIREARCH_HOSTNAME"
  ok "$(t wsl.hostname "$FIREARCH_HOSTNAME")"
else
  ok "$(t wsl.hostname_kept "$(uname -n)")"
fi

# systemd is required by Docker
wsl_conf_set boot systemd true
ok "$(t wsl.systemd)"

# Windows home as a Linux path (/mnt/c/Users/<you>), via WSL interop.
# Prints nothing when interop is disabled.
windows_home() {
  local cmd=/mnt/c/Windows/System32/cmd.exe profile
  [[ -x "$cmd" ]] || return 0
  profile="$(cd /mnt/c && "$cmd" /c 'echo %USERPROFILE%' 2>/dev/null || true)"
  profile="${profile%$'\r'}"
  [[ "$profile" == [A-Za-z]:\\* ]] || return 0
  wslpath -u "$profile" 2>/dev/null || true
}

# New shells start in the Windows home, and mise looks for config files from
# the current directory upwards — so it would load the Windows-side
# ~/.config/mise and list those tools as "missing". Projects elsewhere under
# /mnt/c keep working; only that one directory is ignored.
# The setting is only honored in miserc.toml (read before any config file).
_win_home="$(windows_home)"
_miserc="$TARGET_HOME/.config/mise/miserc.toml"
if [[ -z "$_win_home" ]]; then
  skip "$(t wsl.no_interop)"
elif [[ ! -e "$_miserc" ]]; then
  as_user mkdir -p "$TARGET_HOME/.config/mise"
  printf '# Written by firearchwsl: ignore the Windows-side mise config.\nignored_config_paths = ["%s/.config/mise"]\n' \
    "$_win_home" | as_user tee "$_miserc" >/dev/null
  ok "$(t wsl.mise_ignore "$_win_home/.config/mise")"
elif grep -qF "$_win_home/.config/mise" "$_miserc"; then
  ok "$(t wsl.mise_ignore "$_win_home/.config/mise")"
else
  # shellcheck disable=SC2088 # display text
  skip "$(t wsl.mise_ignore_skip "~/.config/mise/miserc.toml" "$_win_home/.config/mise")"
fi
unset _win_home _miserc

# libedit ABI shim — some binaries (e.g. the OpenGL stack) look for libedit.so.2
if [[ -e /usr/lib/libedit.so ]]; then
  ln -sf /usr/lib/libedit.so /usr/lib/libedit.so.2
  ok "$(t wsl.libedit)"
else
  skip "$(t wsl.libedit_skip)"
fi
