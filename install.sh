#!/bin/bash
# firearchwsl — orchestrator. Always the entry point:  bash install.sh
set -Eeuo pipefail

# Absolute repo root — base path for subscripts that copy payloads
FIREARCH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export FIREARCH_ROOT

FIREARCH_INSTALL="$FIREARCH_ROOT/install"
FIREARCH_SYSTEM="$FIREARCH_ROOT/system"
FIREARCH_CONFIG="$FIREARCH_ROOT/config"

# Library: i18n (t) + UI (step/run/ask_*) + target-user helpers
source "$FIREARCH_INSTALL/preflights/lib.sh"

# Language: FIREARCH_LANG if given, else the default until the picker runs.
_lang_from_env="${FIREARCH_LANG:-}"
if ! i18n_load "${FIREARCH_LANG:-$I18N_DEFAULT_LANG}"; then
  _bad_lang="$FIREARCH_LANG"
  i18n_load "$I18N_DEFAULT_LANG"
  echo "✖ $(t pre.unknown_lang "$_bad_lang" "$(i18n_available | tr '\n' ' ')")" >&2
  exit 2
fi

while (($#)); do
  case "$1" in
    -y | --yes) FIREARCH_YES=1 ;;
    -v | --verbose) FIREARCH_VERBOSE=1 ;;
    -h | --help)
      t usage
      echo
      exit 0
      ;;
    *)
      echo "✖ $(t pre.unknown_opt "$1")" >&2
      t usage >&2
      echo >&2
      exit 2
      ;;
  esac
  shift
done

if ((EUID != 0)); then
  echo "✖ $(t pre.need_root)" >&2
  exit 1
fi
if ! command -v pacman &>/dev/null; then
  echo "✖ $(t pre.need_pacman)" >&2
  exit 1
fi

UI_STEP_TOTAL=14
ui_init
source "$FIREARCH_INSTALL/preflights/trap-errors.sh"

# First question of all: which language to speak.
if [[ -z "$_lang_from_env" ]] && ((UI_INTERACTIVE)); then
  i18n_choose
fi
unset _lang_from_env

ui_banner

## ── Step 1: base ────────────────────────────────────────────────────────────
step "$(t step.base)"
run "$(t base.sync)" pacman -Syu --noconfirm
if ((UI_INTERACTIVE)) && ! command -v gum &>/dev/null; then
  run "$(t base.gum)" pacman -S --needed --noconfirm gum || warn "$(t base.gum_fail)"
fi
ui_detect_gum

## ── Questionnaire (ask everything now; run unattended afterwards) ───────────
source "$FIREARCH_INSTALL/preflights/wizard.sh"

## ── Steps 2..14 — the order is load-bearing, do not reshuffle ───────────────
# "<i18n title key>|<script>"
STEPS=(
  "step.user|$FIREARCH_SYSTEM/create_your_user.sh"
  "step.locale|$FIREARCH_SYSTEM/configure_locale.sh"
  "step.wsl|$FIREARCH_SYSTEM/wsl_config.sh"
  "step.essentials|$FIREARCH_INSTALL/preflights/essentials_pkgs.sh"
  "step.git|$FIREARCH_SYSTEM/configure_git_user.sh"
  "step.repos|$FIREARCH_INSTALL/preflights/repositories.sh"
  "step.mise|$FIREARCH_INSTALL/preflights/install-mise.sh"
  "step.tools|$FIREARCH_INSTALL/pkgs/good-tools.sh"
  "step.tuis|$FIREARCH_INSTALL/pkgs/tuis.sh"
  "step.langs|$FIREARCH_INSTALL/pkgs/install_langs.sh"
  "step.editors|$FIREARCH_INSTALL/pkgs/editors.sh"
  "step.config|$FIREARCH_CONFIG/config.sh"
  "step.docker|$FIREARCH_CONFIG/docker.sh"
)

for _entry in "${STEPS[@]}"; do
  step "$(t "${_entry%%|*}")"
  # shellcheck disable=SC1090
  source "${_entry#*|}"
done
unset _entry

## ── Finale ──────────────────────────────────────────────────────────────────
source "$FIREARCH_INSTALL/preflights/finale.sh"
