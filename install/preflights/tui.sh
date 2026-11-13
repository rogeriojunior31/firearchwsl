#!/bin/bash
# Full-screen view of the installer, in the spirit of Omarchy: the logo
# centered on top, the overall progress, the list of steps and a live window
# on the log. Sourced by ui.sh. Not an entry point.
#
#   tui_start      enter the view (alternate screen); returns 1 when the
#                  terminal cannot show it (no TTY, too small, --verbose)
#   tui_stop       leave it and give the terminal back
#   tui_draw       repaint (step, run and the status lines call it)
#   ui_screen "…"  clear the screen, centered logo and a title (wizard, end)
#
# While the view is on, stdout/stderr go to the log (stray command output
# cannot break the layout) and the view is painted on fd 3, the terminal.
# FIREARCH_TUI=0 keeps the line-by-line output.

UI_TUI=0
UI_STEP_TITLES=() # step titles, in order (install.sh)
UI_STEP_STATE=()  # per step: "" todo | run | ok | fail
UI_STEP_DUR=()    # per step: formatted duration ("1m02s"), once finished
UI_STEP_T0=0
UI_ACTIVITY=""    # label of the command behind the spinner
UI_ACTIVITY_T0=0
UI_FRAME=0
UI_LOGO=()
UI_LOGO_W=0
TUI_ROWS=24 TUI_COLS=80 TUI_W=76 TUI_PAD="  "

## ── Geometry ────────────────────────────────────────────────────────────────

# One centered column, as wide as the logo when the window allows it.
_tui_size() {
  local size
  size="$(stty size </dev/tty 2>/dev/null || true)"
  if [[ "$size" =~ ^([0-9]+)\ ([0-9]+)$ ]]; then
    TUI_ROWS=${BASH_REMATCH[1]} TUI_COLS=${BASH_REMATCH[2]}
  fi
  UI_COLS=$TUI_COLS
  TUI_W=$((TUI_COLS - 4 < 86 ? TUI_COLS - 4 : 86))
  printf -v TUI_PAD '%*s' $(((TUI_COLS - TUI_W) / 2)) ''
}

_tui_load_logo() {
  ((${#UI_LOGO[@]})) && return 0
  local file="${FIREARCH_ROOT:-.}/logo.txt" line
  [[ -r "$file" ]] || return 0
  mapfile -t UI_LOGO <"$file"
  for line in "${UI_LOGO[@]}"; do
    ((${#line} > UI_LOGO_W)) && UI_LOGO_W=${#line}
  done
  return 0
}

tui_supported() {
  ((UI_TTY && UI_INTERACTIVE)) || return 1
  ((FIREARCH_VERBOSE)) && return 1
  [[ "${FIREARCH_TUI:-1}" != 0 ]] || return 1
  _tui_size
  ((TUI_ROWS >= 20 && TUI_COLS >= 60))
}

## ── Small helpers (no subshells: tui_draw runs ten times a second) ─────────

# _tui_fit VAR "text" width — text cut to width, with an ellipsis.
_tui_fit() {
  local -n _fit_out=$1
  if ((${#2} > $3)); then _fit_out="${2:0:$3-1}…"; else _fit_out=$2; fi
}

_tui_buf=""
_tui_used=0
_tui_put() {
  _tui_buf+=$'\e[2K'"$TUI_PAD$1"$'\n'
  _tui_used=$((_tui_used + 1))
}

# Logo with the fire gradient, centered in the column (or a one-line mark).
_tui_logo_lines() {
  local putter=$1 line n=0 lpad
  local grad=(196 202 208 214 220 226 245)
  _tui_load_logo
  if ((${#UI_LOGO[@]} && TUI_W >= UI_LOGO_W)) && { [[ "${2:-}" != compact ]] || ((TUI_ROWS >= 28)); }; then
    printf -v lpad '%*s' $(((TUI_W - UI_LOGO_W) / 2)) ''
    for line in "${UI_LOGO[@]}"; do
      if [[ -n "$C_RESET" ]]; then
        "$putter" "$lpad"$'\e[38;5;'"${grad[n < 6 ? n : 6]}m$line"$'\e[0m'
      else
        "$putter" "$lpad$line"
      fi
      n=$((n + 1))
    done
  else
    "$putter" "${C_BOLD}${C_FIRE}🔥 F I R E A R C H${C_RESET}  ${C_GRAY}wsl${C_RESET}"
  fi
}

# One cell of the step grid: icon, title, duration once done.
_tui_cell=""
_tui_step_cell() {
  local idx=$1 spin=$2 w=$3 icon color tcolor="" dur="" title fill
  case "${UI_STEP_STATE[idx]:-}" in
    ok) icon="✔" color=$C_GREEN dur=" ${UI_STEP_DUR[idx]:-}" ;;
    run) icon=$spin color=$C_FIRE tcolor=$C_BOLD ;;
    fail) icon="✖" color=$C_RED tcolor=$C_RED ;;
    *) icon="·" color=$C_GRAY tcolor=$C_GRAY ;;
  esac
  _tui_fit title "${UI_STEP_TITLES[idx]:-}" $((w - 3 - ${#dur}))
  fill=$((w - 2 - ${#title} - ${#dur}))
  ((fill < 0)) && fill=0
  printf -v _tui_cell '%s%s%s %s%s%s%*s%s%s%s' "$color" "$icon" "$C_RESET" \
    "$tcolor" "$title" "$C_RESET" "$fill" '' "$C_GRAY" "$dur" "$C_RESET"
}

# The step grid, two columns: "putter" receives each row.
_tui_steps_grid() {
  local putter=$1 spin=$2 total=${#UI_STEP_TITLES[@]} rows r c idx row
  local half=$((TUI_W / 2))
  rows=$(((total + 1) / 2))
  for ((r = 0; r < rows; r++)); do
    row=""
    for c in 0 1; do
      idx=$((r + c * rows))
      ((idx < total)) || continue
      _tui_step_cell "$idx" "$spin" $((half - 1))
      row+="$_tui_cell "
    done
    "$putter" "$row"
  done
}

# Log line → colored line for the live window.
_tui_log_line=""
_tui_format_log() {
  local line=$1 w=$((TUI_W - 2))
  case "$line" in
    "[ OK ] "*) _tui_fit line "${line#"[ OK ] "}" "$w"; _tui_log_line="${C_GREEN}✔${C_RESET} ${C_GRAY}${line}${C_RESET}" ;;
    "[WARN] "*) _tui_fit line "${line#"[WARN] "}" "$w"; _tui_log_line="${C_YELLOW}⚠ ${line}${C_RESET}" ;;
    "[FAIL] "*) _tui_fit line "${line#"[FAIL] "}" "$w"; _tui_log_line="${C_RED}✖ ${line}${C_RESET}" ;;
    "[SKIP] "*) _tui_fit line "${line#"[SKIP] "}" "$w"; _tui_log_line="${C_GRAY}↷ ${line}${C_RESET}" ;;
    "[INFO] "*) _tui_fit line "${line#"[INFO] "}" "$w"; _tui_log_line="${C_BLUE}•${C_RESET} ${C_GRAY}${line}${C_RESET}" ;;
    "▶ "*) _tui_fit line "${line#"▶ "}" "$w"; _tui_log_line="${C_FIRE}▶${C_RESET} ${line}" ;;
    "════ "*) _tui_fit line "${line//═/}" "$w"; _tui_log_line="${C_FIRE}${C_BOLD}${line# }${C_RESET}" ;;
    *) _tui_fit line "$line" "$w"; _tui_log_line="  ${C_DIM}${line}${C_RESET}" ;;
  esac
}

## ── The view ────────────────────────────────────────────────────────────────

tui_start() {
  tui_supported || return 1
  UI_TUI=1
  exec 3>&1 4>&2 >>"$FIREARCH_LOG" 2>&1
  printf '\e[?1049h\e[?25l' >&3
  trap '_tui_size; tui_draw' WINCH
  tui_draw
}

tui_stop() {
  ((${UI_TUI:-0})) || return 0
  UI_TUI=0
  trap - WINCH
  printf '\e[?25h\e[?1049l' >&3
  exec 1>&3 2>&4 3>&- 4>&-
}

tui_draw() {
  ((UI_TUI)) || return 0
  local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏) spin i done=0 total=${#UI_STEP_TITLES[@]}
  UI_FRAME=$((UI_FRAME + 1))
  spin=${frames[UI_FRAME % 10]}

  # Synchronized update (no flicker) + home; every line clears itself.
  _tui_buf=$'\e[?2026h\e[H' _tui_used=0
  _tui_put ""
  _tui_logo_lines _tui_put compact
  _tui_put ""

  # Overall progress: current step, elapsed time, warnings, meter.
  for ((i = 0; i < total; i++)); do
    [[ "${UI_STEP_STATE[i]:-}" == ok ]] && done=$((done + 1))
  done
  local pct=$((total ? done * 100 / total : 0)) head right meter
  printf -v head '[%02d/%02d] %s' "$UI_STEP_N" "$total" "$UI_STEP_TITLE"
  right="$(_fmt_dur $((SECONDS - UI_T0)))"
  ((${#UI_WARNINGS[@]})) && right="⚠ ${#UI_WARNINGS[@]}  $right"
  _tui_fit head "$head" $((TUI_W - ${#right} - 2))
  local gap=$((TUI_W - ${#head} - ${#right}))
  ((gap < 1)) && gap=1
  printf -v meter '%*s' "$gap" ''
  _tui_put "${C_BOLD}${head}${C_RESET}${meter}${C_GRAY}${right}${C_RESET}"
  _tui_put "${C_FIRE}$(_ui_meter "$pct" $((TUI_W - 6)))${C_RESET} ${C_BOLD}$(printf '%3d%%' "$pct")${C_RESET}"
  _tui_put ""

  _tui_steps_grid _tui_put "$spin"
  _tui_put ""

  # What is running right now.
  local label
  if [[ -n "$UI_ACTIVITY" ]]; then
    local dur
    dur="$(_fmt_dur $((SECONDS - UI_ACTIVITY_T0)))"
    _tui_fit label "$UI_ACTIVITY" $((TUI_W - ${#dur} - 5))
    _tui_put "${C_FIRE}${spin}${C_RESET} ${label} ${C_GRAY}(${dur})${C_RESET}"
  else
    _tui_put "${C_FIRE}${spin}${C_RESET} ${C_GRAY}${UI_STEP_TITLE}${C_RESET}"
  fi

  # Live window on the log: whatever room is left.
  local avail=$((TUI_ROWS - _tui_used - 2)) rule line
  if ((avail >= 2)); then
    printf -v rule '%*s' "$TUI_W" ''
    _tui_put "${C_GRAY}${rule// /─}${C_RESET}"
    local -a lines=()
    mapfile -t lines < <(tail -n 300 "$FIREARCH_LOG" 2>/dev/null |
      sed -e '/^\$ /d' -e 's/\x1b\[[0-9;?]*[A-Za-z]//g' -e 's/.*\r//' -e '/^[[:space:]]*$/d' |
      tail -n $((avail - 1)))
    for ((i = 0; i < avail - 1; i++)); do
      line="${lines[i]:-}"
      if [[ -n "$line" ]]; then
        _tui_format_log "$line"
        _tui_put "$_tui_log_line"
      else
        _tui_put ""
      fi
    done
  fi

  _tui_buf+=$'\e[J\e[?2026l'
  printf '%s' "$_tui_buf" >&3
}

## ── Step bookkeeping (called by `step`) ─────────────────────────────────────

# Close the running step (ok + duration) and open the next one.
_tui_step_advance() {
  local prev=$((UI_STEP_N - 2))
  if ((prev >= 0)) && [[ "${UI_STEP_STATE[prev]:-}" == run ]]; then
    UI_STEP_STATE[prev]=ok
    UI_STEP_DUR[prev]="$(_fmt_dur $((SECONDS - UI_STEP_T0)))"
  fi
  UI_STEP_STATE[UI_STEP_N - 1]=run
  UI_STEP_T0=$SECONDS
}

# The last step has no "next" to close it: the finale and the error trap do.
tui_step_finish() {
  local cur=$((UI_STEP_N - 1)) state=${1:-ok}
  ((cur >= 0)) || return 0
  [[ "${UI_STEP_STATE[cur]:-}" == run ]] || return 0
  UI_STEP_STATE[cur]=$state
  UI_STEP_DUR[cur]="$(_fmt_dur $((SECONDS - UI_STEP_T0)))"
}

## ── Static screens (wizard, finale) ─────────────────────────────────────────

_screen_put() { printf '%s%s\n' "$TUI_PAD" "$1"; }

# ui_screen "Title" — clean screen, logo, title; aligns the prompts below it.
# Without a big enough terminal it only prints the title as a header.
ui_screen() {
  if tui_supported; then
    printf '\e[H\e[2J'
    echo
    _tui_logo_lines _screen_put
    echo
    UI_PAD="$TUI_PAD"
    export GUM_INPUT_PADDING="0 0 0 ${#TUI_PAD}" GUM_CHOOSE_PADDING="0 0 0 ${#TUI_PAD}"
    export GUM_CONFIRM_PADDING="0 0 0 ${#TUI_PAD}"
  fi
  [[ -n "${1:-}" ]] && printf '%s%s%s%s%s\n\n' "$UI_PAD" "$C_BOLD" "$C_FIRE" "$1" "$C_RESET"
  return 0
}

# Recap of every step with its duration (final screen).
ui_steps_recap() {
  ((${#UI_STEP_TITLES[@]})) || return 0
  ((UI_TTY)) && _tui_size
  _tui_steps_grid _screen_put "✔"
}
