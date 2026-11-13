#!/bin/bash
# Creates the non-root user (wheel group), enables sudo and records the
# target user. Asks nothing: FIREARCH_USER / FIREARCH_PASSWORD come from
# wizard.sh.

if [[ $EUID -ne 0 ]]; then
  echo "✖ $(t user.need_root)"
  return 1 2>/dev/null || exit 1
fi
: "${FIREARCH_USER:?FIREARCH_USER not set — run through install.sh}"

username="$FIREARCH_USER"

run "$(t user.sudo)" pacman -S --needed --noconfirm sudo

if id "$username" &>/dev/null; then
  ok "$(t user.exists "$username")"
  if ! id -nG "$username" | tr ' ' '\n' | grep -qx wheel; then
    run "$(t user.add_wheel "$username")" usermod -aG wheel "$username"
  fi
else
  # wizard.sh guarantees a password for a new user; never create one without.
  [[ -n "${FIREARCH_PASSWORD:-}" ]] || die "$(t wiz.pw_required_env "$username")"
  run "$(t user.create "$username")" useradd -m -G wheel -s /bin/bash "$username"
  # Through stdin: the password never shows up in argv or in the log.
  printf '%s:%s\n' "$username" "$FIREARCH_PASSWORD" | chpasswd
  ok "$(t user.pw_set "$username")"
fi
unset FIREARCH_PASSWORD

# sudo for the wheel group through a drop-in (never edits /etc/sudoers)
sudoers_dropin=/etc/sudoers.d/10-firearchwsl-wheel
install -d -m 0750 /etc/sudoers.d
printf '%s\n' '%wheel ALL=(ALL:ALL) ALL' >"$sudoers_dropin"
chmod 0440 "$sudoers_dropin"
if ! visudo -cf "$sudoers_dropin" >/dev/null 2>&1; then
  rm -f "$sudoers_dropin"
  die "$(t user.sudoers_invalid)"
fi
ok "$(t user.sudo_ok)"

# Single source of truth for the target user on re-runs
mkdir -p /etc/firearchwsl
printf '%s\n' "$username" >/etc/firearchwsl/target_user

export TARGET_USER="$username"
TARGET_HOME="$(getent passwd "$username" | cut -d: -f6)"
export TARGET_HOME
ensure_target_user
unset username sudoers_dropin
