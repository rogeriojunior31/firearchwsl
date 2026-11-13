#!/bin/bash
# Toolchains through mise, installed into the target user's home.
# FIREARCH_MISE_TOOLS overrides the list (e.g. FIREARCH_MISE_TOOLS="python node").

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"

_tools="${FIREARCH_MISE_TOOLS:-python node bun rust go}"

# cargo is still needed by Neovim/LazyVim plugins that build from source.
# When mise does not provide Rust, fall back to the system package — and only
# then, so the user does not end up with two toolchains.
if ! component_enabled langs || [[ " $_tools " != *" rust "* ]]; then
  pac_install "$(t langs.rust_system)" rust
fi

if ! component_enabled langs; then
  skip "$(t langs.skip)"
  unset _tools
  return 0
fi

for _tool in $_tools; do
  # One failing toolchain does not abort the installer — it becomes a warning.
  run "mise: ${_tool}@latest" as_user mise use -g "${_tool}@latest" ||
    warn "$(t langs.fail "$_tool" "$_tool")"
done
unset _tool _tools
