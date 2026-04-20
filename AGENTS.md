<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# firearchwsl

## Purpose

Automated bootstrap for an Arch Linux WSL2 environment. Runs as root on a fresh Arch WSL distro, creates a non-root user, configures locale/git/mise, installs a curated pacman + AUR + mise toolchain, and lays down shell (bash, fish) and terminal (starship, zellij, yazi, lazygit, etc.) configs. User-facing output is in Portuguese (pt_BR). Author: Rogerio Junior.

## Key Files

| File | Description |
|------|-------------|
| `install.sh` | Top-level orchestrator. `set -eE`, sources every preflight / pkg / config script in fixed order. Finishes with a `tte` animation of `logo.txt` and prompts the user to `wsl --terminate archlinux`. |
| `logo.txt` | ASCII banner ("FIREARCHWSL") rendered by `tte` (python-terminaltexteffects) on install completion. |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `install/` | Preflight steps and package groups (see `install/AGENTS.md`) |
| `system/` | System-level config: user, locale, git, WSL shims (see `system/AGENTS.md`) |
| `config/` | Post-install config copiers + Docker daemon wiring (see `config/AGENTS.md`) |
| `config_files/` | Verbatim config payloads (starship.toml) (see `config_files/AGENTS.md`) |
| `default/` | Default bash / fish rc files (see `default/AGENTS.md`) |

## For AI Agents

### Working In This Directory

- `install.sh` must remain runnable from the repo root — subscripts use relative paths (`./install`, `./system`, `./config`, and `config/config.sh` uses `../config_files`, `../default`). Do not change CWD mid-run.
- Script order in `install.sh` is load-bearing. Summary: `pacman -Syu` → trap → user → locale → wsl → essentials → git-user → repositories → mise → good-tools → tuis → langs → editors → config → docker. Do not reshuffle without understanding each dependency.
- User-facing strings (`echo`, `printf`, `read -rp`) are Portuguese. Preserve that tone.
- Scripts are `#!/bin/bash`. New scripts should start with `set -Eeuo pipefail`; `install.sh` itself uses `set -eE` so the `ERR` trap fires.
- Log helpers `msg` (green) / `warn` (yellow) / `die` (red) are duplicated across files on purpose so each is self-sourceable.

### Testing Requirements

- No tests, no CI, no lint config. Validation is: spin up a fresh Arch WSL distro and re-run `install.sh`. Scripts are designed to be idempotent (`--needed`, `mkdir -p`, `grep -q` guards, `[[ ! -d ... ]]`) — reruns should be safe.

### Common Patterns

- `PACMAN_PKGS=()` arrays grouped by intent (one per pkg file). Do not consolidate across groups.
- Idempotency checks before mutating `/etc` (e.g. `grep -q "chaotic-aur" /etc/pacman.conf`).
- Root-required scripts guard with `if [[ $EUID -ne 0 ]]`.
- Interactive `read -rp` for values that must come from the human (username, git name/email).

## Dependencies

### External

- `pacman` — base Arch package manager.
- Omarchy repo (`https://pkgs.omarchy.org/`) and Chaotic-AUR — extra package sources added by `install/preflights/repositories.sh`.
- `mise` — polyglot language version manager (python, node, bun, rust, go).
- `tte` (python-terminaltexteffects) — renders the finale banner.
- LazyVim starter and doomemacs — cloned by `install/pkgs/editors.sh`.

<!-- MANUAL: Any manually added notes below this line are preserved on regeneration -->
