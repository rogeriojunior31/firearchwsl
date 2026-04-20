# install/pkgs/

Package groups installed after the preflight phase. Each script owns its own `PACMAN_PKGS=()` array (kept narrow on purpose — swap one group without disturbing others).

## Files

- `good-tools.sh` — general-purpose CLI: `jq`, `yq`, `stow`, `fd`, `ripgrep`, `task`, `zellij`, `neovim`, `glow`, `docker` + `docker-buildx` + `docker-compose`, `starship`, `zoxide`, `cargo`, `python-poetry-core`, `python-terminaltexteffects` (for the finale animation), `yay`, `paru`, nerd fonts, `emacs`, etc. `main()` runs `pacman -Syu` then installs with `--needed --noconfirm`.
- `tuis.sh` — terminal UIs: `taskwarrior-tui`, `lazygit`, `television`, `navi`, `yazi` (+ preview deps: `imagemagick`, `poppler`, `ueberzug`, `chafa`, `ffmpegthumbnailer`, `mediainfo`, `odt2txt`, `perl-image-exiftool`, `w3m`), `fzf`, `atuin`, `lazydocker`, `superfile`. Also runs `yay -Syu`.
  - Note: `need_cmd` here is buggy (split across two lines — the `&` backgrounds the command, redirects go nowhere). Not currently used by `main()`, so the bug is latent. Fix if you start using it.
- `install_langs.sh` — language toolchains via mise (`mise use -g python@latest`, `node@latest`, `bun@latest`, `rust@latest`, `go@latest`). Runs after `install-mise.sh` has activated mise in the shell.
- `editors.sh` — editors that are cloned, not pacman-installed:
  - LazyVim starter into `~/.config/nvim`, strips `.git`, appends `vim.opt.relativenumber = false`.
  - Doom Emacs into `~/.emacs.d`, runs `doom install`.
  - Each clone is guarded on `[[ ! -d ... ]]`, so reruns skip.

## Conventions here

- Package group files are structured identically: shebang, `set -Eeuo pipefail`, `PACMAN_PKGS=()` array, `msg/warn/die` helpers, `ensure_sudo`, `main()`, `main "$@"`.
- Always pass `--needed --noconfirm` to `pacman -S`.
- Don't rely on user-mode tools inside these scripts — `install.sh` runs as root and the target non-root user only gets touched later in `config/config.sh`.
- When adding a TUI, remember its preview/helper deps belong in the same array as the TUI itself (see yazi's cluster in `tuis.sh`).
