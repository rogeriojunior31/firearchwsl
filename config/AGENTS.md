<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# config

## Purpose

Post-install configuration. Runs after the packaging phase. Copies `config_files/` and `default/` payloads into the target non-root user's home, and wires Docker daemon + systemd.

## Key Files

| File | Description |
|------|-------------|
| `config.sh` | Resolves the target user via `getent group wheel` (first non-empty member) and their home via `getent passwd`. Creates `~/.config`, `~/.local/share/firearchwsl/{config,default}`. Copies `../config_files/*` and `../default/*` into those dirs. Installs `default/config.fish` → `~/.config/fish/config.fish` and `default/bashrc` → `~/.bashrc`. Chowns everything to the resolved user. Relative path `../config_files` requires CWD == repo root when sourced. |
| `docker.sh` | Writes `/etc/docker/daemon.json` with 10MB / 5-file log cap, `bip=172.17.0.1/16`, and DNS pointing back at the bridge. Drops `/etc/systemd/resolved.conf.d/20-docker-dns.conf` (`DNSStubListenerExtra=172.17.0.1`), restarts `systemd-resolved`, enables `docker`, adds `${USER}` to `docker` group, writes `docker.service.d/no-block-boot.conf` (`DefaultDependencies=no`), `systemctl daemon-reload`. Note: `${USER}` resolves to root here (install.sh runs as root), so the non-root user is NOT added to `docker` — fix if that's the intent. |

## For AI Agents

### Working In This Directory

- `config.sh` is the only script that writes into the non-root user's home — it centralizes the `chown -R`. Keep that invariant.
- Split between `../config_files/` and `../default/` is intentional: `config_files/` is copied only to `~/.local/share/firearchwsl/config/`; `default/` is also forwarded to shell-specific rc paths. Don't merge.
- If you need the non-root user in a supplementary group, mirror `config.sh`'s `getent group wheel` pattern — do not rely on `$USER`.

### Testing Requirements

- After running, on the target user: `ls -la ~/.bashrc ~/.config/fish/config.fish ~/.local/share/firearchwsl/` — all owned by the user, bashrc and config.fish match the `default/` versions.
- After docker.sh: `systemctl is-enabled docker` → `enabled`; `cat /etc/docker/daemon.json` matches; docker network subnet is `172.17.0.1/16`.

### Common Patterns

- Use `getent` rather than hard-coding usernames.
- `sudo tee <<'EOF'` heredocs for writing system config files (quoted `'EOF'` to prevent variable expansion).

## Dependencies

### Internal

- `../config_files/*` — opaque config payloads.
- `../default/*` — shell rc templates.
- `../system/create_your_user.sh` — must run first so the `wheel` user exists.

### External

- `getent`, `chown`, `systemctl`, `docker`, `systemd-resolved`.

<!-- MANUAL: -->
