#!/bin/bash
# ERR trap: shows the step, the command, the log tail, and offers to retry,
# read the full log or quit. Requires ui.sh (colors, FIREARCH_LOG), tui.sh
# and i18n.sh to be loaded.

catch_errors() {
  local ec=$?
  trap - ERR # do not fire again while the error propagates
  local where="${BASH_SOURCE[1]:-?}:${BASH_LINENO[0]:-?}"
  local cmd="${UI_FAIL_CMD:-$BASH_COMMAND}"
  local pad

  tui_step_finish fail
  tui_stop
  printf '\e[?25h'
  pad="$UI_PAD"

  printf '\n%s%s%s✖ %s%s\n\n' "$pad" "$C_BOLD" "$C_RED" "$(t err.title)" "$C_RESET"
  printf '%s%s%s%s %s\n' "$pad" "$C_GRAY" "$(t err.step)" "$C_RESET" "${UI_STEP_TITLE:-?}${UI_FAIL_LABEL:+ → $UI_FAIL_LABEL}"
  printf '%s%s%s%s %s\n' "$pad" "$C_GRAY" "$(t err.command)" "$C_RESET" "$cmd"
  printf '%s%s%s%s %s (exit %d)\n' "$pad" "$C_GRAY" "$(t err.where)" "$C_RESET" "${where#"${FIREARCH_ROOT:-}"/}" "$ec"

  if [[ -s "${FIREARCH_LOG:-}" ]]; then
    printf '\n%s%s%s%s\n' "$pad" "$C_GRAY" "$(t err.log_tail)" "$C_RESET"
    tail -n 15 "$FIREARCH_LOG" | sed -e 's/\x1b\[[0-9;?]*[A-Za-z]//g' -e 's/.*\r//' -e "s/^/${pad}${C_DIM}│${C_RESET} /"
    printf '\n%s%s%s%s %s\n' "$pad" "$C_GRAY" "$(t err.log_full)" "$C_RESET" "$FIREARCH_LOG"
  fi

  printf '\n%s%s\n' "$pad" "$(t err.rerun)"
  printf '%s%s  bash %s/install.sh%s\n\n' "$pad" "$C_FIRE" "${FIREARCH_ROOT:-.}" "$C_RESET"
  _log "[FAIL] exit $ec at $where: $cmd"

  _error_menu
}

# Retry / full log / quit. Without a terminal the installer just stops.
_error_menu() {
  ((UI_INTERACTIVE)) || return 0
  local action
  while true; do
    action=""
    ask_choose action "$(t err.menu_q)" retry \
      "retry — $(t err.menu_retry)" \
      "log — $(t err.menu_log)" \
      "exit — $(t err.menu_exit)"
    case "$action" in
      retry)
        # Every step is idempotent and the answers were exported by the
        # wizard, so the new run goes straight to work.
        [[ -n "${FIREARCH_PASSWORD:-}" ]] && export FIREARCH_PASSWORD
        local -a args=()
        # Answers already confirmed: do not ask for the summary again.
        ((${WIZARD_DONE:-0})) && args+=(--yes)
        ((FIREARCH_VERBOSE)) && args+=(--verbose)
        exec bash "$FIREARCH_ROOT/install.sh" "${args[@]}"
        ;;
      log)
        if command -v less &>/dev/null; then
          less -R +G "$FIREARCH_LOG" </dev/tty >/dev/tty 2>&1 || true
        else
          tail -n 80 "$FIREARCH_LOG"
        fi
        ;;
      *) return 0 ;;
    esac
  done
}

trap catch_errors ERR
