#!/bin/bash
# firearchwsl i18n. Sourced by lib.sh.
#
# Catalogs live in install/i18n/<lang>.sh and fill the MSG associative array.
# en.sh is the reference; any other language only overrides keys.
#
#   i18n_load <lang>     load en.sh, then <lang>.sh on top of it
#   i18n_choose          ask for the language (interactive, FIREARCH_LANG unset)
#   t <key> [args…]      print the translated message (printf-style)
#
# Adding a language: copy install/i18n/en.sh to <lang>.sh, translate the
# values, set the "# name:" header and the I18N_* variables. Nothing else.

I18N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../i18n" && pwd)"
I18N_DEFAULT_LANG="pt_BR"
declare -gA MSG=()

# Language codes available on disk, one per line.
i18n_available() {
  local f
  for f in "$I18N_DIR"/*.sh; do
    basename "$f" .sh
  done
}

# Human-readable name from the "# name:" header of a catalog.
i18n_name() { sed -n 's/^# name: //p' "$I18N_DIR/$1.sh" | head -n 1; }

i18n_load() {
  local lang=$1
  MSG=()
  # shellcheck source=install/i18n/en.sh
  source "$I18N_DIR/en.sh"
  if [[ "$lang" != "en" ]]; then
    [[ -r "$I18N_DIR/$lang.sh" ]] || return 1
    # shellcheck disable=SC1090
    source "$I18N_DIR/$lang.sh"
  fi
  FIREARCH_LANG="$lang"
  export FIREARCH_LANG
}

# t <key> [args…] — unknown keys print the key itself, so gaps are easy to spot.
t() {
  local key=$1
  shift
  # shellcheck disable=SC2059
  printf -- "${MSG[$key]:-$key}" "$@"
}

# Numbered language picker. Plain `read` on purpose: it runs before gum exists.
i18n_choose() {
  local langs=() lang i choice
  mapfile -t langs < <(i18n_available)
  printf '\n  %sLanguage / Idioma%s\n' "${C_BOLD:-}" "${C_RESET:-}"
  for i in "${!langs[@]}"; do
    printf '  %s%d)%s %s\n' "${C_FIRE:-}" $((i + 1)) "${C_RESET:-}" "$(i18n_name "${langs[i]}")"
  done
  while true; do
    read -rp "  › [$(i18n_name "$FIREARCH_LANG")]: " choice || return 0
    [[ -z "$choice" ]] && return 0
    if [[ "$choice" =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#langs[@]})); then
      lang="${langs[choice - 1]}"
      i18n_load "$lang"
      return 0
    fi
  done
}
