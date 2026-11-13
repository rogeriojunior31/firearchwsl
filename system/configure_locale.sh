#!/bin/bash
# Generates en_US.UTF-8 plus the locale of the chosen installer language
# (I18N_LOCALE, from install/i18n/<lang>.sh) and makes the latter the default.

if [[ $EUID -ne 0 ]]; then
  echo "✖ $(t user.need_root)"
  return 1 2>/dev/null || exit 1
fi

_locales=("en_US.UTF-8")
[[ "$I18N_LOCALE" != "en_US.UTF-8" ]] && _locales+=("$I18N_LOCALE")

for _locale in "${_locales[@]}"; do
  _entry="$_locale UTF-8"
  sed -i "s/^#\s*\(${_entry}\)/\1/" /etc/locale.gen
  grep -q "^${_entry}" /etc/locale.gen || echo "$_entry" >>/etc/locale.gen
done

run "$(t locale.gen "${_locales[*]}")" locale-gen

printf 'LANG=%s\nLANGUAGE=%s\n' "$I18N_LOCALE" "$I18N_LANGUAGE" >/etc/locale.conf
ok "$(t locale.done "$I18N_LOCALE")"
unset _locales _locale _entry
