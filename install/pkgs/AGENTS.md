<!-- Parent: ../AGENTS.md -->

# pkgs

## Purpose

Package groups installed after the preflight phase. Groups are kept narrow on purpose so one can be swapped without disturbing the others.

## Key Files

| File | Description |
|------|-------------|
| `good-tools.sh` | Everyday CLIs, fonts and AUR helpers: `jq`, `yq`, `fd`, `ripgrep`, `zellij`, `neovim`, `glow`, `gum`, `starship`, `zoxide`, `python-terminaltexteffects` (`tte`), `yay`, `paru`, nerd fonts, `fastfetch`… |
| `tuis.sh` | TUIs and the yazi preview stack: `lazygit`, `lazydocker`, `yazi`, `television`, `navi`, `atuin`, `fzf`, `superfile`, `imagemagick`, `poppler`, `chafa`… |
| `install_langs.sh` | Optional component `langs`. `as_user mise use -g <tool>@latest` for each tool in `FIREARCH_MISE_TOOLS` (default `python node bun rust go`). A failing tool becomes a warning. When mise will not provide Rust (langs skipped, or `rust` not in the list) it installs the pacman `rust` instead, so `cargo` always exists without two toolchains. |
| `editors.sh` | Optional components `lazyvim` and `doom`. LazyVim starter cloned into `~/.config/nvim` (only if the dir is absent). Doom: installs `emacs`, clones into `~/.emacs.d`, runs `doom --force install`. Failures are warnings. |

## For AI Agents

### Working In This Directory

- Pacman group file shape: comment header, `PACMAN_PKGS=()`, one `pac_install` call. No local helpers — everything comes from `preflights/ui.sh`.
- `pac_install` always uses `--needed --noconfirm`; reruns rely on it. Do not add `pacman -Sy`/`-Syu` here.
- One missing package name makes pacman reject the whole transaction (`target not found`). Check a new name with `pacman -Si <pkg>` on a configured distro; several packages (`yay`, `paru`, `python-terminaltexteffects`…) come from Chaotic-AUR/Omarchy, not the official repos.
- When adding a TUI with preview/helper deps, keep them in the same array (see the yazi cluster).
- Docker packages live in `../../config/docker.sh` and `emacs` in `editors.sh`, so skipping those components skips their packages too.
- Doom's CLI flags change between releases. The prompt-suppressing flag is the global `--force` (`-!`), placed before the subcommand.
- Everything user-scoped goes through `as_user` and `$TARGET_HOME`.

### Testing Requirements

- A second run prints `✔` for every group in a few seconds and reports LazyVim/Doom as already present.

## Dependencies

- `../preflights/repositories.sh` — Chaotic-AUR/Omarchy must be enabled first.
- `../preflights/install-mise.sh` — before `install_langs.sh`.
- `pacman`, `mise`, `git`, `github.com/LazyVim/starter`, `github.com/doomemacs/doomemacs`.
