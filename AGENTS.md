# firearchwsl

## Purpose

Automated bootstrap for an Arch Linux WSL2 environment. Runs as root on a fresh Arch WSL distro: asks everything up front (language, user, git identity, shell, optional components), then runs unattended — creates the non-root user, configures locale/WSL/git, installs a curated pacman + Chaotic-AUR + mise toolchain, and lays down shell (bash, fish) and terminal configs. The installer UI is multilingual (`pt_BR`, `en`). Author: Rogerio Junior.

## Key Files

| File | Description |
|------|-------------|
| `install.sh` | Orchestrator and only entry point. `set -Eeuo pipefail`. Loads `lib.sh`, picks the language, runs step 1 (base sync), sources `wizard.sh`, then sources every step script from the `STEPS` array in fixed order, then `finale.sh`. |
| `logo.txt` | ASCII banner. Printed with a color gradient at start; animated by `tte` at the end. |
| `README.md` | User documentation (Portuguese). |
| `.gitattributes` | Forces LF. CRLF breaks bash/fish when the repo is run from `/mnt/c`. |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `install/` | i18n catalogs, preflights (lib, UI, wizard) and package groups (see `install/AGENTS.md`) |
| `system/` | System-level config: user, locale, git, `/etc/wsl.conf` (see `system/AGENTS.md`) |
| `config/` | User rc files + Docker (see `config/AGENTS.md`) |
| `config_files/` | Verbatim config payloads (see `config_files/AGENTS.md`) |
| `default/` | Default bash / fish rc files (see `default/AGENTS.md`) |

## For AI Agents

### Hard rules

- **Code, identifiers and comments are English.** No Portuguese in `.sh` files outside `install/i18n/pt_BR.sh`.
- **No hard-coded user-facing text.** Every string shown to the user goes through `t <key> [args]` and lives in `install/i18n/en.sh` (reference) plus each other catalog. Adding a key means adding it to **every** catalog.
- **Entry point is always `install.sh`.** Step scripts are sourced, not executed — use `return`, never `exit`, to leave early. User-scoped scripts guard with `: "${TARGET_USER:?…}"`.
- **Slow or noisy commands go through `run "label" cmd…`** (spinner on a TTY, output to the log file). Never print raw command output to the screen.
- **Step scripts ask nothing.** All prompts live in `install/preflights/wizard.sh`; every answer has a `FIREARCH_*` env var so the installer can run unattended.
- **The user always chooses their name and password.** Never create a user without a password; without a terminal, a missing `FIREARCH_PASSWORD` for a new user is a hard stop.

### Working In This Directory

- `install.sh` exports `FIREARCH_ROOT`; scripts reference payloads as `$FIREARCH_ROOT/...`.
- Step order in the `STEPS` array is load-bearing: base → *wizard* → user → locale → wsl → essentials → git → repositories → mise → good-tools → tuis → langs → editors → config → docker. `UI_STEP_TOTAL` must equal the number of `step` calls (14).
- `TARGET_USER` / `TARGET_HOME` are exported by `system/create_your_user.sh`. Single source of truth on re-runs: `/etc/firearchwsl/target_user`.
- User-scoped commands use `as_user <cmd>` (from `lib.sh`); never `$HOME`/`$USER` (those are root's).
- Non-fatal steps: `run … || warn "$(t …)"`. Warnings are collected and repeated in the final summary. Fatal: let the `ERR` trap fire (it prints step, command and log tail).
- Optional components (`langs`, `lazyvim`, `doom`, `docker`) are gated by `component_enabled <name>`, driven by `FIREARCH_SKIP`.
- No rollback: a mid-run failure leaves partial state. Every step must be idempotent so a re-run is safe.

### Testing Requirements

- No CI. Before committing: `bash -n` on every changed `.sh`; `shellcheck -x` if available; `fish -n default/config.fish`.
- `bash install.sh --help` proves the catalogs load.
- Real validation: fresh Arch WSL + unattended run, then a second run that must not abort:
  `FIREARCH_LANG=en FIREARCH_USER=test bash install.sh --yes`
- Spinner/TTY paths can be exercised without a terminal via `script -qec 'bash …' /dev/null`.

### Common Patterns

- `PACMAN_PKGS=()` array per package file, grouped by intent, installed with `pac_install "$(t …)" "${PACMAN_PKGS[@]}"`.
- `pacman -Syu` only in two places: step 1 in `install.sh` and the end of `repositories.sh`. Everything else is `-S --needed --noconfirm`.
- Idempotency guards before mutating `/etc` (`grep -q` on `pacman.conf`, `wsl_conf_set`, `visudo -cf` on the sudoers drop-in, group checks before `usermod`).

## Dependencies

### External

- `pacman`; Omarchy repo and Chaotic-AUR (added by `install/preflights/repositories.sh`).
- `gum` — interactive prompts (installed in step 1 when a TTY is present; plain `read` fallback).
- `mise` — language toolchains. `tte` (python-terminaltexteffects) — finale animation.
- LazyVim starter and doomemacs — cloned by `install/pkgs/editors.sh`.
