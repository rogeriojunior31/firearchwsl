#!/bin/bash
# End-to-end test inside a clean Arch Linux container (no systemd, no WSL).
# Runs the installer twice, unattended, then checks the result.
#
#   On a host with Docker:   bash tests/container.sh
#   Inside the container:    bash tests/container.sh --inside   (used by CI)
#
# Doom Emacs and Docker are skipped: one is slow, the other needs systemd.
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "${1:-}" != "--inside" ]]; then
  # No -t: with a terminal the installer would turn interactive and wait for
  # the questions the env vars below leave open (e.g. the hostname).
  exec docker run --rm -v "$ROOT:/src:ro" archlinux:latest \
    bash -c 'cp -r /src /firearchwsl && bash /firearchwsl/tests/container.sh --inside'
fi

export FIREARCH_LANG=en
export FIREARCH_USER=ci
export FIREARCH_PASSWORD=ci-password
export FIREARCH_GIT_NAME="CI Bot"
export FIREARCH_GIT_EMAIL=ci@example.com
export FIREARCH_SHELL=fish
export FIREARCH_SKIP=doom,docker
export FIREARCH_MISE_TOOLS="node go"

failures=0
check() {
  local label=$1
  shift
  if "$@" &>/dev/null; then
    printf '  \e[32m✔\e[0m %s\n' "$label"
  else
    printf '  \e[31m✖\e[0m %s\n' "$label"
    failures=$((failures + 1))
  fi
}

for run in 1 2; do
  echo "=== installer run $run"
  FIREARCH_LOG="/var/log/firearchwsl/ci-run$run.log" bash "$ROOT/install.sh" --yes
done

echo "=== assertions"
check "user exists and is in wheel"        bash -c 'id -nG ci | grep -qw wheel'
check "sudoers drop-in is valid"           visudo -cf /etc/sudoers.d/10-firearchwsl-wheel
check "password is set (not locked/empty)" bash -c '[[ "$(passwd -S ci | cut -d" " -f2)" == P ]]'
check "default shell is fish"              bash -c '[[ "$(getent passwd ci | cut -d: -f7)" == /usr/bin/fish ]]'
check "WSL default user written"           grep -qx 'default=ci' /etc/wsl.conf
check "locale.conf is en_US"               grep -qx 'LANG=en_US.UTF-8' /etc/locale.conf
check "git identity configured"            bash -c '[[ "$(sudo -Hu ci git config --global user.email)" == ci@example.com ]]'
check "Omarchy is the last repo"           bash -c '[[ "$(grep -E "^\[" /etc/pacman.conf | tail -1)" == "[omarchy]" ]]'
check "rc files installed, owned, 0644"    bash -c '[[ "$(stat -c "%U %a" /home/ci/.bashrc)" == "ci 644" ]]'
check "starship config linked"             test -L /home/ci/.config/starship.toml
check "home folders created, owned by user" bash -c 'for d in Projects Work Notes; do [[ "$(stat -c %U /home/ci/$d)" == ci ]] || exit 1; done'
check "LazyVim cloned"                     test -f /home/ci/.config/nvim/init.lua
check "mise tools installed"               sudo -Hu ci bash -lc 'cd ~ && mise ls --current | grep -q node'
check "fish config loads"                  sudo -Hu ci fish -c 'type -q starship'
check "TUIs installed"                     command -v lazygit
check "firearch command on PATH"           sudo -Hu ci bash -lc 'firearch version | grep -q firearchwsl'
check "firearch speaks the install lang"   bash -c '[[ "$(cat /etc/firearchwsl/lang)" == en ]] && sudo -Hu ci firearch --help | grep -q companion'
check "firearch doctor runs"               bash -c 'sudo -Hu ci firearch doctor | grep -q "DNS resolves"'
check "second run had no failures"         bash -c '! grep -q "^\[FAIL\]" /var/log/firearchwsl/ci-run2.log'
check "second run had no warnings"         bash -c '! grep -q "^\[WARN\]" /var/log/firearchwsl/ci-run2.log'

echo
if ((failures)); then
  printf '\e[31m%d assertion(s) failed\e[0m\n' "$failures"
  echo "--- tail of the second run log"
  tail -n 40 /var/log/firearchwsl/ci-run2.log
  exit 1
fi
printf '\e[32mall assertions passed\e[0m\n'
