# firearchwsl

Automated bootstrap for an Arch Linux WSL2 environment: creates a non-root user, installs a curated toolchain, and lays down shell/terminal configs.

Author: Rogerio Junior. Script language is Portuguese (pt_BR); logs/prompts speak to the user in Portuguese.

## Entry point

`install.sh` is the single orchestrator. It runs as root on a fresh Arch WSL distro and sequences every subscript with `source` so all exports/functions stay in one process. It sets `set -eE` and installs an `ERR` trap from `install/preflights/trap-errors.sh` so any failure prints the failing command and suggests rerunning.

Run order (do not reshuffle without understanding dependencies):

1. `pacman -Syu` — initial sync.
2. Preparation phase:
   - `install/preflights/trap-errors.sh` — error trap.
   - `system/create_your_user.sh` — interactive new user + sudoers.
   - `system/configure_locale.sh` — pt_BR.UTF-8 / en_US.UTF-8 locales.
   - `system/wsl_config.sh` — `libedit.so.2` symlink (OpenGL).
   - `install/preflights/essentials_pkgs.sh` — minimum tools needed before anything else runs.
   - `system/configure_git_user.sh` — prompts for git name/email and sets aliases.
   - `install/preflights/repositories.sh` — pacman cosmetics + Omarchy + Chaotic-AUR.
   - `install/preflights/install-mise.sh` — installs mise and wires shell activation.
3. Packaging phase:
   - `install/pkgs/good-tools.sh` — core CLI utilities.
   - `install/pkgs/tuis.sh` — terminal UI apps (lazygit, yazi, atuin, …).
   - `install/pkgs/install_langs.sh` — languages via mise (python, node, bun, rust, go).
   - `install/pkgs/editors.sh` — LazyVim + Doom Emacs.
4. Config phase:
   - `config/config.sh` — copies `config_files/` and `default/` into target user's home.
   - `config/docker.sh` — Docker daemon, DNS and systemd unit wiring.
5. Final phase — clears screen, animates `logo.txt` via `tte` (terminaltexteffects), prints a message telling the user to `wsl --terminate archlinux`.

## Layout

```
firearchwsl/
├─ install.sh              # top-level orchestrator (run as root)
├─ logo.txt                # ASCII banner rendered by tte on finish
├─ install/
│  ├─ preflights/          # bootstrap steps that must run before packaging
│  └─ pkgs/                # package groups installed via pacman / mise
├─ system/                 # system-level configuration (user, locale, git, wsl)
├─ config/                 # post-install configuration copiers
├─ config_files/           # verbatim config payloads (e.g. starship.toml)
└─ default/                # default shell rc files (bashrc, config.fish)
```

Each subdirectory has its own `AGENTS.md` with per-file notes.

## Conventions

- **Shell**: all scripts are `#!/bin/bash`. Prefer `set -Eeuo pipefail` in new scripts (as in `good-tools.sh`, `tuis.sh`, `essentials_pkgs.sh`). `install.sh` itself uses `set -eE` so the `ERR` trap fires.
- **Language**: user-facing `echo`/`printf` strings are Portuguese. Keep that tone in new additions.
- **Logging helpers**: reuse the `msg` / `warn` / `die` trio (green/yellow/red ANSI). Duplicated across scripts by design — each script is sourceable and self-contained.
- **Privilege**: most scripts assume root (run via `install.sh`). Scripts that refuse to run outside root guard with `if [[ $EUID -ne 0 ]]`. `config.sh` detects the target non-root user by reading the `wheel` group.
- **Idempotency**: `pacman -S --needed --noconfirm`, `mkdir -p`, `grep -q` guards, and `if [[ ! -d ... ]]` checks are the pattern. New steps should follow suit so reruns don't break.
- **Package lists**: each `install/pkgs/*.sh` keeps its own `PACMAN_PKGS=()` array. Group by intent (CLI utilities vs TUIs), don't consolidate.
- **Path assumptions**: `install.sh` uses relative paths (`./install`, `./system`, `./config`). Run from repo root. `config/config.sh` uses `../config_files` and `../default`, so it expects to be sourced while CWD is the repo root.

## Not in this repo

- `install.sh` is invoked against a fresh Arch WSL image; it does not install the WSL distro itself.
- There are no tests, no CI, and no lint config. Changes are verified by re-running `install.sh` in a throwaway WSL distro.
