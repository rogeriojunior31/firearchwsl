#!/bin/bash
# Up-front questionnaire: asks EVERYTHING at once, before any slow step.
# After the confirmation the installer runs unattended to the end.
#
# Every answer can come from the environment (non-interactive mode):
#   FIREARCH_USER       Linux username                        (required)
#   FIREARCH_PASSWORD   user password                         (optional)
#   FIREARCH_GIT_NAME   git user.name                         (optional)
#   FIREARCH_GIT_EMAIL  git user.email                        (optional)
#   FIREARCH_SHELL      bash | fish                           (default: bash)
#   FIREARCH_SKIP       components to skip: langs,lazyvim,doom,docker
#   FIREARCH_YES=1      skip the final confirmation (= --yes flag)

_valid_username() { [[ "$1" =~ ^[a-z_][a-z0-9_-]{0,31}$ && "$1" != "root" ]]; }

## ── User ────────────────────────────────────────────────────────────────────
if [[ -r /etc/firearchwsl/target_user ]]; then
  FIREARCH_USER="$(tr -d '[:space:]' </etc/firearchwsl/target_user)"
  msg "$(t wiz.user_known "${C_BOLD}${FIREARCH_USER}${C_RESET}")"
fi

while true; do
  ask_input FIREARCH_USER "$(t wiz.user_q)"
  if _valid_username "${FIREARCH_USER:-}"; then break; fi
  ((UI_INTERACTIVE)) || die "$(t wiz.user_invalid_env "${FIREARCH_USER:-}")"
  hint "$(t wiz.user_invalid)"
  FIREARCH_USER=""
done

## ── Password (only when the user does not exist yet) ────────────────────────
FIREARCH_PASSWORD="${FIREARCH_PASSWORD:-}"
if ! id "$FIREARCH_USER" &>/dev/null && [[ -z "$FIREARCH_PASSWORD" ]] && ((UI_INTERACTIVE)); then
  while true; do
    ask_secret FIREARCH_PASSWORD "$(t wiz.pw_q "$FIREARCH_USER")"
    ask_secret _pw_confirm "$(t wiz.pw_repeat)"
    if [[ -n "$FIREARCH_PASSWORD" && "$FIREARCH_PASSWORD" == "$_pw_confirm" ]]; then break; fi
    hint "$(t wiz.pw_mismatch)"
  done
  unset _pw_confirm
fi

## ── Git ─────────────────────────────────────────────────────────────────────
# On re-runs, offer the identity already configured as the default.
_git_def_name="" _git_def_email=""
if id "$FIREARCH_USER" &>/dev/null && command -v git &>/dev/null; then
  _git_def_name="$(sudo -Hu "$FIREARCH_USER" git config --global user.name 2>/dev/null || true)"
  _git_def_email="$(sudo -Hu "$FIREARCH_USER" git config --global user.email 2>/dev/null || true)"
fi
ask_input FIREARCH_GIT_NAME "$(t wiz.git_name_q)" "$_git_def_name"
ask_input FIREARCH_GIT_EMAIL "$(t wiz.git_email_q)" "$_git_def_email"
unset _git_def_name _git_def_email

## ── Default shell ───────────────────────────────────────────────────────────
ask_choose FIREARCH_SHELL "$(t wiz.shell_q)" bash bash fish

## ── Optional components ─────────────────────────────────────────────────────
if [[ -z "${FIREARCH_SKIP+x}" ]]; then
  FIREARCH_SKIP=""
  if ((UI_INTERACTIVE)); then
    ask_multi _picked "$(t wiz.comp_q)" \
      "langs — $(t wiz.comp_langs)" \
      "lazyvim — $(t wiz.comp_lazyvim)" \
      "doom — $(t wiz.comp_doom)" \
      "docker — $(t wiz.comp_docker)"
    for _component in langs lazyvim doom docker; do
      [[ " $_picked " == *" $_component "* ]] || FIREARCH_SKIP+="$_component "
    done
    FIREARCH_SKIP="${FIREARCH_SKIP% }"
    unset _picked _component
  fi
fi
export FIREARCH_SKIP

## ── Summary + confirmation ──────────────────────────────────────────────────
_on_off() {
  if component_enabled "$1"; then
    printf '%s%s%s' "$C_GREEN" "$(t ui.on)" "$C_RESET"
  else
    printf '%s%s%s' "$C_GRAY" "$(t ui.off)" "$C_RESET"
  fi
}
_pw_status="$(t wiz.pw_set)"
if id "$FIREARCH_USER" &>/dev/null; then
  _pw_status="$(t wiz.pw_kept)"
elif [[ -z "$FIREARCH_PASSWORD" ]]; then
  _pw_status="${C_YELLOW}$(t wiz.pw_unset)${C_RESET}"
fi

ui_box "$(t wiz.sum_title)" \
  "$(ui_row "$(t wiz.sum_user)" "${C_BOLD}${FIREARCH_USER}${C_RESET}")" \
  "$(ui_row "$(t wiz.sum_password)" "$_pw_status")" \
  "$(ui_row "$(t wiz.sum_git)" "${FIREARCH_GIT_NAME:-—} <${FIREARCH_GIT_EMAIL:-—}>")" \
  "$(ui_row "$(t wiz.sum_shell)" "$FIREARCH_SHELL")" \
  "$(ui_row "$(t wiz.sum_langs)" "$(_on_off langs)")" \
  "$(ui_row "$(t wiz.sum_lazyvim)" "$(_on_off lazyvim)")" \
  "$(ui_row "$(t wiz.sum_doom)" "$(_on_off doom)")" \
  "$(ui_row "$(t wiz.sum_docker)" "$(_on_off docker)")"
unset _pw_status

if [[ "${FIREARCH_YES:-0}" != "1" ]]; then
  ask_confirm "$(t wiz.confirm_q)" || die "$(t wiz.aborted)"
fi
_log "[WIZARD] lang=$FIREARCH_LANG user=$FIREARCH_USER shell=$FIREARCH_SHELL skip='${FIREARCH_SKIP}'"
