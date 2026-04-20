<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# install

## Purpose

Everything `install.sh` sources during the bootstrap proper. Two phases: `preflights/` prepares the base system (error trap, repos, mise, essentials) and `pkgs/` layers curated package groups on top.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `preflights/` | Error trap, essentials, repo setup, mise bootstrap (see `preflights/AGENTS.md`) |
| `pkgs/` | CLI tools, TUIs, language toolchains, editors (see `pkgs/AGENTS.md`) |

## For AI Agents

### Working In This Directory

- Ordering contract (enforced by `install.sh`): all `preflights/*` run before any `pkgs/*`. Within `pkgs/`: `good-tools.sh` → `tuis.sh` → `install_langs.sh` → `editors.sh`. `editors.sh` relies on `git` and writable home dirs established earlier — don't move it up.
- Every script here is sourced (not exec'd) by `install.sh`, so `exit` terminates the whole installer. Prefer `return 1` in helpers you don't want fatal.

### Testing Requirements

- Re-run the full `install.sh` on a fresh Arch WSL distro. `--needed --noconfirm` flags on `pacman` make the package phase idempotent.

### Common Patterns

- Each pkg file owns its own `PACMAN_PKGS=()` array. Keep groups narrow (CLI vs TUI vs langs vs editors).
- Reuse the `msg` / `warn` / `die` trio and the `ensure_sudo` helper when adding a new group.

### Adding a new package group

1. Create `pkgs/<name>.sh` modeled on `good-tools.sh` (set flags, array, helpers, `main`, `main "$@"`).
2. Add `source $FIREARCH_INSTALL/pkgs/<name>.sh` to `install.sh` in the right phase slot.
3. Do not merge into an existing file unless the new packages share the same intent.

## Dependencies

### Internal

- `../install.sh` — orchestrator that sources these scripts.
- `../system/*` — system config scripts that run between preflights and pkgs in the main `install.sh`.

### External

- `pacman`, `yay`, `paru`, `mise`.

<!-- MANUAL: -->
