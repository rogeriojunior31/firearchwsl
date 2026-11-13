#!/bin/bash
# Native Docker on WSL: packages, daemon.json, docker group, systemd service.

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"

if ! component_enabled docker; then
  skip "$(t docker.skip)"
  return 0
fi

PACMAN_PKGS=(
  "docker"
  "docker-buildx"
  "docker-compose"
)

pac_install "$(t docker.install)" "${PACMAN_PKGS[@]}"

# Cap log size so containers cannot fill the disk.
# DNS: Docker inherits the WSL resolver (/etc/resolv.conf) — nothing to set.
if [[ ! -e /etc/docker/daemon.json ]]; then
  mkdir -p /etc/docker
  printf '%s\n' \
    '{' \
    '    "log-driver": "json-file",' \
    '    "log-opts": { "max-size": "10m", "max-file": "5" }' \
    '}' >/etc/docker/daemon.json
  ok "$(t docker.daemon_new)"
else
  ok "$(t docker.daemon_keep)"
fi

# Target user in the docker group (idempotent)
if id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx docker; then
  ok "$(t docker.group_already "$TARGET_USER")"
else
  run "$(t docker.group_add "$TARGET_USER")" usermod -aG docker "$TARGET_USER"
fi

# systemd may be unavailable (container without init, or WSL without systemd)
if [[ -d /run/systemd/system ]]; then
  run "$(t docker.enable)" systemctl enable --now docker || warn "$(t docker.enable_fail)"
else
  warn "$(t docker.no_systemd)"
fi
