# system/

System-level configuration: scripts that touch `/etc/*` or create users/groups. All sourced by `install.sh` as root.

## Files

- `create_your_user.sh` — interactive. `read -rp` prompts for a username, `useradd -m -G wheel -s /bin/bash`, `passwd`, then uncomments `%wheel ALL=(ALL) ALL` in `/etc/sudoers`. Refuses to run if not root. Exits early if the user already exists.
  - Downstream contract: everything after this assumes exactly one non-root user in `wheel`. `config/config.sh` relies on that to discover the target home directory.
- `configure_locale.sh` — installs `glibc`, uncomments `pt_BR.UTF-8 UTF-8` and `en_US.UTF-8 UTF-8` in `/etc/locale.gen` (falling back to appending if the line is absent), runs `locale-gen`, and writes `/etc/locale.conf` with `LANG=pt_BR.UTF-8`, `LANGUAGE=pt_BR:en_US`.
- `wsl_config.sh` — one-liner: symlinks `/usr/lib/libedit.so` → `libedit.so.2`. Comment says "OpenGL"; this is the WSL-specific shim.
- `configure_git_user.sh` — interactive `git config --global` for `user.name` / `user.email`. Also sets `init.defaultBranch=main`, `pull.rebase=true`, and aliases `co`, `br`, `ci`, `st`. Runs with `set -euo pipefail`, so a blank name/email will proceed — validation is light on purpose.

## Conventions here

- Scripts that hard-require root use `if [[ $EUID -ne 0 ]]; then ... exit 1; fi` at the top.
- Interactive prompts (`read -rp`) are the norm — these files are for first-time bootstrap, not unattended reruns.
- When adding a new system script, append it to `install.sh` in the preparation phase (between `create_your_user.sh` and `install-mise.sh`); ordering matters because mise and the packaging phase both key off the non-root user existing.
