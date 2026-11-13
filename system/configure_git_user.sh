#!/bin/bash
# git config --global for the target user. Name/email come from wizard.sh.

: "${TARGET_USER:?TARGET_USER not set — run through install.sh}"

if [[ -n "${FIREARCH_GIT_NAME:-}" ]]; then
  as_user git config --global user.name "$FIREARCH_GIT_NAME"
  ok "user.name  = $FIREARCH_GIT_NAME"
else
  skip "$(t git.name_skip)"
fi

if [[ -n "${FIREARCH_GIT_EMAIL:-}" ]]; then
  as_user git config --global user.email "$FIREARCH_GIT_EMAIL"
  ok "user.email = $FIREARCH_GIT_EMAIL"
else
  skip "$(t git.email_skip)"
fi

# Defaults and aliases
as_user git config --global init.defaultBranch main
as_user git config --global pull.rebase true
as_user git config --global alias.co checkout
as_user git config --global alias.br branch
as_user git config --global alias.ci commit
as_user git config --global alias.st status
ok "$(t git.defaults)"
