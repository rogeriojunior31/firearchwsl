#!/bin/bash
# firearchwsl UI layer: colors, steps, spinner, prompts, log file.
# Sourced by lib.sh (after i18n.sh). Not an entry point.
#
#   ui_init                      set up colors, log file and TTY detection
#   step "Title"                 open a numbered step  [03/14]
#   run "label" cmd args…        run cmd behind a spinner; output goes to the log
#   pac_install "label" pkg…     pacman -S --needed behind `run`
#   msg / ok / warn / skip / die status lines
#   ask_input / ask_secret / ask_confirm / ask_choose / ask_multi   prompts
#
# All text passed in is already translated — callers use "$(t key …)".
#
# Environment:
#   FIREARCH_VERBOSE=1   show raw command output (no spinner)
#   FIREARCH_LOG=<path>  log file (default: /var/log/firearchwsl/…)
#   NO_COLOR=1           disable colors

ui_init() {
  # Widths are measured in characters (${#s}), which needs a UTF-8 locale;
  # a fresh Arch image runs in C. C.UTF-8 ships with glibc.
  if [[ "$(locale charmap 2>/dev/null)" != UTF-8 ]] && locale -a 2>/dev/null | grep -qix 'c.utf-\?8'; then
    export LC_CTYPE=C.UTF-8
  fi
  UI_PAD="  "
  UI_TTY=0
  [[ -t 1 ]] && UI_TTY=1
  # Prompts talk to the terminal directly (/dev/tty), so they work even when
  # stdin is a pipe. They render on stderr, which must be a terminal too.
  UI_INTERACTIVE=0
  if [[ -t 2 ]] && (: </dev/tty) 2>/dev/null; then UI_INTERACTIVE=1; fi
  UI_GUM=0
  FIREARCH_VERBOSE="${FIREARCH_VERBOSE:-0}"

  UI_COLS=80
  if ((UI_TTY)) && command -v tput &>/dev/null; then
    UI_COLS="$(tput cols 2>/dev/null || echo 80)"
  fi

  if ((UI_TTY)) && [[ -z "${NO_COLOR:-}" ]]; then
    C_RESET=$'\e[0m' C_BOLD=$'\e[1m' C_DIM=$'\e[2m'
    C_FIRE=$'\e[38;5;208m' C_RED=$'\e[38;5;203m' C_GREEN=$'\e[38;5;114m'
    C_YELLOW=$'\e[38;5;220m' C_BLUE=$'\e[38;5;75m' C_GRAY=$'\e[38;5;245m'
  else
    C_RESET='' C_BOLD='' C_DIM='' C_FIRE='' C_RED='' C_GREEN=''
    C_YELLOW='' C_BLUE='' C_GRAY=''
  fi

  # gum prompt theme (same "fire" palette)
  export GUM_INPUT_PROMPT_FOREGROUND=208 GUM_INPUT_CURSOR_FOREGROUND=208
  export GUM_INPUT_HEADER_FOREGROUND=220
  export GUM_CHOOSE_CURSOR_FOREGROUND=208 GUM_CHOOSE_SELECTED_FOREGROUND=208
  export GUM_CHOOSE_HEADER_FOREGROUND=220
  export GUM_CONFIRM_PROMPT_FOREGROUND=220 GUM_CONFIRM_SELECTED_BACKGROUND=208

  if [[ -z "${FIREARCH_LOG:-}" ]]; then
    FIREARCH_LOG="/var/log/firearchwsl/install-$(date +%Y%m%d-%H%M%S).log"
  fi
  mkdir -p "$(dirname "$FIREARCH_LOG")" 2>/dev/null || FIREARCH_LOG="/tmp/firearchwsl-install.log"
  : >>"$FIREARCH_LOG"
  export FIREARCH_LOG

  UI_STEP_N=0
  UI_STEP_TOTAL="${UI_STEP_TOTAL:-0}"
  UI_STEP_TITLE=""
  UI_WARNINGS=()
  UI_FAIL_LABEL=""
  UI_FAIL_CMD=""
  UI_T0=$SECONDS

  trap '_ui_on_exit $?' EXIT
  trap 'tui_stop; _ui_restore_cursor; printf "\n%s  ✖ %s%s\n" "$C_RED" "$(t ui.interrupted)" "$C_RESET"; exit 130' INT
}

_ui_restore_cursor() { ((${UI_TTY:-0})) && printf '\e[?25h' || true; }

# Progress in the terminal itself: tab title (OSC 0) and the Windows Terminal
# tab/taskbar progress ring (OSC 9;4 — state 1 normal, 2 error, 0 clear).
# Other terminals ignore both sequences.
_ui_osc() {
  ((${UI_TTY:-0})) || return 0
  local seq
  printf -v seq '\e]9;4;%d;%d\a' "$1" "$2"
  [[ -n "${3:-}" ]] && seq+=$'\e]0;'"$3"$'\a'
  # While the full-screen view is on, stdout is the log: use the terminal.
  if ((${UI_TUI:-0})); then printf '%s' "$seq" >&3; else printf '%s' "$seq"; fi
}

# Success clears the progress ring; a failure leaves it red.
_ui_on_exit() {
  tui_stop
  _ui_restore_cursor
  if (($1 == 0)); then _ui_osc 0 0; else _ui_osc 2 100; fi
}

# Append one plain (uncolored) line to the log.
_log() { printf '%s\n' "$*" >>"${FIREARCH_LOG:-/dev/null}"; }

# 75 → "1m15s"
_fmt_dur() {
  local s=$1
  if ((s >= 60)); then printf '%dm%02ds' $((s / 60)) $((s % 60)); else printf '%ds' "$s"; fi
}

# Re-detect gum (called once it has been installed).
# FIREARCH_NO_GUM=1 forces the plain `read` prompts.
ui_detect_gum() {
  UI_GUM=0
  if ((UI_INTERACTIVE)) && [[ "${FIREARCH_NO_GUM:-0}" != "1" ]] && command -v gum &>/dev/null; then
    UI_GUM=1
  fi
}

## ── Status lines ────────────────────────────────────────────────────────────

# In the full-screen view these only reach the log, which the view shows.
msg() {
  _log "[INFO] $*"
  if ((UI_TUI)); then tui_draw; else printf '%s%s•%s %s\n' "$UI_PAD" "$C_BLUE" "$C_RESET" "$*"; fi
}
ok() {
  _log "[ OK ] $*"
  if ((UI_TUI)); then tui_draw; else printf '%s%s✔%s %s\n' "$UI_PAD" "$C_GREEN" "$C_RESET" "$*"; fi
}
skip() {
  _log "[SKIP] $*"
  if ((UI_TUI)); then tui_draw; else printf '%s%s↷ %s%s\n' "$UI_PAD" "$C_GRAY" "$*" "$C_RESET"; fi
}
hint() {
  if ((UI_TUI)); then
    _log "       $*"
    tui_draw
  else
    printf '%s%s%s%s\n' "$UI_PAD" "$C_GRAY" "$*" "$C_RESET"
  fi
}
# Warnings are collected and repeated in the final summary.
warn() {
  _log "[WARN] $*"
  UI_WARNINGS+=("$*")
  if ((UI_TUI)); then tui_draw; else printf '%s%s⚠ %s%s\n' "$UI_PAD" "$C_YELLOW" "$*" "$C_RESET" >&2; fi
}
die() {
  tui_stop
  printf '\n%s%s✖ %s%s\n' "$UI_PAD" "$C_RED" "$*" "$C_RESET" >&2
  _log "[FAIL] $*"
  exit 1
}

# _ui_meter <percent> <cells> → "▰▰▰▱▱▱▱▱▱▱"
_ui_meter() {
  local done=$(($1 * $2 / 100)) out="" i
  for ((i = 0; i < $2; i++)); do
    if ((i < done)); then out+="▰"; else out+="▱"; fi
  done
  printf '%s' "$out"
}

# Step header with the overall progress:
#   ━━ [03/14] Locale ━━━━━━━━━━━━━━━━━━━ ▰▰▱▱▱▱▱▱▱▱ 14% · 1m02s
step() {
  UI_STEP_N=$((UI_STEP_N + 1))
  UI_STEP_TITLE="$1"
  ((${#UI_STEP_TITLES[@]})) && _tui_step_advance
  if ((UI_TUI)); then
    local pct=$(((UI_STEP_N - 1) * 100 / (UI_STEP_TOTAL ? UI_STEP_TOTAL : 1)))
    _ui_osc 1 "$pct" "$(printf 'firearchwsl [%02d/%02d] %s' "$UI_STEP_N" "$UI_STEP_TOTAL" "$1")"
    _log ""
    _log "════ $(printf '[%02d/%02d]' "$UI_STEP_N" "$UI_STEP_TOTAL") $1 ════"
    tui_draw
    return 0
  fi
  local tag right="" pct=0
  if ((UI_STEP_TOTAL > 0)); then
    tag="$(printf '[%02d/%02d]' "$UI_STEP_N" "$UI_STEP_TOTAL")"
    # Steps already finished, so the last step starts below 100%.
    pct=$(((UI_STEP_N - 1) * 100 / UI_STEP_TOTAL))
    right="$(printf '%3d%% · %s' "$pct" "$(_fmt_dur $((SECONDS - UI_T0)))")"
  else
    tag="$(printf '[%02d]' "$UI_STEP_N")"
  fi
  local width=$((UI_COLS < 80 ? UI_COLS : 80)) meter="" meter_len=0
  # The meter only when it fits; ${#} would count bytes in the C locale.
  if [[ -n "$right" ]] && ((width - ${#tag} - ${#1} - ${#right} >= 26)); then
    meter="$(_ui_meter "$pct" 10)"
    meter_len=11
  fi
  local fill=$((width - ${#tag} - ${#1} - 6 - meter_len - ${#right} - (${#right} ? 1 : 0)))
  ((fill < 3)) && fill=3
  local bar
  bar="$(printf '━%.0s' $(seq 1 "$fill"))"
  printf '\n%s━━ %s%s %s%s %s%s%s' "$C_FIRE" "$C_BOLD" "$tag" "$1" "$C_RESET" "$C_FIRE" "$bar" "$C_RESET"
  [[ -n "$meter" ]] && printf ' %s%s%s' "$C_FIRE" "$meter" "$C_RESET"
  [[ -n "$right" ]] && printf ' %s%s%s' "$C_GRAY" "$right" "$C_RESET"
  printf '\n'
  _ui_osc 1 "$pct" "firearchwsl $tag $1"
  _log ""
  _log "════ $tag $1 ════"
}

## ── Command execution ───────────────────────────────────────────────────────

# Last useful log line, ANSI-stripped and truncated to fit beside the spinner.
_ui_log_tail() {
  local max=$1
  ((max < 12)) && return 0
  tail -n 1 "$FIREARCH_LOG" 2>/dev/null |
    sed -e '/^\$ /d' -e 's/\x1b\[[0-9;?]*[A-Za-z]//g' -e 's/.*\r//' -e 's/^[[:space:]]*//' |
    cut -c "1-$max"
}

# run "label" cmd args…
#   TTY:      spinner + elapsed time + last log line; ✔/✖ when done
#   verbose:  raw output on screen (and in the log)
#   no TTY:   only the final ✔/✖ line (good for CI / captured logs)
# Returns the command's exit code. Use `run … || warn …` for non-fatal steps.
# cmd may be a shell function; it runs in a subshell, so it cannot set
# variables in the caller.
run() {
  local label=$1
  shift
  local t0=$SECONDS rc=0
  _log ""
  _log "▶ $label"
  _log "\$ $*"

  if ((UI_TUI)); then
    # Full-screen view: the view repaints itself while the command runs.
    (trap - ERR; "$@") >>"$FIREARCH_LOG" 2>&1 </dev/null &
    local pid=$!
    UI_ACTIVITY=$label UI_ACTIVITY_T0=$SECONDS
    while kill -0 "$pid" 2>/dev/null; do
      tui_draw
      sleep 0.1
    done
    wait "$pid" && rc=0 || rc=$?
    UI_ACTIVITY=""
  elif ((FIREARCH_VERBOSE)); then
    printf '  %s▶ %s%s\n' "$C_FIRE" "$label" "$C_RESET"
    { (trap - ERR; "$@") 2>&1 | tee -a "$FIREARCH_LOG"; } && rc=0 || rc=$?
  elif ((UI_TTY)); then
    (trap - ERR; "$@") >>"$FIREARCH_LOG" 2>&1 </dev/null &
    local pid=$! i=0 tail_line=""
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    printf '\e[?25l'
    while kill -0 "$pid" 2>/dev/null; do
      if ((i % 5 == 0)); then
        tail_line="$(_ui_log_tail $((UI_COLS - ${#label} - 18)))" || tail_line=""
      fi
      printf '\r\e[2K  %s%s%s %s %s(%s)%s %s%s%s' \
        "$C_FIRE" "${frames[i % 10]}" "$C_RESET" "$label" \
        "$C_GRAY" "$(_fmt_dur $((SECONDS - t0)))" "$C_RESET" \
        "$C_DIM" "$tail_line" "$C_RESET"
      i=$((i + 1))
      sleep 0.1
    done
    wait "$pid" && rc=0 || rc=$?
    printf '\r\e[2K\e[?25h'
  else
    (trap - ERR; "$@") >>"$FIREARCH_LOG" 2>&1 </dev/null && rc=0 || rc=$?
  fi

  local dur
  dur="$(_fmt_dur $((SECONDS - t0)))"
  if ((rc == 0)); then
    ((UI_TUI)) || printf '%s%s✔%s %s %s(%s)%s\n' "$UI_PAD" "$C_GREEN" "$C_RESET" "$label" "$C_GRAY" "$dur" "$C_RESET"
    _log "[ OK ] $label ($dur)"
  else
    ((UI_TUI)) || printf '%s%s✖ %s%s %s(%s, exit %d)%s\n' "$UI_PAD" "$C_RED" "$label" "$C_RESET" "$C_GRAY" "$dur" "$rc" "$C_RESET"
    _log "[FAIL] $label ($dur, exit $rc)"
    UI_FAIL_LABEL="$label"
    UI_FAIL_CMD="$*"
  fi
  tui_draw
  return "$rc"
}

# pac_install "label" pkg…  — pacman -S --needed, package count in the label.
# A name missing from every repo would make pacman reject the whole
# transaction, so those are dropped first and reported as a warning.
pac_install() {
  local label=$1 name
  shift
  local -a missing=() keep=() skipped=()
  # LC_ALL=C: the error text is parsed. `|| true`: pacman exits 1 on any miss.
  mapfile -t missing < <(LC_ALL=C pacman -Si -- "$@" 2>&1 >/dev/null |
    sed -n "s/^error: package '\(.*\)' was not found$/\1/p" || true)
  for name in "$@"; do
    # -Si misses groups and virtual names (`man` is provided by man-db);
    # -Sp resolves both, so it gets the final say on each miss.
    if [[ " ${missing[*]} " == *" $name "* ]] && ! pacman -Sp --print-format '%n' -- "$name" &>/dev/null; then
      skipped+=("$name")
    else
      keep+=("$name")
    fi
  done
  ((${#skipped[@]})) && warn "$(t ui.pkg_missing "${skipped[*]}")"
  ((${#keep[@]})) || return 0
  run "$(t ui.pkg_count "$label" "${#keep[@]}")" pacman -S --needed --noconfirm "${keep[@]}"
}

## ── Boxes and banner ────────────────────────────────────────────────────────

# ui_box "Title" "line 1" "line 2" …
# Columns a string takes on screen: no color codes, emoji count as two.
_ui_width() { sed 's/\x1b\[[0-9;]*m//g' <<<"$1" | wc -L; }

# Rounded box sized to its widest line.
ui_box() {
  local title=$1 line len title_w fill
  shift
  title_w="$(_ui_width "$title")"
  local width=$((title_w + 4))
  local -a lens=()
  for line in "$@"; do
    len="$(_ui_width "$line")"
    lens+=("$len")
    ((len + 4 > width)) && width=$((len + 4))
  done
  printf -v fill '%*s' $((width - title_w - 3)) ''
  printf '\n%s%s╭─ %s%s%s %s%s╮%s\n' "$UI_PAD" "$C_FIRE" "$C_BOLD" "$title" "$C_RESET$C_FIRE" "${fill// /─}" "" "$C_RESET"
  local i=0
  for line in "$@"; do
    printf -v fill '%*s' $((width - lens[i] - 2)) ''
    printf '%s%s│%s  %s%s%s│%s\n' "$UI_PAD" "$C_FIRE" "$C_RESET" "$line" "$fill" "$C_FIRE" "$C_RESET"
    i=$((i + 1))
  done
  printf -v fill '%*s' "$width" ''
  printf '%s%s╰%s╯%s\n' "$UI_PAD" "$C_FIRE" "${fill// /─}" "$C_RESET"
}

# ui_row "Label" "value" → "Label ........ value" (dot leaders, 16 columns).
# Padding is computed by hand: printf's %-Ns counts bytes, not characters.
ui_row() {
  local label=$1 dots
  dots="$(printf '.%.0s' $(seq 1 $((16 - ${#label} > 2 ? 16 - ${#label} : 2))))"
  printf '%s %s%s%s %s' "$label" "$C_GRAY" "$dots" "$C_RESET" "$2"
}

# Logo with a "fire" gradient (compact variant on narrow terminals).
ui_banner() {
  local logo="${FIREARCH_ROOT:-.}/logo.txt"
  local grad=(196 202 208 214 220 226 245) n=0 line
  echo
  if ((UI_COLS >= 88)) && [[ -r "$logo" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ -n "$C_RESET" ]]; then
        printf '\e[38;5;%sm%s\e[0m\n' "${grad[n < 6 ? n : 6]}" "$line"
      else
        printf '%s\n' "$line"
      fi
      n=$((n + 1))
    done <"$logo"
  else
    printf '  %s%s🔥 FIREARCHWSL%s %s— by Rogerio Junior%s\n' "$C_BOLD" "$C_FIRE" "$C_RESET" "$C_GRAY" "$C_RESET"
  fi
  printf '\n  %s%s%s\n' "$C_GRAY" "$(t banner.tagline)" "$C_RESET"
  printf '  %s%s%s\n' "$C_GRAY" "$(t banner.log "$FIREARCH_LOG")" "$C_RESET"
}

## ── Prompts ─────────────────────────────────────────────────────────────────
# Shared rule: a variable already set in the environment is never asked for.
# Without a TTY the default is used.
# gum exits 1 on Esc and 130 on Ctrl+C (it reads keys in raw mode, so Ctrl+C
# never reaches the shell as SIGINT). Both cancel the installer.

# ask_input VAR "Question" [default]
ask_input() {
  local var=$1 prompt=$2 def=${3:-} val
  if [[ -n "${!var:-}" ]]; then return 0; fi
  if ((UI_INTERACTIVE)); then
    if ((UI_GUM)); then
      val="$(gum input --header "$prompt" --prompt "› " --value "$def" </dev/tty)" || die "$(t ui.cancelled)"
    else
      read -rp "$UI_PAD$prompt${def:+ [$def]}: " val </dev/tty || die "$(t ui.cancelled)"
      val="${val:-$def}"
    fi
  else
    val="$def"
  fi
  printf -v "$var" '%s' "$val"
}

# ask_secret VAR "Question"  — the value is never echoed or logged.
ask_secret() {
  local var=$1 prompt=$2 val=""
  if ((UI_GUM)); then
    val="$(gum input --password --header "$prompt" --prompt "› " </dev/tty)" || die "$(t ui.cancelled)"
  else
    read -rsp "$UI_PAD$prompt: " val </dev/tty || die "$(t ui.cancelled)"
    echo >&2
  fi
  printf -v "$var" '%s' "$val"
}

# ask_confirm "Question"  — exit 0 means yes, 1 means no; Ctrl+C cancels.
# Without a TTY the answer is yes.
ask_confirm() {
  local ans rc=0
  ((UI_INTERACTIVE)) || return 0
  if ((UI_GUM)); then
    gum confirm --affirmative "$(t ui.yes)" --negative "$(t ui.no)" "$1" </dev/tty || rc=$?
    ((rc == 130)) && die "$(t ui.cancelled)"
    return "$rc"
  fi
  read -rp "$UI_PAD$1 $I18N_YES_NO_HINT: " ans </dev/tty || die "$(t ui.cancelled)"
  [[ -z "$ans" || "$ans" =~ $I18N_YES_REGEX ]]
}

# ask_choose VAR "Question" default option…
# An option may be "key — description": the menu shows the whole line and VAR
# receives the key (first word). default is a key.
ask_choose() {
  local var=$1 prompt=$2 def=$3 val opt sel="" keys=""
  shift 3
  for opt in "$@"; do
    keys+="${keys:+/}${opt%% *}"
    [[ "${opt%% *}" == "$def" ]] && sel=$opt
  done
  while true; do
    if [[ -n "${!var:-}" ]]; then
      val="${!var}"
    elif ((UI_INTERACTIVE)); then
      if ((UI_GUM)); then
        local -a selected=()
        [[ -n "$sel" ]] && selected=(--selected "$sel")
        val="$(gum choose --header "$prompt" "${selected[@]}" "$@" </dev/tty)" || die "$(t ui.cancelled)"
      else
        if [[ "$*" == *" — "* ]]; then
          printf '%s%s\n' "$UI_PAD" "$prompt" >&2
          for opt in "$@"; do printf '%s  %s%s%s%s\n' "$UI_PAD" "$C_BOLD" "${opt%% *}" "$C_RESET" "${opt#"${opt%% *}"}" >&2; done
          read -rp "$UI_PAD($keys) [$def]: " val </dev/tty || die "$(t ui.cancelled)"
        else
          read -rp "$UI_PAD$prompt ($keys) [$def]: " val </dev/tty || die "$(t ui.cancelled)"
        fi
        val="${val:-$def}"
      fi
    else
      val="$def"
    fi
    val="${val%% *}"
    for opt in "$@"; do
      if [[ "${opt%% *}" == "$val" ]]; then
        printf -v "$var" '%s' "$val"
        return 0
      fi
    done
    # A typo in the terminal is asked again; a bad env value is fatal.
    if ((UI_INTERACTIVE)) && [[ -z "${!var:-}" ]]; then
      hint "$(t ui.invalid_choice "$var" "$val" "${keys//\// }")"
      continue
    fi
    die "$(t ui.invalid_choice "$var" "$val" "${keys//\// }")"
  done
}

# ask_multi VAR "Question" "key — description"…
# Everything starts selected; VAR receives the selected KEYS (first word),
# space-separated.
ask_multi() {
  local var=$1 prompt=$2 picked="" item out
  shift 2
  if ((UI_INTERACTIVE && UI_GUM)); then
    out="$(gum choose --no-limit --selected "*" \
      --header "$prompt ($(t ui.multi_hint))" "$@" </dev/tty)" || die "$(t ui.cancelled)"
    while IFS= read -r item; do
      [[ -n "$item" ]] && picked+="${item%% *} "
    done <<<"$out"
  else
    ((UI_INTERACTIVE)) && printf '%s%s\n' "$UI_PAD" "$prompt"
    for item in "$@"; do
      if ask_confirm "$(t ui.install_q "$item")"; then picked+="${item%% *} "; fi
    done
  fi
  printf -v "$var" '%s' "${picked% }"
}
