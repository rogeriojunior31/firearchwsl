#!/bin/bash
# Final screen: animated logo (tte), summary, every step with its time,
# collected warnings, next steps.

tui_step_finish ok
tui_stop

_distro="${WSL_DISTRO_NAME:-archlinux}"
_total="$(_fmt_dur $((SECONDS - UI_T0)))"

if ((UI_INTERACTIVE)) && tui_supported; then
  printf '\e[H\e[2J\n'
  UI_PAD="$TUI_PAD"
  # tte draws the logo where it finds it: pad it into the centered column.
  _tui_load_logo
  if ((TUI_W >= UI_LOGO_W)) && command -v tte &>/dev/null &&
    sed "s/^/$TUI_PAD$(printf '%*s' $(((TUI_W - UI_LOGO_W) / 2)) '')/" "$FIREARCH_ROOT/logo.txt" |
    tte --frame-rate 920 laseretch 2>/dev/null; then
    :
  else
    _tui_logo_lines _screen_put
  fi
  echo
else
  echo
fi

ui_box "$(t fin.title)" \
  "$(ui_row "$(t fin.user)" "${C_BOLD}${TARGET_USER}${C_RESET} ($(t fin.shell "${FIREARCH_SHELL:-bash}"))")" \
  "$(ui_row "$(t fin.profile)" "${FIREARCH_PROFILE:-custom}")" \
  "$(ui_row "$(t fin.time)" "$_total")" \
  "$(ui_row "$(t fin.warnings)" "${#UI_WARNINGS[@]}")" \
  "$(ui_row "$(t fin.log)" "$FIREARCH_LOG")"

echo
ui_steps_recap

if ((${#UI_WARNINGS[@]})); then
  printf '\n%s%s%s%s\n' "$UI_PAD" "$C_YELLOW" "$(t fin.warn_header)" "$C_RESET"
  for _warning in "${UI_WARNINGS[@]}"; do
    printf '%s%s⚠%s %s\n' "$UI_PAD" "$C_YELLOW" "$C_RESET" "$_warning"
  done
fi

printf '\n%s%s%s%s\n' "$UI_PAD" "$C_BOLD" "$(t fin.next)" "$C_RESET"
printf '%s1. %s\n' "$UI_PAD" "$(t fin.step1)"
printf '%s   %swsl --terminate %s%s\n' "$UI_PAD" "$C_FIRE" "$_distro" "$C_RESET"
printf '%s2. %s\n' "$UI_PAD" "$(t fin.step2 "${C_FIRE}wsl -d ${_distro}${C_RESET}" "${C_BOLD}${TARGET_USER}${C_RESET}")"
printf '%s3. %s\n' "$UI_PAD" "$(t fin.step3 "${C_FIRE}firearch${C_RESET}")"
printf '%s4. %s\n\n' "$UI_PAD" "$(t fin.step4)"

_log "[DONE] finished in $_total with ${#UI_WARNINGS[@]} warning(s)"
unset _distro _total _warning
