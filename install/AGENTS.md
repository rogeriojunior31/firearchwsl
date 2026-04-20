# install/

Everything `install.sh` sources during the bootstrap proper. Split into two phases:

- `preflights/` — runs before any optional packages. Error trap, repositories, mise, bare essentials.
- `pkgs/` — package groups layered on top of the preflight base.

See `preflights/AGENTS.md` and `pkgs/AGENTS.md` for per-file notes.

## Ordering contract

`install.sh` sources preflights before pkgs. Within pkgs the order is `good-tools.sh` → `tuis.sh` → `install_langs.sh` → `editors.sh`. `editors.sh` relies on `git` and `~/.config/nvim` being writable by the current user context — don't move it earlier.

## Adding a new package group

1. Create `pkgs/<name>.sh` modeled on `good-tools.sh`: `set -Eeuo pipefail`, `PACMAN_PKGS=()`, `msg/warn/die` helpers, `main()`.
2. Add `source $FIREARCH_INSTALL/pkgs/<name>.sh` to `install.sh` in the right phase slot.
3. Keep the array grouped by intent; don't merge into an existing file unless the packages are of the same kind.
