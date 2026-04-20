<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# system

## Purpose

System-level configuration scripts: touch `/etc/*` or create users/groups. All sourced by `install.sh` as root during the preparation phase.

## Key Files

| File | Description |
|------|-------------|
| `create_your_user.sh` | Interactive. Prompts for a username, runs `useradd -m -G wheel -s /bin/bash`, `passwd`, then uncomments `%wheel ALL=(ALL) ALL` in `/etc/sudoers`. Refuses if not root; exits early if the user already exists. Downstream contract: everything after assumes exactly one non-root user in `wheel`. |
| `configure_locale.sh` | Installs `glibc`, uncomments `pt_BR.UTF-8 UTF-8` and `en_US.UTF-8 UTF-8` in `/etc/locale.gen` (falls back to appending if the line is absent), runs `locale-gen`, writes `/etc/locale.conf` with `LANG=pt_BR.UTF-8`, `LANGUAGE=pt_BR:en_US`, `LC_ALL=`. |
| `wsl_config.sh` | One-liner: symlinks `/usr/lib/libedit.so` → `libedit.so.2`. Commented "OpenGL"; WSL-specific shim. |
| `configure_git_user.sh` | Interactive. `git config --global` for `user.name` / `user.email`. Sets `init.defaultBranch=main`, `pull.rebase=true`, aliases `co`, `br`, `ci`, `st`. `set -euo pipefail`; validation is intentionally light. |

## For AI Agents

### Working In This Directory

- Root-required scripts use `if [[ $EUID -ne 0 ]]; then ... exit 1; fi` at the top.
- Interactive prompts (`read -rp`) are the norm — these files are for first-time bootstrap, not unattended reruns.
- `create_your_user.sh` is the pivot point: `config/config.sh` later resolves the target home via `getent group wheel` and takes the first member, so this script must put exactly one user in `wheel`.

### Testing Requirements

- `create_your_user.sh`: verify `id <user>`, `groups <user>` contains `wheel`, and `sudo -l -U <user>` shows `(ALL) ALL`.
- `configure_locale.sh`: `locale -a | grep pt_BR.utf8` should match; `/etc/locale.conf` should carry `LANG=pt_BR.UTF-8`.
- `configure_git_user.sh`: `git config --global --list` should show the name/email and the four aliases.

### Common Patterns

- When adding a new system script, append it to `install.sh` in the preparation phase (between `create_your_user.sh` and `install-mise.sh`). Ordering matters because mise and the packaging phase both key off the non-root user existing.

## Dependencies

### Internal

- Sourced by `../install.sh` in the preparation phase.
- `../config/config.sh` consumes the `wheel` membership set here.

### External

- `useradd`, `passwd`, `sudo`, `locale-gen`, `git`, `sed`, `pacman`.

<!-- MANUAL: -->
