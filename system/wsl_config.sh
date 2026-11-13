#!/bin/bash
# WSL-specific tweaks: /etc/wsl.conf (default user, systemd) and shims.

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"

# wsl_conf_set <section> <key> <value> — idempotent edit of /etc/wsl.conf that
# keeps whatever else is already in the file.
wsl_conf_set() {
  local section=$1 key=$2 value=$3 file=/etc/wsl.conf
  touch "$file"
  if ! grep -q "^\[$section\]" "$file"; then
    [[ -s "$file" ]] && echo >>"$file"
    printf '[%s]\n%s=%s\n' "$section" "$key" "$value" >>"$file"
  elif sed -n "/^\[$section\]/,/^\[/p" "$file" | grep -q "^$key[[:space:]]*="; then
    sed -i "/^\[$section\]/,/^\[/ s|^$key[[:space:]]*=.*|$key=$value|" "$file"
  else
    sed -i "/^\[$section\]/a $key=$value" "$file"
  fi
}

# Log in straight as the created user (otherwise WSL keeps opening as root)
wsl_conf_set user default "$TARGET_USER"
ok "$(t wsl.default_user "$TARGET_USER")"

# systemd is required by Docker
wsl_conf_set boot systemd true
ok "$(t wsl.systemd)"

# libedit ABI shim — some binaries (e.g. the OpenGL stack) look for libedit.so.2
if [[ -e /usr/lib/libedit.so ]]; then
  ln -sf /usr/lib/libedit.so /usr/lib/libedit.so.2
  ok "$(t wsl.libedit)"
else
  skip "$(t wsl.libedit_skip)"
fi
