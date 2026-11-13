```
███████╗██╗██████╗ ███████╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗    ██╗███████╗██╗
██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║    ██║██╔════╝██║
█████╗  ██║██████╔╝█████╗  ███████║██████╔╝██║     ███████║██║ █╗ ██║███████╗██║
██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║██║███╗██║╚════██║██║
██║     ██║██║  ██║███████╗██║  ██║██║  ██║╚██████╗██║  ██║╚███╔███╔╝███████║███████╗
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝
                                                                    by Rogerio Junior
```

# firearchwsl 🔥

**[Português](README.md)** · English

Bootstrap for **Arch Linux on WSL2**: one command takes a fresh Arch distro to a complete development environment.

You answer a few questions up front, confirm the summary and go grab a coffee. The installer then runs on its own, showing each step with a spinner and elapsed time, and keeps the full output in a log file. The installer speaks **English and Portuguese**.

---

## Quick start

In **PowerShell** on Windows:

```powershell
irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/main/bootstrap.ps1 | iex
```

This installs the official Arch Linux distro (if you do not have it yet), fetches firearchwsl into it and starts the installer. Then it installs **CaskaydiaMono Nerd Font** for your Windows user and adds a **FireArch** Windows Terminal profile (font + Tokyo Night + 🔥 icon), both without admin rights. The profile is a Windows Terminal fragment, so your `settings.json` is never touched. When it finishes, open the new environment with `wsl -d archlinux` or the FireArch profile.

Options (download the script first, or use the scriptblock form):

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/main/bootstrap.ps1))) -Name archdev
```

| Parameter | Effect |
|-----------|--------|
| `-Name <distro>` | Distro name to create or reuse (default `archlinux`) |
| `-Branch <branch>` | Branch to clone (default `main`) |
| `-Source <path>` | Copy a local checkout instead of cloning |
| `-Yes` | Skip the installer's final confirmation |
| `-VerboseInstall` | Raw command output instead of spinners |
| `-NoFont` | Do not install the Nerd Font (or `$env:FIREARCH_NO_FONT = '1'`) |
| `-NoTerminal` | Do not add the Windows Terminal profile (or `$env:FIREARCH_NO_TERMINAL = '1'`) |

### Manual install

Inside an Arch WSL distro, as `root`:

```bash
pacman -Syu --noconfirm git
git clone https://github.com/rogeriojunior31/firearchwsl.git
cd firearchwsl
bash install.sh
```

---

## The questions

1. **Language** of the installer.
2. **Username** to create. System accounts (`root`, `bin`, `http`…) and invalid names are rejected right away.
3. **Password**, typed twice. It cannot be empty: it is your `sudo` password.
4. **Git name and email** (leave empty to skip).
5. **Hostname** of the distro. Enter keeps the Windows machine name.
6. **Default shell**: `bash` or `fish`.
7. **Profile**: `minimal` (CLIs, shells and prompt only), `dev` *(default, everything but Doom Emacs)*, `full` (everything, +5 to 15 min for Doom Emacs) or `custom` (pick TUIs, languages, LazyVim, Doom Emacs and Docker, and each language: Python, Node, Bun, Rust, Go).

Then the summary: **Yes** starts the installation; **No** goes back to the form with your answers pre-filled; **Ctrl+C** cancels.

While it runs, every step header shows the overall progress (bar, percentage, elapsed time), mirrored in the tab title and in the Windows Terminal tab/taskbar progress ring, which turns red if something fails.

## What you get

- A non-root user in `wheel` with `sudo`, set as the **WSL default user**.
- The locale of the chosen language, git configured, optional custom hostname.
- **Chaotic-AUR** and **Omarchy** repositories (Omarchy is unsigned, so it is placed last: signed repos always win).
- **mise** with Python, Node, Bun, Rust and Go *(optional)*. mise is told to ignore the Windows-side `~/.config/mise`.
- **bash** and **fish** ready to go, **starship** prompt, modern CLIs (`eza`, `bat`, `fd`, `ripgrep`, `zoxide`, `atuin`, `fzf`…) and TUIs (`lazygit`, `lazydocker`, `yazi`, `zellij`…).
- `~/Projects`, `~/Work` and `~/Notes` ready in your home (`FIREARCH_HOME_DIRS` changes the list; `""` creates none).
- **LazyVim** and **Doom Emacs** *(optional)*.
- Native **Docker** with `buildx` and `compose` *(optional)*.

## Unattended mode

Every question has an environment variable; with `--yes` nothing is asked:

```bash
FIREARCH_LANG=en FIREARCH_USER=jane FIREARCH_PASSWORD='s3cret' \
FIREARCH_GIT_NAME='Jane Doe' FIREARCH_GIT_EMAIL='jane@example.com' \
FIREARCH_HOSTNAME=devbox FIREARCH_SHELL=fish FIREARCH_PROFILE=minimal \
bash install.sh --yes
```

A new user always needs a password: without a terminal and without `FIREARCH_PASSWORD`, the installer stops before changing anything. `bash install.sh --help` lists every variable.

`FIREARCH_PROFILE` picks a profile; `FIREARCH_SKIP` (`tuis,langs,lazyvim,doom,docker`) picks components one by one and overrides it. With neither, unattended runs use `dev`.

The same variables work with `bootstrap.ps1`: set them with `$env:FIREARCH_USER = '...'` before running it and they are forwarded into WSL.

## The `firearch` command

After the install, `firearch` is on your PATH. Without arguments it opens a menu.

| Command | What it does |
|---------|--------------|
| `firearch update` | `pacman -Syu`, `mise upgrade`, and updates firearchwsl itself (`/opt/firearchwsl`) |
| `firearch doctor` | Checks WSL, systemd, default user, sudo, Windows interop, DNS, locale, disk space, mise and Docker, each with its fix |
| `firearch setup` | Runs the installer again (asks the questions again) |
| `firearch logs` | Opens the latest installer log |
| `firearch version` | Shows the installed version |

It speaks the language picked at install time (`/etc/firearchwsl/lang`; `FIREARCH_LANG` overrides it).

## Re-running

Safe at any time: packages are `--needed`, `/etc` edits are idempotent, the user is remembered in `/etc/firearchwsl/target_user`, rc files you never edited are upgraded and the ones you edited are preserved (`FORCE_CONFIG=1` overwrites them, keeping a backup).

## Development

```bash
bash tests/check.sh       # bash -n, shellcheck, fish -n, i18n catalogs, line endings
bash tests/container.sh   # full install, twice, in a clean Arch container (needs Docker)
```

CI (`.github/workflows/ci.yml`) runs both on every push and pull request.

Conventions: code, identifiers and comments in English; every user-facing string through `t <key>` with its translation in `install/i18n/*.sh`; slow commands inside `run "label" …`. Adding a language is one file: copy `install/i18n/en.sh`, translate the values, keep the `%s` placeholders. See `AGENTS.md` in each directory for the details.

## Credits

Author: Rogerio Junior. Inspired by [Omarchy](https://omarchy.org/); built on [Chaotic-AUR](https://aur.chaotic.cx/), [mise](https://mise.jdx.dev/), [starship](https://starship.rs/), [LazyVim](https://www.lazyvim.org/), [Doom Emacs](https://github.com/doomemacs/doomemacs), [gum](https://github.com/charmbracelet/gum) and [terminaltexteffects](https://github.com/ChrisBuilds/terminaltexteffects).
