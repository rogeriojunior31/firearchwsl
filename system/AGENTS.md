<!-- Parent: ../AGENTS.md -->

# system

## Purpose

System-level configuration: scripts that touch `/etc/*` or create users/groups. All sourced by `install.sh` as root. None of them prompts — inputs come from `install/preflights/wizard.sh`.

## Key Files

| File | Description |
|------|-------------|
| `create_your_user.sh` | Installs `sudo`; creates `FIREARCH_USER` with `useradd -m -G wheel -s /bin/bash` (or adds an existing user to `wheel`); sets the password through `chpasswd` on stdin (never argv/log), or warns when none was given; writes the `/etc/sudoers.d/10-firearchwsl-wheel` drop-in validated by `visudo -cf`; records `/etc/firearchwsl/target_user`; exports `TARGET_USER`/`TARGET_HOME`. |
| `configure_locale.sh` | Enables `en_US.UTF-8` plus `I18N_LOCALE` (from the chosen language catalog) in `/etc/locale.gen`, runs `locale-gen`, writes `/etc/locale.conf` with `LANG=$I18N_LOCALE` and `LANGUAGE=$I18N_LANGUAGE`. |
| `wsl_config.sh` | `wsl_conf_set <section> <key> <value>` (idempotent `/etc/wsl.conf` editor). Sets `[user] default=$TARGET_USER` and `[boot] systemd=true`. Also the `libedit.so.2` shim when `libedit.so` exists. |
| `configure_git_user.sh` | `git config --global` for the target user: `user.name`/`user.email` when provided (skipped otherwise), `init.defaultBranch=main`, `pull.rebase=true`, aliases `co`/`br`/`ci`/`st`. |

## For AI Agents

### Working In This Directory

- Root guard pattern: `if [[ $EUID -ne 0 ]]; then …; return 1 2>/dev/null || exit 1; fi` (scripts are sourced).
- Do not edit `/etc/sudoers` directly; a fresh Arch WSL image does not even ship it until `sudo` is installed. Use the drop-in.
- `/etc/wsl.conf` may already carry settings (the official image ships `[boot] systemd=true`). Always go through `wsl_conf_set`; never overwrite the file.
- The WSL default user only takes effect after `wsl --terminate <distro>`.
- Do not run `pacman -Sy <pkg>` here (partial upgrade). The base is already synced by step 1.

### Testing Requirements

- `id <user>` shows `wheel`; `sudo -l -U <user>` shows `(ALL : ALL) ALL`.
- `locale -a` lists the generated locales; `/etc/locale.conf` carries the chosen `LANG`.
- `/etc/wsl.conf` has exactly one `[user]` and one `[boot]` section after two runs.
- `git config --global --list` as the user shows identity and aliases.

## Dependencies

- `../install/preflights/lib.sh` (`run`, `t`, `as_user`), `../install/preflights/wizard.sh` (inputs).
- `useradd`, `chpasswd`, `visudo`, `locale-gen`, `git`, `sed`.
