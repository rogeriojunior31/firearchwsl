<!-- Parent: ../AGENTS.md -->

# config

## Purpose

Post-install configuration. Runs after the packaging phase: copies `config_files/` and `default/` payloads into the target user's home, sets the default shell, and sets up Docker.

## Key Files

| File | Description |
|------|-------------|
| `config.sh` | Copies `config_files/*` → `~/.local/share/firearchwsl/config/` and `default/*` → `~/.local/share/firearchwsl/default/` (always overwritten). `install_rc` then installs `bashrc` → `~/.bashrc` and `config.fish` → `~/.config/fish/config.fish`: copies when missing/identical, preserves local edits by default, or backs up (`.bak-<timestamp>`) and overwrites with `FORCE_CONFIG=1`. A `~/.bashrc` identical to `/etc/skel/.bashrc` counts as untouched. Symlinks `~/.config/starship.toml`. Chowns to the target user. Sets the default shell from `FIREARCH_SHELL` via `usermod -s`. |
| `docker.sh` | Optional component `docker`. Installs `docker`, `docker-buildx`, `docker-compose`; writes `/etc/docker/daemon.json` (log cap 10 MB × 5) only if absent; adds the target user to the `docker` group; `systemctl enable --now docker` when systemd is running. |

## For AI Agents

### Working In This Directory

- `config.sh` is the only script that writes rc files into the user's home and it centralizes the `chown -R`. Keep that invariant.
- `config_files/` is copied only to the share dir; `default/` is also forwarded to shell rc paths. Don't merge them.
- Docker DNS: do not add `dns`/`bip` overrides to `daemon.json`. Docker inherits the WSL resolver from `/etc/resolv.conf`; pointing containers at a `systemd-resolved` stub breaks DNS after a WSL restart because `systemd-resolved` is not enabled on WSL.
- The `docker` group membership only applies after `wsl --terminate <distro>`.
- `cmp` comes from `diffutils`, which the fresh WSL image lacks — it is installed by `essentials_pkgs.sh`.

### Testing Requirements

- As the target user: `~/.bashrc`, `~/.config/fish/config.fish` and `~/.local/share/firearchwsl/` exist and are owned by the user.
- Edit `~/.bashrc`, re-run: the edit survives. Re-run with `FORCE_CONFIG=1`: overwritten, backup created.
- `systemctl is-active docker` → `active`; `docker run --rm alpine nslookup archlinux.org` resolves.

## Dependencies

- `../config_files/*`, `../default/*`, `../system/create_your_user.sh` (target user).
- `usermod`, `chown`, `cmp`, `systemctl`, `docker`.
