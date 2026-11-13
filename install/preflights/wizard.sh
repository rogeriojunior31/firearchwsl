#!/bin/bash
# Up-front questionnaire: asks EVERYTHING at once, before any slow step.
# After the confirmation the installer runs unattended to the end.
# Answering "no" on the summary goes back to the form; Ctrl+C cancels.
#
# Every answer can come from the environment (non-interactive mode):
#   FIREARCH_USER       Linux username                        (required)
#   FIREARCH_PASSWORD   user password            (required for a new user)
#   FIREARCH_GIT_NAME   git user.name                         (optional)
#   FIREARCH_GIT_EMAIL  git user.email                        (optional)
#   FIREARCH_HOSTNAME   WSL hostname            (default: current hostname)
#   FIREARCH_SHELL      bash | fish                           (default: bash)
#   FIREARCH_SKIP       components to skip: langs,lazyvim,doom,docker
#   FIREARCH_YES=1      skip the final confirmation (= --yes flag)

WIZARD_VARS=(FIREARCH_USER FIREARCH_PASSWORD FIREARCH_GIT_NAME FIREARCH_GIT_EMAIL
  FIREARCH_HOSTNAME FIREARCH_SHELL FIREARCH_SKIP)

## ── Validation ──────────────────────────────────────────────────────────────

_valid_username() { [[ "$1" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]; }

# System accounts (UID < 1000, e.g. root, bin, http) are never a valid target.
_system_username() {
  local uid
  uid="$(id -u "$1" 2>/dev/null || true)"
  [[ -n "$uid" ]] || return 1
  ((uid < 1000))
}

_valid_hostname() { [[ "$1" =~ ^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$ ]]; }

## ── Answers that came from outside are fixed; the rest can be re-asked ─────

declare -A _wizard_preset=()
if [[ -r /etc/firearchwsl/target_user ]]; then
  FIREARCH_USER="$(tr -d '[:space:]' </etc/firearchwsl/target_user)"
  msg "$(t wiz.user_known "${C_BOLD}${FIREARCH_USER}${C_RESET}")"
fi
for _var in "${WIZARD_VARS[@]}"; do
  if [[ "$_var" == FIREARCH_SKIP ]]; then
    [[ -n "${FIREARCH_SKIP+x}" ]] && _wizard_preset[$_var]=1
  else
    [[ -n "${!_var:-}" ]] && _wizard_preset[$_var]=1
  fi
done
unset _var

# Going back to the form: forget the answers typed here (presets stay), but
# remember them so every question comes back pre-filled. The password is
# never kept.
declare -A _wizard_prev=()
wizard_reset() {
  local var
  for var in "${WIZARD_VARS[@]}"; do
    [[ -n "${_wizard_preset[$var]:-}" ]] && continue
    [[ "$var" == FIREARCH_PASSWORD ]] || _wizard_prev[$var]="${!var:-}"
    unset "$var"
  done
}

# _prev VAR fallback — the previous answer to VAR, or fallback.
_prev() { printf '%s' "${_wizard_prev[$1]-$2}"; }

# True when going back to the form would ask at least one question.
wizard_has_askable() {
  local var
  for var in "${WIZARD_VARS[@]}"; do
    [[ -n "${_wizard_preset[$var]:-}" ]] && continue
    # An existing user's password is never asked.
    [[ "$var" == FIREARCH_PASSWORD ]] && id "$FIREARCH_USER" &>/dev/null && continue
    return 0
  done
  return 1
}

## ── The form ────────────────────────────────────────────────────────────────

wizard_ask_user() {
  while true; do
    ask_input FIREARCH_USER "$(t wiz.user_q)" "$(_prev FIREARCH_USER "")"
    if ! _valid_username "${FIREARCH_USER:-}"; then
      ((UI_INTERACTIVE)) || die "$(t wiz.user_invalid_env "${FIREARCH_USER:-}")"
      hint "$(t wiz.user_invalid)"
    elif _system_username "$FIREARCH_USER"; then
      ((UI_INTERACTIVE)) || die "$(t wiz.user_reserved "$FIREARCH_USER")"
      hint "$(t wiz.user_reserved "$FIREARCH_USER")"
    else
      break
    fi
    unset 'FIREARCH_USER' '_wizard_preset[FIREARCH_USER]'
  done
}

# Only a new user needs a password; an existing one keeps theirs.
wizard_ask_password() {
  id "$FIREARCH_USER" &>/dev/null && return 0
  [[ -n "${FIREARCH_PASSWORD:-}" ]] && return 0
  ((UI_INTERACTIVE)) || die "$(t wiz.pw_required_env "$FIREARCH_USER")"
  local confirmation
  while true; do
    ask_secret FIREARCH_PASSWORD "$(t wiz.pw_q "$FIREARCH_USER")"
    if [[ -z "$FIREARCH_PASSWORD" ]]; then
      hint "$(t wiz.pw_blank)"
      continue
    fi
    ask_secret confirmation "$(t wiz.pw_repeat)"
    [[ "$FIREARCH_PASSWORD" == "$confirmation" ]] && break
    hint "$(t wiz.pw_mismatch)"
  done
}

# On re-runs, offer the identity already configured as the default.
wizard_ask_git() {
  local def_name="" def_email=""
  if id "$FIREARCH_USER" &>/dev/null && command -v git &>/dev/null; then
    def_name="$(sudo -Hu "$FIREARCH_USER" git config --global user.name 2>/dev/null || true)"
    def_email="$(sudo -Hu "$FIREARCH_USER" git config --global user.email 2>/dev/null || true)"
  fi
  ask_input FIREARCH_GIT_NAME "$(t wiz.git_name_q)" "$(_prev FIREARCH_GIT_NAME "$def_name")"
  ask_input FIREARCH_GIT_EMAIL "$(t wiz.git_email_q)" "$(_prev FIREARCH_GIT_EMAIL "$def_email")"
}

wizard_ask_hostname() {
  while true; do
    ask_input FIREARCH_HOSTNAME "$(t wiz.hostname_q)" "$(_prev FIREARCH_HOSTNAME "$(uname -n)")"
    _valid_hostname "${FIREARCH_HOSTNAME:-}" && break
    ((UI_INTERACTIVE)) || die "$(t wiz.hostname_invalid "${FIREARCH_HOSTNAME:-}")"
    hint "$(t wiz.hostname_invalid "${FIREARCH_HOSTNAME:-}")"
    unset 'FIREARCH_HOSTNAME' '_wizard_preset[FIREARCH_HOSTNAME]'
  done
}

wizard_ask_components() {
  [[ -n "${FIREARCH_SKIP+x}" ]] && return 0
  FIREARCH_SKIP=""
  ((UI_INTERACTIVE)) || return 0
  # Not named `picked`: ask_multi has a local of that name, and printf -v
  # would write into it instead of into ours.
  local selection component
  ask_multi selection "$(t wiz.comp_q)" \
    "langs — $(t wiz.comp_langs)" \
    "lazyvim — $(t wiz.comp_lazyvim)" \
    "doom — $(t wiz.comp_doom)" \
    "docker — $(t wiz.comp_docker)"
  for component in langs lazyvim doom docker; do
    [[ " $selection " == *" $component "* ]] || FIREARCH_SKIP+="$component "
  done
  FIREARCH_SKIP="${FIREARCH_SKIP% }"
}

_on_off() {
  if component_enabled "$1"; then
    printf '%s%s%s' "$C_GREEN" "$(t ui.on)" "$C_RESET"
  else
    printf '%s%s%s' "$C_GRAY" "$(t ui.off)" "$C_RESET"
  fi
}

# "Name <email>", either half alone, or — when both were skipped.
_git_identity() {
  local name=${FIREARCH_GIT_NAME:-} email=${FIREARCH_GIT_EMAIL:-}
  if [[ -n "$name" && -n "$email" ]]; then
    printf '%s <%s>' "$name" "$email"
  elif [[ -n "$name$email" ]]; then
    printf '%s' "$name$email"
  else
    printf '—'
  fi
}

wizard_summary() {
  local user_note="" pw_status
  if id "$FIREARCH_USER" &>/dev/null; then
    user_note=" ${C_GRAY}($(t wiz.user_existing))${C_RESET}"
    pw_status="$(t wiz.pw_kept)"
  else
    pw_status="$(t wiz.pw_set)"
  fi
  ui_box "$(t wiz.sum_title)" \
    "$(ui_row "$(t wiz.sum_user)" "${C_BOLD}${FIREARCH_USER}${C_RESET}${user_note}")" \
    "$(ui_row "$(t wiz.sum_password)" "$pw_status")" \
    "$(ui_row "$(t wiz.sum_git)" "$(_git_identity)")" \
    "$(ui_row "$(t wiz.sum_hostname)" "$FIREARCH_HOSTNAME")" \
    "$(ui_row "$(t wiz.sum_shell)" "$FIREARCH_SHELL")" \
    "$(ui_row "$(t wiz.sum_langs)" "$(_on_off langs)")" \
    "$(ui_row "$(t wiz.sum_lazyvim)" "$(_on_off lazyvim)")" \
    "$(ui_row "$(t wiz.sum_doom)" "$(_on_off doom)")" \
    "$(ui_row "$(t wiz.sum_docker)" "$(_on_off docker)")"
}

## ── Run ─────────────────────────────────────────────────────────────────────

while true; do
  wizard_ask_user
  wizard_ask_password
  wizard_ask_git
  wizard_ask_hostname
  ask_choose FIREARCH_SHELL "$(t wiz.shell_q)" "$(_prev FIREARCH_SHELL bash)" bash fish
  wizard_ask_components
  wizard_summary

  [[ "${FIREARCH_YES:-0}" == "1" ]] && break
  ((UI_INTERACTIVE)) && hint "$(t wiz.confirm_hint)"
  ask_confirm "$(t wiz.confirm_q)" && break

  # "No": go back to the form, unless there is nothing left to change.
  wizard_has_askable || die "$(t wiz.aborted)"
  wizard_reset
  echo
done
export FIREARCH_SKIP FIREARCH_HOSTNAME
_log "[WIZARD] lang=$FIREARCH_LANG user=$FIREARCH_USER host=$FIREARCH_HOSTNAME shell=$FIREARCH_SHELL skip='${FIREARCH_SKIP}'"
