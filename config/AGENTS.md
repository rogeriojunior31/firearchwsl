# config/

Post-install configuration. Runs after the packaging phase; copies payloads from `config_files/` and `default/` into the target user's home, and configures Docker.

## Files

- `config.sh` — resolves the target user by reading `getent group wheel` and taking the first non-empty member. Resolves their home via `getent passwd`. Then:
  - Creates `~/.config`, `~/.local/share/firearchwsl/{config,default}`.
  - `cp -R ../config_files/* ~/.local/share/firearchwsl/config/` (note the relative path — CWD must be the repo root when sourced, which is how `install.sh` runs it).
  - `cp ../default/* ~/.local/share/firearchwsl/default/`.
  - Copies `default/config.fish` into `~/.config/fish/config.fish`.
  - Copies `default/bashrc` into `~/.bashrc`.
  - `chown -R` the user on everything it touched.
- `docker.sh` — writes `/etc/docker/daemon.json` with a 10MB / 5-file log cap, a fixed `bip` of `172.17.0.1/16`, and DNS pointing back to the bridge. Then adds `DNSStubListenerExtra=172.17.0.1` via `/etc/systemd/resolved.conf.d/20-docker-dns.conf`, restarts `systemd-resolved`, enables `docker`, adds `${USER}` to the `docker` group, and drops a `no-block-boot.conf` drop-in that sets `DefaultDependencies=no` on `docker.service`. Finishes with `systemctl daemon-reload`.
  - `${USER}` here resolves to root (install.sh is running as root), so in practice the non-root user does NOT end up in the docker group via this script. If you need the non-root user in `docker`, add it explicitly (mirroring `config.sh`'s wheel-detection).

## Conventions here

- The split is intentional: `config_files/` is for things copied verbatim into `~/.local/share/firearchwsl/config/`, `default/` is for rc files also forwarded to their shell-specific paths. Don't merge them.
- Keep `config.sh` the only script that writes into the non-root user's home — it centralizes the `chown` step.
