#!/bin/bash
# ERR trap: shows the step, the command, the log tail and how to resume.
# Requires ui.sh (colors, FIREARCH_LOG) and i18n.sh to be loaded.

catch_errors() {
  local ec=$?
  trap - ERR # do not fire again while the error propagates
  local where="${BASH_SOURCE[1]:-?}:${BASH_LINENO[0]:-?}"
  local cmd="${UI_FAIL_CMD:-$BASH_COMMAND}"

  printf '\e[?25h'
  printf '\n%s%s  ✖ %s%s\n\n' "$C_BOLD" "$C_RED" "$(t err.title)" "$C_RESET"
  printf '  %s%s%s %s\n' "$C_GRAY" "$(t err.step)" "$C_RESET" "${UI_STEP_TITLE:-?}${UI_FAIL_LABEL:+ → $UI_FAIL_LABEL}"
  printf '  %s%s%s %s\n' "$C_GRAY" "$(t err.command)" "$C_RESET" "$cmd"
  printf '  %s%s%s %s (exit %d)\n' "$C_GRAY" "$(t err.where)" "$C_RESET" "${where#"${FIREARCH_ROOT:-}"/}" "$ec"

  if [[ -s "${FIREARCH_LOG:-}" ]]; then
    printf '\n  %s%s%s\n' "$C_GRAY" "$(t err.log_tail)" "$C_RESET"
    tail -n 15 "$FIREARCH_LOG" | sed -e 's/\x1b\[[0-9;?]*[A-Za-z]//g' -e "s/^/  ${C_DIM}│${C_RESET} /"
    printf '\n  %s%s%s %s\n' "$C_GRAY" "$(t err.log_full)" "$C_RESET" "$FIREARCH_LOG"
  fi

  printf '\n  %s\n' "$(t err.rerun)"
  printf '  %s  bash %s/install.sh%s\n\n' "$C_FIRE" "${FIREARCH_ROOT:-.}" "$C_RESET"
  _log "[FAIL] exit $ec at $where: $cmd"
}

trap catch_errors ERR
