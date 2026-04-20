<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# pkgs

## Purpose

Package groups installed after the preflight phase. Each script owns its own `PACMAN_PKGS=()` array and `main()` that runs `pacman -Syu` (and `yay -Syu` for `tuis.sh`) before installing with `--needed --noconfirm`. Groups are kept narrow on purpose so a group can be swapped without disturbing others.

## Key Files

| File | Description |
|------|-------------|
| `good-tools.sh` | Core CLI utilities: `jq`, `yq`, `stow`, `fx`, `fd`, `ripgrep`, `7zip`/`zip`/`unzip`, `task`, `zellij`, `neovim`, `glow`, `harper`, `figlet`, `asciinema`, `docker` + `docker-buildx` + `docker-compose`, `dust`, `starship`, `tldr`, `tree-sitter-cli`, `zoxide`, `cargo`, `python-poetry-core`, `python-terminaltexteffects` (for `tte`), `bash-completion`, `yay`, `paru`, `luarocks`, nerd fonts (`cascadia-mono`, `jetbrains-mono`, `hack`), `fastfetch`, `emacs`. |
| `tuis.sh` | Terminal UIs and yazi preview stack: `taskwarrior-tui`, `tabiew`, `lazygit`, `television`, `navi`, `yazi`, `imagemagick`, `poppler`, `fzf`, `atuin`, `rsync`, `chafa`, `resvg`, `ffmpegthumbnailer`, `libcaca`, `lynx`, `mediainfo`, `odt2txt`, `perl-image-exiftool`, `python-pillow`, `python-chardet`, `ueberzug`, `w3m`, `lazydocker`, `superfile`. Also runs `yay -Syu`. |
| `install_langs.sh` | Language toolchains via mise: `mise use -g python@latest`, `node@latest`, `bun@latest`, `rust@latest`, `go@latest`. Runs after `preflights/install-mise.sh` has activated mise in the shell. |
| `editors.sh` | Editors cloned (not pacman-installed): LazyVim starter into `~/.config/nvim` (strips `.git`, appends `vim.opt.relativenumber = false`); Doom Emacs into `~/.emacs.d` with `doom install`. Each clone guarded on `[[ ! -d ... ]]` so reruns skip. |

## For AI Agents

### Working In This Directory

- File shape is uniform: shebang, `set -Eeuo pipefail`, `PACMAN_PKGS=()`, `msg`/`warn`/`die` helpers, `ensure_sudo`, `main()`, `main "$@"`. Copy the shape when adding a group.
- Always pass `--needed --noconfirm` to `pacman -S`. Never drop `--needed`: reruns rely on it.
- When adding a TUI with preview/helper deps, keep them in the same array (see the yazi cluster in `tuis.sh`).
- Known latent bug: `tuis.sh`'s `need_cmd()` is split across two lines (`command -v "$1" &` then `/dev/null` on the next line) which backgrounds the check and misroutes the redirect. It's unused by `main()` today — fix if you start calling it.

### Testing Requirements

- Install idempotence: rerun after the first successful install should print "skipping" / "already installed" for every package.

### Common Patterns

- Don't assume the target non-root user exists yet at this phase only for `editors.sh` — it still writes into `$HOME`, which at install time is root's home (the user-config copy in `config/config.sh` happens later).

## Dependencies

### Internal

- `../preflights/install-mise.sh` — must run before `install_langs.sh` so `mise` is on PATH.
- `../preflights/repositories.sh` — Chaotic-AUR is often where TUIs come from.

### External

- `pacman`, `yay`, `mise`, `git`, LazyVim starter (`github.com/LazyVim/starter`), doomemacs (`github.com/doomemacs/doomemacs`).

<!-- MANUAL: -->
