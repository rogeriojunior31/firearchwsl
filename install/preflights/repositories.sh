#!/bin/bash
# Extra repositories: Omarchy + Chaotic-AUR, colored pacman, global mirrors.
# Every edit to /etc/pacman.conf is grep-guarded (re-runs never duplicate).

CHAOTIC_KEY=3056513887B78AEB

# Color, the "pacman eating" progress bar and verbose package lists
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sed -i '/^\[options\]/a Color\nILoveCandy\nVerbosePkgLists' /etc/pacman.conf
fi
ok "$(t repo.candy)"

# Omarchy
if ! grep -q '^\[omarchy\]' /etc/pacman.conf; then
  printf '\n[omarchy]\nSigLevel = Optional TrustAll\nServer = https://pkgs.omarchy.org/$arch/\n' >>/etc/pacman.conf
fi
ok "$(t repo.omarchy)"

# Global (geo-balanced) mirrors only
printf '%s\n' \
  'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' \
  'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch' \
  >/etc/pacman.d/mirrorlist
ok "$(t repo.mirrors)"

# Chaotic-AUR is x86_64 only (on ARM the packages get built locally)
setup_chaotic_keyring() {
  if ! pacman-key --list-keys "$CHAOTIC_KEY" &>/dev/null; then
    pacman-key --recv-key "$CHAOTIC_KEY" --keyserver keyserver.ubuntu.com || return 1
    pacman-key --lsign-key "$CHAOTIC_KEY" || return 1
  fi
  pacman -U --noconfirm --needed \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
}

if [[ -n "${DISABLE_CHAOTIC:-}" ]]; then
  skip "$(t repo.chaotic_disabled)"
elif [[ "$(uname -m)" != "x86_64" ]]; then
  skip "$(t repo.chaotic_arch)"
elif grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
  ok "$(t repo.chaotic_already)"
elif run "$(t repo.chaotic_setup)" setup_chaotic_keyring; then
  printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' >>/etc/pacman.conf
  ok "$(t repo.chaotic_ok)"
else
  warn "$(t repo.chaotic_fail)"
fi

run "$(t repo.sync)" pacman -Syu --noconfirm
