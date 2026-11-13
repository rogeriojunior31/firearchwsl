#!/bin/bash
# Toolchains through mise, installed into the target user's home.
# FIREARCH_MISE_TOOLS overrides the list (e.g. FIREARCH_MISE_TOOLS="python node").

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"

if ! component_enabled langs; then
  skip "$(t langs.skip)"
  return 0
fi

for _tool in ${FIREARCH_MISE_TOOLS:-python node bun rust go}; do
  # One failing toolchain does not abort the installer — it becomes a warning.
  run "mise: ${_tool}@latest" as_user mise use -g "${_tool}@latest" ||
    warn "$(t langs.fail "$_tool" "$_tool")"
done
unset _tool
