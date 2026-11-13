#!/bin/bash
# Final screen: animated logo (tte), summary, collected warnings, next steps.

_distro="${WSL_DISTRO_NAME:-archlinux}"
_total="$(_fmt_dur $((SECONDS - UI_T0)))"

echo
if ((UI_INTERACTIVE)) && ((UI_COLS >= 88)) && command -v tte &>/dev/null; then
  tte -i "$FIREARCH_ROOT/logo.txt" --frame-rate 920 laseretch || ui_banner
fi

ui_box "$(t fin.title)" \
  "$(ui_row "$(t fin.user)" "${C_BOLD}${TARGET_USER}${C_RESET} ($(t fin.shell "${FIREARCH_SHELL:-bash}"))")" \
  "$(ui_row "$(t fin.time)" "$_total")" \
  "$(ui_row "$(t fin.warnings)" "${#UI_WARNINGS[@]}")" \
  "$(ui_row "$(t fin.log)" "$FIREARCH_LOG")"

if ((${#UI_WARNINGS[@]})); then
  printf '\n  %s%s%s\n' "$C_YELLOW" "$(t fin.warn_header)" "$C_RESET"
  for _warning in "${UI_WARNINGS[@]}"; do
    printf '  %s⚠%s %s\n' "$C_YELLOW" "$C_RESET" "$_warning"
  done
fi

printf '\n  %s%s%s\n' "$C_BOLD" "$(t fin.next)" "$C_RESET"
printf '  1. %s\n' "$(t fin.step1)"
printf '     %swsl --terminate %s%s\n' "$C_FIRE" "$_distro" "$C_RESET"
printf '  2. %s\n' "$(t fin.step2 "${C_FIRE}wsl -d ${_distro}${C_RESET}" "${C_BOLD}${TARGET_USER}${C_RESET}")"
printf '  3. %s\n\n' "$(t fin.step3)"

_log "[DONE] finished in $_total with ${#UI_WARNINGS[@]} warning(s)"
unset _distro _total _warning
