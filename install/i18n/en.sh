# shellcheck shell=bash disable=SC2034,SC2088
# (SC2088: "~" in messages is display text, never expanded.)
# name: English
#
# Reference catalog: every key must exist here. Other languages override keys;
# anything they leave out falls back to this file.
# Values are printf formats — keep the %s / %d placeholders and their order.

# Declared by i18n.sh; repeated so tools know MSG is associative.
declare -gA MSG

I18N_LOCALE="en_US.UTF-8"
I18N_LANGUAGE="en_US"
I18N_YES_REGEX='^[yY]'
I18N_YES_NO_HINT="[Y/n]"

## Generic UI
MSG[ui.yes]="Yes"
MSG[ui.no]="No"
MSG[ui.on]="yes"
MSG[ui.off]="no"
MSG[ui.cancelled]="Cancelled."
MSG[ui.interrupted]="Interrupted by user."
MSG[ui.invalid_choice]="Invalid value for %s: '%s' (options: %s)"
MSG[ui.multi_hint]="space toggles · enter confirms"
MSG[ui.install_q]="Install %s?"
MSG[ui.pkg_count]="%s (%d packages)"
MSG[ui.pkg_missing]="Not found in any repository, skipped: %s"

## Banner
MSG[banner.tagline]="Arch Linux + WSL2, from zero to a full dev environment."
MSG[banner.log]="Full log: %s"

## Pre-checks and usage
MSG[pre.need_root]="Run as root inside the Arch WSL distro (e.g. wsl -d archlinux -u root)."
MSG[pre.need_pacman]="pacman not found — this installer only supports Arch Linux."
MSG[pre.unknown_opt]="Unknown option: %s"
MSG[pre.unknown_lang]="Unknown language '%s'. Available: %s"
MSG[usage]="firearchwsl — Arch Linux bootstrap for WSL2

Usage (as root, inside the Arch WSL distro):
  bash install.sh [options]

Options:
  -y, --yes       skip the final confirmation of the summary
  -v, --verbose   show raw command output (no spinner)
  -h, --help      show this help

Environment variables (all optional in interactive mode):
  FIREARCH_LANG        installer language: en, pt_BR
  FIREARCH_USER        Linux username to create
  FIREARCH_PASSWORD    user password (required for a new user without a terminal)
  FIREARCH_GIT_NAME    git config user.name
  FIREARCH_GIT_EMAIL   git config user.email
  FIREARCH_HOSTNAME    distro hostname (default: the Windows machine name)
  FIREARCH_SHELL       default shell: bash (default) or fish
  FIREARCH_PROFILE     minimal, dev (default), full or custom
  FIREARCH_SKIP        components to skip: tuis,langs,lazyvim,doom,docker
                       (overrides the profile)
  FIREARCH_MISE_TOOLS  mise toolchains (default: \"python node bun rust go\")
  FIREARCH_HOME_DIRS   folders created in the home (default: \"Projects Work Notes\")
  FIREARCH_VERBOSE=1   same as --verbose
  FIREARCH_NO_GUM=1    plain prompts instead of gum
  FIREARCH_TUI=0       line-by-line output instead of the full-screen view
  FIREARCH_LOG         log file path
  FORCE_CONFIG=1       overwrite ~/.bashrc and config.fish (backs them up first)
  DISABLE_CHAOTIC=1    do not add the Chaotic-AUR repository

Fully unattended example:
  FIREARCH_LANG=en FIREARCH_USER=jane FIREARCH_PASSWORD='s3cret' \\
  FIREARCH_GIT_NAME='Jane Doe' FIREARCH_GIT_EMAIL='jane@example.com' \\
  FIREARCH_SKIP=doom bash install.sh --yes"

## Error trap
MSG[err.title]="firearchwsl installation failed"
MSG[err.step]="Step:"
MSG[err.command]="Command:"
MSG[err.where]="Where:"
MSG[err.log_tail]="Last log lines:"
MSG[err.log_full]="Full log:"
MSG[err.menu_q]="What now?"
MSG[err.menu_retry]="try again (everything done so far is kept)"
MSG[err.menu_log]="read the full log"
MSG[err.menu_exit]="quit"
MSG[err.rerun]="The installer is idempotent — fix the problem and run it again:"

## Step titles
MSG[step.base]="Preparing the base system"
MSG[step.user]="User and sudo"
MSG[step.locale]="System locale"
MSG[step.wsl]="WSL tweaks"
MSG[step.essentials]="Essential packages"
MSG[step.git]="Git"
MSG[step.repos]="Extra repositories"
MSG[step.mise]="mise"
MSG[step.tools]="Command-line tools"
MSG[step.tuis]="TUIs"
MSG[step.langs]="Languages (mise)"
MSG[step.editors]="Editors"
MSG[step.config]="User config"
MSG[step.docker]="Docker"

## Base
MSG[base.sync]="Updating the system (pacman -Su)"
MSG[base.keyring_init]="Initializing the pacman keyring"
MSG[base.keyring_update]="Updating archlinux-keyring"
MSG[base.gum]="Installing gum (interactive prompts)"
MSG[base.gum_fail]="gum unavailable — falling back to plain prompts."

## Wizard
MSG[wiz.title]="Let's set up your environment"
MSG[wiz.user_known]="User registered by a previous run: %s"
MSG[wiz.user_q]="Your Linux username (lowercase, no spaces)"
MSG[wiz.user_invalid_env]="FIREARCH_USER missing or invalid ('%s'). E.g.: FIREARCH_USER=jane bash install.sh"
MSG[wiz.user_invalid]="Invalid name: use lowercase letters, digits, '-' or '_' (and not 'root')."
MSG[wiz.user_reserved]="'%s' is a system account — pick another name."
MSG[wiz.user_existing]="already exists"
MSG[wiz.pw_q]="Password for %s (used by sudo)"
MSG[wiz.pw_repeat]="Repeat the password"
MSG[wiz.pw_blank]="The password cannot be empty."
MSG[wiz.pw_required_env]="A new user needs a password: set FIREARCH_PASSWORD or run in a terminal (user: %s)."
MSG[wiz.pw_mismatch]="Passwords do not match (or are empty). Try again."
MSG[wiz.git_name_q]="Your name for Git — user.name (empty = skip)"
MSG[wiz.git_email_q]="Your email for Git — user.email (empty = skip)"
MSG[wiz.hostname_q]="Hostname of this WSL distro"
MSG[wiz.hostname_invalid]="Invalid hostname '%s': letters, digits and '-', up to 63 characters."
MSG[wiz.shell_q]="Default shell for the user"
MSG[wiz.comp_q]="Optional components"
MSG[wiz.comp_langs]="Python · Node · Bun · Rust · Go via mise"
MSG[wiz.comp_lazyvim]="Neovim with LazyVim"
MSG[wiz.comp_doom]="Doom Emacs (takes 5 to 15 min)"
MSG[wiz.comp_docker]="Docker + buildx + compose"
MSG[wiz.profile_q]="Installation profile"
MSG[wiz.profile_minimal]="CLIs, shells and prompt only (fastest)"
MSG[wiz.profile_dev]="Everything except Doom Emacs (recommended)"
MSG[wiz.profile_full]="Everything, Doom Emacs included (+5 to 15 min)"
MSG[wiz.profile_custom]="Pick components and languages one by one"
MSG[wiz.comp_tuis]="TUIs: lazygit, lazydocker, yazi, atuin, fzf…"
MSG[wiz.langs_q]="Languages via mise"
MSG[wiz.sum_profile]="Profile"
MSG[wiz.sum_tuis]="TUIs"
MSG[wiz.sum_title]="Installation summary"
MSG[wiz.sum_user]="User"
MSG[wiz.sum_password]="Password"
MSG[wiz.sum_git]="Git"
MSG[wiz.sum_hostname]="Hostname"
MSG[wiz.sum_shell]="Default shell"
MSG[wiz.sum_langs]="Languages"
MSG[wiz.sum_lazyvim]="LazyVim"
MSG[wiz.sum_doom]="Doom Emacs"
MSG[wiz.sum_docker]="Docker"
MSG[wiz.pw_set]="set"
MSG[wiz.pw_kept]="kept (user already exists)"
MSG[wiz.confirm_q]="All good? Start the installation?"
MSG[wiz.confirm_hint]="No = edit the answers · Ctrl+C = cancel"
MSG[wiz.aborted]="Installation cancelled — nothing was changed besides the base system update."

## User
MSG[user.need_root]="This script must run as root."
MSG[user.sudo]="Installing sudo"
MSG[user.exists]="User '%s' already exists — moving on."
MSG[user.add_wheel]="Adding '%s' to the wheel group"
MSG[user.create]="Creating user '%s' (wheel group)"
MSG[user.pw_set]="Password set for '%s'."
MSG[user.sudoers_invalid]="Invalid sudoers drop-in — removed. Aborting."
MSG[user.sudo_ok]="sudo enabled for the wheel group."

## Locale
MSG[locale.gen]="Generating locales (%s)"
MSG[locale.present]="Locales already generated: %s."
MSG[locale.done]="Default language: %s (/etc/locale.conf)."

## WSL
MSG[wsl.default_user]="WSL default user: %s (/etc/wsl.conf)."
MSG[wsl.hostname]="Hostname: %s (applied on the next WSL start)."
MSG[wsl.hostname_kept]="Hostname: %s (follows the Windows machine name)."
MSG[wsl.systemd]="systemd enabled at WSL boot."
MSG[wsl.libedit]="libedit.so.2 shim created."
MSG[wsl.libedit_skip]="libedit.so not present — libedit.so.2 shim not needed right now."
MSG[wsl.mise_ignore]="mise ignores the Windows-side config (%s)."
MSG[wsl.mise_ignore_skip]="%s already exists — add %s to its ignored_config_paths yourself if needed."
MSG[wsl.no_interop]="Windows interop unavailable — mise may also read the Windows-side config."

## Packages
MSG[ess.install]="Installing essentials"
MSG[tools.install]="Installing CLIs and fonts"
MSG[tuis.install]="Installing TUIs and yazi previewers"
MSG[tuis.skip]="TUIs skipped (component disabled)."
MSG[mise.install]="Installing mise"

## Git
MSG[git.name_skip]="user.name not provided — later: git config --global user.name \"Your Name\""
MSG[git.email_skip]="user.email not provided — later: git config --global user.email \"you@example.com\""
MSG[git.defaults]="Defaults applied: main branch, pull.rebase, aliases co/br/ci/st."

## Repositories
MSG[repo.candy]="pacman: Color + ILoveCandy + VerbosePkgLists."
MSG[repo.omarchy]="Omarchy repository enabled (last, so signed repos win)."
MSG[repo.mirrors]="Mirrorlist: global mirrors (original kept in %s)."
MSG[repo.chaotic_disabled]="Chaotic-AUR disabled (DISABLE_CHAOTIC)."
MSG[repo.chaotic_arch]="Chaotic-AUR only exists for x86_64 — skipping."
MSG[repo.chaotic_already]="Chaotic-AUR repository already enabled."
MSG[repo.chaotic_setup]="Installing Chaotic-AUR keyring and mirrorlist"
MSG[repo.chaotic_ok]="Chaotic-AUR repository enabled."
MSG[repo.chaotic_fail]="Chaotic-AUR failed — continuing without it (use DISABLE_CHAOTIC=1 to skip it for good)."
MSG[repo.sync]="Syncing repositories (pacman -Syu)"

## Languages
MSG[langs.skip]="Languages skipped (FIREARCH_SKIP=langs)."
MSG[langs.rust_system]="Installing system Rust (cargo)"
MSG[langs.fail]="Failed to install %s — later: mise use -g %s@latest"

## Editors
MSG[ed.lazy_skip]="LazyVim skipped (FIREARCH_SKIP=lazyvim)."
MSG[ed.lazy_exists]="~/.config/nvim already exists — LazyVim left untouched."
MSG[ed.lazy_clone]="Cloning the LazyVim starter"
MSG[ed.lazy_fail]="LazyVim failed — check the log and clone it manually: https://www.lazyvim.org/installation"
MSG[ed.doom_skip]="Doom Emacs skipped (FIREARCH_SKIP=doom)."
MSG[ed.emacs]="Installing Emacs"
MSG[ed.doom_exists]="Doom Emacs already installed in ~/.emacs.d."
MSG[ed.doom_clone]="Cloning Doom Emacs"
MSG[ed.doom_note]="Doom Emacs downloads and compiles packages: 5 to 15 min. Good time for a coffee ☕"
MSG[ed.doom_fail]="doom install returned an error — later run: ~/.emacs.d/bin/doom doctor"

## User config
MSG[cfg.payloads]="Payloads copied to ~/.local/share/firearchwsl."
MSG[cfg.rc_installed]="%s installed."
MSG[cfg.rc_current]="%s is already up to date."
MSG[cfg.rc_updated]="%s updated to the new default (it had no local edits)."
MSG[cfg.rc_overwritten]="%s overwritten (backup: %s)."
MSG[cfg.rc_preserved]="%s has local edits — preserved (FORCE_CONFIG=1 overwrites with a backup)."
MSG[cfg.starship]="Starship pointed at the firearchwsl theme."
MSG[cfg.cli]="Command firearch installed: update, doctor, setup, logs."
MSG[cfg.home_dirs]="Folders in your home: %s."
MSG[cfg.home_dir_invalid]="Skipping folder %s — use a name relative to the home."
MSG[cfg.shell_missing]="Shell %s not found — keeping the current shell."
MSG[cfg.shell_already]="Default shell is already %s."
MSG[cfg.shell_set]="Setting %s as the default shell"

## Docker
MSG[docker.skip]="Docker skipped (FIREARCH_SKIP=docker)."
MSG[docker.install]="Installing Docker"
MSG[docker.daemon_new]="/etc/docker/daemon.json created (logs: 10 MB x 5 files)."
MSG[docker.daemon_keep]="/etc/docker/daemon.json already exists — preserved."
MSG[docker.group_already]="%s is already in the docker group."
MSG[docker.group_add]="Adding %s to the docker group"
MSG[docker.enable]="Enabling and starting the docker service"
MSG[docker.enable_fail]="Could not start docker — later: sudo systemctl enable --now docker"
MSG[docker.no_systemd]="systemd is not active in this session — after restarting WSL run: sudo systemctl enable --now docker"

## Finale
MSG[fin.title]="All done! 🔥"
MSG[fin.user]="User"
MSG[fin.shell]="shell: %s"
MSG[fin.profile]="Profile"
MSG[fin.time]="Total time"
MSG[fin.warnings]="Warnings"
MSG[fin.log]="Full log"
MSG[fin.warn_header]="Warnings from this run:"
MSG[fin.next]="Next steps"
MSG[fin.step1]="In Windows PowerShell, restart the distro:"
MSG[fin.step2]="Open it again with %s — you will log in as %s."
MSG[fin.step3]="Type %s anytime for the menu: update, doctor, setup again."
MSG[fin.step4]="Use a Nerd Font in your Windows terminal to see the prompt icons."

## firearch command (bin/firearch)
MSG[cli.usage]="firearch — your firearchwsl companion

Usage:
  firearch            menu
  firearch update     system packages, mise tools and firearchwsl itself
  firearch doctor     check the WSL environment
  firearch setup      run the installer again (asks the questions again)
  firearch logs       open the latest installer log
  firearch version    show the firearchwsl version"
MSG[cli.menu_q]="What do you want to do?"
MSG[cli.menu_doctor]="check the environment"
MSG[cli.menu_update]="update packages, tools and firearchwsl"
MSG[cli.menu_setup]="run the installer again"
MSG[cli.menu_logs]="open the latest installer log"
MSG[cli.menu_quit]="quit"
MSG[cli.sudo_fail]="sudo is needed for this command."
MSG[cli.update_title]="Update"
MSG[cli.update_pkgs]="Updating system packages"
MSG[cli.update_pkgs_fail]="pacman -Syu failed — see the output of: sudo pacman -Syu"
MSG[cli.update_mise]="Updating mise tools"
MSG[cli.update_mise_fail]="mise upgrade failed — run it by hand to see why."
MSG[cli.update_no_git]="%s is not a git checkout — firearchwsl itself was not updated."
MSG[cli.update_dirty]="%s has local changes — firearchwsl itself was not updated."
MSG[cli.update_fetch]="Fetching firearchwsl (%s)"
MSG[cli.update_fetch_fail]="Could not reach the firearchwsl repository."
MSG[cli.update_current]="firearchwsl is up to date: %s"
MSG[cli.update_done]="firearchwsl updated to %s"
MSG[cli.update_apply]="Run 'firearch setup' to apply the new version."
MSG[cli.doctor_title]="Doctor"
MSG[cli.report_ok]="Everything looks good."
MSG[cli.report_warn]="%d item(s) need attention (see above)."
MSG[cli.logs_none]="No installer log in /var/log/firearchwsl."

## firearch doctor checks
MSG[doc.wsl]="Running inside WSL"
MSG[doc.wsl_fix]="firearchwsl is made for WSL2."
MSG[doc.systemd]="systemd is running"
MSG[doc.systemd_fix]="In PowerShell: wsl --terminate %s (systemd=true is in /etc/wsl.conf)."
MSG[doc.default_user]="%s is the WSL default user"
MSG[doc.default_user_fix]="Run 'firearch setup' to write it to /etc/wsl.conf."
MSG[doc.wheel]="%s can use sudo (wheel group)"
MSG[doc.wheel_fix]="As root: usermod -aG wheel <user>"
MSG[doc.interop]="Windows interop works (cmd.exe reachable)"
MSG[doc.interop_fix]="Check [interop] in /etc/wsl.conf and restart the distro."
MSG[doc.dns]="DNS resolves archlinux.org"
MSG[doc.dns_fix]="Check /etc/resolv.conf, a VPN or the WSL networking mode."
MSG[doc.locale]="Locale is valid"
MSG[doc.locale_fix]="Run 'firearch setup' to generate it again."
MSG[doc.disk]="More than 5 GB free on /"
MSG[doc.disk_fix]="Free some space: sudo pacman -Sc, docker system prune."
MSG[doc.mise]="mise tools are installed"
MSG[doc.mise_fix]="Run: mise install"
MSG[doc.docker]="Docker service is active"
MSG[doc.docker_fix]="Run: sudo systemctl enable --now docker"
MSG[doc.docker_group]="%s is in the docker group"
MSG[doc.docker_group_fix]="In PowerShell: wsl --terminate %s (the group applies on the next start)."
MSG[doc.font_hint]="Prompt icons look like boxes? Use a Nerd Font in the terminal (bootstrap.ps1 installs CaskaydiaMono Nerd Font)."
