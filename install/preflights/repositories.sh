#!/bin/bash
# Extra repositories: Chaotic-AUR + Omarchy, colored pacman, global mirrors.
# Every edit to /etc/pacman.conf is idempotent (re-runs never duplicate).

CHAOTIC_KEY=3056513887B78AEB
MIRRORLIST=/etc/pacman.d/mirrorlist
MIRRORLIST_BACKUP=/etc/pacman.d/mirrorlist.firearchwsl.bak

# Color, the "pacman eating" progress bar and verbose package lists
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sed -i '/^\[options\]/a Color\nILoveCandy\nVerbosePkgLists' /etc/pacman.conf
fi
ok "$(t repo.candy)"

# Global (geo-balanced) mirrors only. The original list is kept once.
if [[ ! -e "$MIRRORLIST_BACKUP" ]]; then
  cp -p "$MIRRORLIST" "$MIRRORLIST_BACKUP"
fi
printf '%s\n' \
  'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' \
  'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch' \
  >"$MIRRORLIST"
ok "$(t repo.mirrors "$MIRRORLIST_BACKUP")"

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

# Omarchy is signature-less (SigLevel = Optional TrustAll), so it must be the
# LAST repo: pacman takes a package from the first repo that has it, and this
# way Omarchy only supplies what no signed repo carries (e.g.
# python-terminaltexteffects). The section is stripped and re-appended on
# every run, which also fixes installs where it was added before Chaotic-AUR.
place_omarchy_last() {
  local conf=/etc/pacman.conf tmp
  tmp="$(mktemp)"
  # Drop the [omarchy] section and trailing blank lines, keep everything else.
  awk '
    /^\[omarchy\][[:space:]]*$/ { skip = 1; next }
    /^\[/                       { skip = 0 }
    skip                        { next }
    /^[[:space:]]*$/            { blank++; next }
                                { while (blank > 0) { print ""; blank-- } print }
  ' "$conf" >"$tmp"
  printf '\n[omarchy]\nSigLevel = Optional TrustAll\nServer = https://pkgs.omarchy.org/$arch/\n' >>"$tmp"
  cat "$tmp" >"$conf" # keeps the original file mode and owner
  rm -f "$tmp"
}
place_omarchy_last
ok "$(t repo.omarchy)"

run "$(t repo.sync)" pacman -Syu --noconfirm
