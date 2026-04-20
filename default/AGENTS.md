# default/

Default shell rc files. `config/config.sh` copies these into `~/.local/share/firearchwsl/default/` and then forwards the active shell's rc file into place (`~/.bashrc` and `~/.config/fish/config.fish`).

## Files

- `bashrc` — bash rc for the new user. Sets `EDITOR=nvim`, a minimal PS1, history (`HISTSIZE=32768`, `ignoreboth`), PATH additions (`./bin:$HOME/.local/bin`), shell functions (`transcode-video-1080p`, `transcode-video-4K`, `img2jpg*`, `img2png` — all rely on `ffmpeg`/`magick`), a large alias block (eza ls aliases, pacman/paru/yay shortcuts, git, mise, zellij, taskwarrior, chmod, shell-switch helpers), and init stanzas for `mise`, `starship`, `zoxide`, `atuin`, `fzf`, and `wsl2-ssh-agent`.
  - Sources `~/.local/share/omarchy/default/bash/inputrc` if the shell is interactive — note that path, not `firearchwsl`, is what it expects. If you don't also install Omarchy you'll see a bind error on every interactive bash start. Keep or replace, but don't silently drop.
- `config.fish` — fish equivalent. Clears greeting, sets `TERM=xterm-256color`, `EDITOR=nvim`, `MANPAGER="nvim +Man!"`. Binds vi-mode via `fish_user_key_bindings`. Prepends PATH entries for `bin`, `~/bin`, `~/usr/bin`, `~/.local/bin`, `$CARGO/bin`, `$GOPATH/bin`, `$EMACS/bin`. Mirrors most aliases from bashrc. Ends by `source`-ing `starship`, `zoxide`, `mise`, and `atuin` init output, and starting `ssh-agent`.

## Conventions here

- Keep bashrc and config.fish aliased identically where both shells support it. When adding a new alias, add it to both files so the user doesn't lose it by switching shells (the `tobash`/`tozsh`/`tofish`/`tonu` aliases make switching trivial).
- Init blocks for CLI tools (`mise`, `starship`, `zoxide`, `atuin`) MUST go at the end, after PATH and functions, and should be guarded (`command -v <tool> &>/dev/null` in bash). Fish currently calls them unconditionally — safe only if the packaging phase installed them.
- Don't embed absolute paths that include a username. Use `$HOME` / `~`.
