#!/bin/bash
# Copies payloads (config_files/, default/) into the target user's home,
# installs the rc files and sets the default shell.

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"
: "${TARGET_HOME:?TARGET_HOME not set — run through install.sh}"

# Repo root — from FIREARCH_ROOT (exported by install.sh), with a fallback
FIREARCH_ROOT="${FIREARCH_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

_share="$TARGET_HOME/.local/share/firearchwsl"
mkdir -p "$TARGET_HOME/.config/fish" "$_share/config" "$_share/default"

# Keep the defaults installed by the previous run: an rc file still equal to
# them was never edited by the user, so it can safely be upgraded.
_previous="$(mktemp -d)"
cp -p "$_share/default/"* "$_previous/" 2>/dev/null || true

# Versioned payloads — always overwritten (the repo is the source of truth)
cp -R "$FIREARCH_ROOT/config_files/"* "$_share/config/"
cp "$FIREARCH_ROOT/default/"* "$_share/default/"
# Payloads are data, not executables (a /mnt/c checkout marks everything 0777)
find "$_share" -type f -exec chmod 0644 {} +
ok "$(t cfg.payloads)"

# install_rc <source> <destination>
#   destination missing / identical         → copy
#   destination equals the previous default → upgrade (never edited)
#   destination differs                     → keep it (default), or back it
#                                             up and overwrite (FORCE_CONFIG=1)
install_rc() {
  local src=$1 dest=$2 name="~${2#"$TARGET_HOME"}"
  local previous="$_previous/$(basename "$src")"
  if [[ ! -e "$dest" ]]; then
    install -m 0644 "$src" "$dest"
    ok "$(t cfg.rc_installed "$name")"
  elif cmp -s "$src" "$dest"; then
    chmod 0644 "$dest"
    ok "$(t cfg.rc_current "$name")"
  elif [[ -e "$previous" ]] && cmp -s "$previous" "$dest"; then
    install -m 0644 "$src" "$dest"
    ok "$(t cfg.rc_updated "$name")"
  elif [[ "${FORCE_CONFIG:-}" == "1" ]]; then
    local backup
    backup="$dest.bak-$(date +%Y%m%d-%H%M%S)"
    cp -p "$dest" "$backup"
    install -m 0644 "$src" "$dest"
    ok "$(t cfg.rc_overwritten "$name" "~${backup#"$TARGET_HOME"}")"
  else
    skip "$(t cfg.rc_preserved "$name")"
  fi
}

# A ~/.bashrc identical to /etc/skel (fresh from useradd) is not a local edit
if [[ -e "$TARGET_HOME/.bashrc" ]] && cmp -s "$TARGET_HOME/.bashrc" /etc/skel/.bashrc; then
  rm -f "$TARGET_HOME/.bashrc"
fi

install_rc "$_share/default/bashrc" "$TARGET_HOME/.bashrc"
install_rc "$_share/default/config.fish" "$TARGET_HOME/.config/fish/config.fish"

# Starship: symlink to the versioned toml (the canonical path starship reads)
ln -sf "$_share/config/starship.toml" "$TARGET_HOME/.config/starship.toml"
ok "$(t cfg.starship)"

# Everything written here belongs to the target user
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.local"
chown -h "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/starship.toml"
[[ -e "$TARGET_HOME/.bashrc" ]] && chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.bashrc"

# Default shell (picked in the questionnaire)
_shell_name="${FIREARCH_SHELL:-bash}"
_shell_path="/usr/bin/$_shell_name"
if [[ ! -x "$_shell_path" ]]; then
  warn "$(t cfg.shell_missing "$_shell_path")"
elif [[ "$(getent passwd "$TARGET_USER" | cut -d: -f7)" == "$_shell_path" ]]; then
  ok "$(t cfg.shell_already "$_shell_name")"
else
  run "$(t cfg.shell_set "$_shell_name")" usermod -s "$_shell_path" "$TARGET_USER"
fi
rm -rf "$_previous"
unset _share _previous _shell_name _shell_path
