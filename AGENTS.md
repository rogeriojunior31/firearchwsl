# firearchwsl

## Purpose

Automated bootstrap for an Arch Linux WSL2 environment. Runs as root on a fresh Arch WSL distro: asks everything up front (language, user, git identity, shell, optional components), then runs unattended — creates the non-root user, configures locale/WSL/git, installs a curated pacman + Chaotic-AUR + mise toolchain, and lays down shell (bash, fish) and terminal configs. The installer UI is multilingual (`pt_BR`, `en`). Author: Rogerio Junior.

## Key Files

| File | Description |
|------|-------------|
| `install.sh` | Orchestrator and only entry point. `set -Eeuo pipefail`. Loads `lib.sh`, picks the language, runs step 1 (base sync), sources `wizard.sh`, then sources every step script from the `STEPS` array in fixed order, then `finale.sh`. |
| `logo.txt` | ASCII banner. Printed with a color gradient at start; animated by `tte` at the end. |
| `bootstrap.ps1` | Windows entry point. Installs the Arch distro (`wsl --install archlinux --name`), fetches the repo into `/opt/firearchwsl` (git clone, or `-Source` local copy), runs `install.sh` as root, restarts the distro. Must stay compatible with Windows PowerShell 5.1 (no `??`, no ternary) and **pure ASCII without a BOM**: `irm | iex` keeps a BOM as a stray U+FEFF that breaks parsing, and 5.1 reads BOM-less non-ASCII as ANSI. Accents go in as `\uXXXX` and are decoded by `Msg` (`[regex]::Unescape`). `tests/check.sh` enforces it. Distro/repo/branch can also come from `FIREARCH_DISTRO`/`FIREARCH_REPO`/`FIREARCH_BRANCH`, since `irm | iex` cannot pass parameters. |
| `README.md` / `README.en.md` | User documentation (Portuguese / English). Keep both in sync. |
| `tests/check.sh` | Static checks: `bash -n`, shellcheck, `fish -n`, i18n key/placeholder parity, LF endings. |
| `tests/container.sh` | End-to-end: installer twice in a clean `archlinux` container + assertions. `--inside` is what CI runs. |
| `.github/workflows/ci.yml` | Runs both tests on push to `main`, PRs and manual dispatch. |
| `.shellcheckrc` | `external-sources=true`, `SC2034` off (globals are shared across sourced files). |
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

- Before committing: `bash tests/check.sh` (must print "all checks passed"). Without a local shellcheck: `docker run --rm -v "$PWD:/mnt:ro" -w /mnt koalaman/shellcheck:stable -x -S warning $(git ls-files '*.sh')`.
- End-to-end without touching any WSL distro: `bash tests/container.sh` (Docker).
- On real WSL without touching the user's distro: `.\bootstrap.ps1 -Name firearch-test -Source .`, then `wsl --unregister firearch-test`.
- Spinner/TTY paths can be exercised without a terminal via `script -qec 'bash …' /dev/null`.
- Driving WSL from PowerShell: put the Linux commands in a script file and run `wsl -d <distro> -- bash <file>`. Never build compound `bash -c "…"` strings in PowerShell: `wsl.exe` re-joins and re-splits the arguments, and command substitutions end up executed in surprising ways.

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
