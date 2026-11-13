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
| `tui.sh` | Full-screen view (Omarchy-style): `tui_start` / `tui_stop` (alternate screen; stdout+stderr go to the log, the view paints on fd 3), `tui_draw` (logo, progress, two-column step grid from `UI_STEP_TITLES`, current command, live log window), `ui_screen` (clear + centered logo + title, aligns prompts through `UI_PAD` and `GUM_*_PADDING`), `ui_steps_recap`. Used only on a TTY ≥ 60×20 without `--verbose` and with `FIREARCH_TUI` ≠ 0. |
| `trap-errors.sh` | `ERR` trap: leaves the full-screen view, prints step, failing command, last 15 log lines, log path and the re-run command, then (on a terminal) a menu: retry (`exec install.sh`, with `--yes` once the wizard was confirmed; its answers are exported), read the log, quit. |
| `wizard.sh` | The only place that asks questions: user (rejects invalid names and system accounts, UID < 1000), password (mandatory for a new user, typed twice), git identity, hostname, default shell, install profile (`minimal`/`dev`/`full`/`custom`; `custom` opens the component list and then the language list). Prints the summary; "no" goes back to the form with previous answers pre-filled (password excepted), Ctrl+C cancels. Every answer has a `FIREARCH_*` env override; env-provided answers are fixed and never re-asked. Without a terminal, a new user without `FIREARCH_PASSWORD` is a hard stop. |
| `finale.sh` | `tte` logo animation (TTY only), summary box, collected warnings, next steps. |
| `essentials_pkgs.sh` | Minimal `PACMAN_PKGS`: `sudo`, `base-devel`, `diffutils`, `git`, `fish`, `curl`… |
| `repositories.sh` | `pacman.conf` candy; global mirrorlist (original backed up once to `mirrorlist.firearchwsl.bak`); Chaotic-AUR on x86_64 (key `3056513887B78AEB`, skippable with `DISABLE_CHAOTIC`); then `place_omarchy_last` strips and re-appends `[omarchy]` so the unsigned repo is always last; ends with `pacman -Syu`. A Chaotic-AUR failure is a warning, not fatal. |
| `install-mise.sh` | `pacman -S mise`. Shell activation lives in `default/bashrc` and `default/config.fish`. |

## For AI Agents

### Full-screen view

- While `UI_TUI=1`, `msg`/`ok`/`skip`/`warn`/`hint` only write the log and repaint; the view shows the log. Never `printf` straight to the screen from a step: stdout is the log at that point.
- `tui_draw` runs ten times a second from `run`: no subshells in the hot path (`_tui_fit` and friends use `printf -v` / namerefs).
- The wizard runs on the normal screen (`install.sh` stops the view around it). The finale and the ERR trap call `tui_stop` first.
- `ui_init` switches to `LC_CTYPE=C.UTF-8` on a non-UTF-8 locale: widths come from `${#s}`; `ui_box` uses `wc -L` (emoji are two columns).
- Visual check without a real terminal: record with `script -qec 'stty cols 110 rows 34; …' out.raw` and render the recording with a terminal emulator library (e.g. Python `pyte`).

### How `run` behaves

- TTY: spinner + elapsed time + last log line; command output goes only to the log.
- `FIREARCH_VERBOSE=1`: raw output on screen and in the log.
- No TTY: one `✔`/`✖` line per command.
- The command runs in a subshell with stdin from `/dev/null`. It may be a shell function, but it cannot set variables in the caller and cannot prompt.
- Returns the command's exit code. Under `set -e` a bare failing `run` triggers the `ERR` trap; `run … || warn …` makes it non-fatal.
- Never pass secrets as arguments to `run`: the command line is written to the log.

### How `pac_install` behaves

- Checks every name with `LC_ALL=C pacman -Si` first; a miss is double-checked with `pacman -Sp`, which also resolves groups (`base-devel`) and virtual names (`man` → `man-db`).
- Names that resolve nowhere are dropped and reported once as a warning, so one stale name no longer fails the whole transaction. Prefer the real package name in arrays anyway.

### Prompts

- A variable already set in the environment is never asked for.
- Prompts read from `/dev/tty` and render on stderr. `UI_INTERACTIVE=1` when stderr is a terminal and `/dev/tty` opens, so piping stdin does not disable them.
- Without a TTY, `ask_input`/`ask_choose` take the default and `ask_confirm` answers yes.
- `gum` is used when available on a TTY (`UI_GUM=1`); otherwise plain `read`. `FIREARCH_NO_GUM=1` forces plain prompts.
- gum exits 1 on Esc and 130 on Ctrl+C (raw mode: Ctrl+C never arrives as SIGINT). `ask_confirm` treats 130 as cancel and 1 as "no".
- The `ask_*` helpers write the answer with `printf -v "$var"`. Never pass a variable name that matches one of the helper's own locals (`var`, `prompt`, `def`, `val`, `picked`, `item`, `out`, `ans`, `rc`, `opt`, `sel`, `keys`, `selected`): the value would land in the helper's local and be lost.

### Testing the wizard

- Simulate a fresh distro without touching the real one: `unshare -m` + `mount --bind <empty dir> /etc/firearchwsl`, then source only `lib.sh`, `ui_init`, `trap-errors.sh` and `wizard.sh`.
- Drive it through `script -qec … /dev/null` with keystrokes piped in: lines with sleeps for plain prompts; raw keys (`\r`, `\e[B`, `\x03`) for gum.

### Working In This Directory

- Scripts run as root; no `sudo` calls except inside `as_user`.
- Any edit to `/etc/pacman.conf` must be `grep -q` guarded.
- `((i++))` returns 1 when `i` is 0 and trips `set -e` — use `i=$((i + 1))`.

### Testing Requirements

- Re-run on a configured distro: `/etc/pacman.conf` unchanged, no prompt for the user, no abort.
- UI under a pseudo-terminal: `script -qec 'bash <demo>' /dev/null`.

## Dependencies

- `pacman`, `pacman-key`, `gum` (optional), `tte` (optional), `mise`.
