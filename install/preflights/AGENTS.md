<!-- Parent: ../AGENTS.md -->

# preflights

## Purpose

The installer's runtime (library, translations, UI, error trap, wizard, finale) plus the steps that prepare the base system before opinionated packages land.

## Key Files

| File | Description |
|------|-------------|
| `lib.sh` | Sourced first by `install.sh`. Sources `i18n.sh` and `ui.sh`; defines `component_enabled`, `resolve_target_user`, `ensure_target_user`, `as_user`. |
| `i18n.sh` | `i18n_load <lang>` (loads `../i18n/en.sh`, then the language on top), `t <key> [args]`, `i18n_available`, `i18n_name`, `i18n_choose` (numbered picker using plain `read`, because it runs before `gum` exists). Default language: `I18N_DEFAULT_LANG` (`pt_BR`). |
| `ui.sh` | `ui_init`, `step`, `run`, `pac_install`, status lines (`msg`/`ok`/`skip`/`hint`/`warn`/`die`), `ui_box`, `ui_row`, `ui_banner`, prompts (`ask_input`/`ask_secret`/`ask_confirm`/`ask_choose`/`ask_multi`). Owns the log file (`FIREARCH_LOG`). |
| `trap-errors.sh` | `ERR` trap: prints step, failing command, last 15 log lines, log path and the re-run command. |
| `wizard.sh` | The only place that asks questions: user, password, git identity, default shell, optional components; prints the summary and confirms. Every answer has a `FIREARCH_*` env override. |
| `finale.sh` | `tte` logo animation (TTY only), summary box, collected warnings, next steps. |
| `essentials_pkgs.sh` | Minimal `PACMAN_PKGS`: `sudo`, `base-devel`, `diffutils`, `git`, `fish`, `curl`… |
| `repositories.sh` | `pacman.conf` candy; Omarchy repo; global mirrorlist; Chaotic-AUR on x86_64 (key `3056513887B78AEB`, skippable with `DISABLE_CHAOTIC`); ends with `pacman -Syu`. A Chaotic-AUR failure is a warning, not fatal. |
| `install-mise.sh` | `pacman -S mise`. Shell activation lives in `default/bashrc` and `default/config.fish`. |

## For AI Agents

### How `run` behaves

- TTY: spinner + elapsed time + last log line; command output goes only to the log.
- `FIREARCH_VERBOSE=1`: raw output on screen and in the log.
- No TTY: one `✔`/`✖` line per command.
- The command runs in a subshell with stdin from `/dev/null`. It may be a shell function, but it cannot set variables in the caller and cannot prompt.
- Returns the command's exit code. Under `set -e` a bare failing `run` triggers the `ERR` trap; `run … || warn …` makes it non-fatal.
- Never pass secrets as arguments to `run`: the command line is written to the log.

### Prompts

- A variable already set in the environment is never asked for.
- Without a TTY, `ask_input`/`ask_choose` take the default and `ask_confirm` answers yes.
- `gum` is used when available on a TTY (`UI_GUM=1`); otherwise plain `read`.

### Working In This Directory

- Scripts run as root; no `sudo` calls except inside `as_user`.
- Any edit to `/etc/pacman.conf` must be `grep -q` guarded.
- `((i++))` returns 1 when `i` is 0 and trips `set -e` — use `i=$((i + 1))`.

### Testing Requirements

- Re-run on a configured distro: `/etc/pacman.conf` unchanged, no prompt for the user, no abort.
- UI under a pseudo-terminal: `script -qec 'bash <demo>' /dev/null`.

## Dependencies

- `pacman`, `pacman-key`, `gum` (optional), `tte` (optional), `mise`.
