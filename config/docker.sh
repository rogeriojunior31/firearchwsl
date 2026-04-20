#!/bin/bash

set -Eeuo pipefail

: "${TARGET_USER:?TARGET_USER não definido — rode via install.sh}"

# Configure Docker daemon:
# - limit log size to avoid running out of disk
# - use host's DNS resolver
mkdir -p /etc/docker
tee /etc/docker/daemon.json >/dev/null <<'EOF'
{
    "log-driver": "json-file",
    "log-opts": { "max-size": "10m", "max-file": "5" },
    "dns": ["172.17.0.1"],
    "bip": "172.17.0.1/16"
}
EOF

# Adiciona o usuário-alvo ao grupo docker (idempotente)
if ! id -nG "$TARGET_USER" | tr ' ' '\n' | grep -qx docker; then
  usermod -aG docker "$TARGET_USER"
fi

mkdir -p /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/no-block-boot.conf >/dev/null <<'EOF'
[Unit]
DefaultDependencies=no
EOF

# systemd pode não estar disponível (ex: container sem init). Guard.
if [[ -d /run/systemd/system ]]; then
  mkdir -p /etc/systemd/resolved.conf.d
  echo -e '[Resolve]\nDNSStubListenerExtra=172.17.0.1' >/etc/systemd/resolved.conf.d/20-docker-dns.conf
  systemctl restart systemd-resolved || warn "systemd-resolved restart falhou — revise manualmente."
  systemctl enable docker || warn "systemctl enable docker falhou."
  systemctl daemon-reload
else
  warn "systemd não detectado (sem /run/systemd/system) — pulando enable/restart de docker."
fi
