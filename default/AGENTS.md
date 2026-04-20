<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# default

## Purpose

Default shell rc files. `../config/config.sh` copies these into `~/.local/share/firearchwsl/default/` and forwards each to its final home: `bashrc` → `~/.bashrc`, `config.fish` → `~/.config/fish/config.fish`.

## Key Files

| File | Description |
|------|-------------|
| `bashrc` | Bash rc. Sets `EDITOR=nvim`, `BAT_THEME=ansi`, `GALLIUM_DRIVER=d3d12`, `LIBVA_DRIVER_NAME=d3d12`, minimal PS1 with window-title escape, history (`HISTSIZE=32768`, `ignoreboth`). PATH prepends `./bin:$HOME/.local/bin`. Ships functions (`transcode-video-1080p`, `transcode-video-4K`, `img2jpg`, `img2jpg-small`, `img2png` — all rely on `ffmpeg`/`magick`). Large alias block: eza (`ls`, `la`, `ll`, `l.`, `l..`, `l...`, `lt`), pacman/paru/yay shortcuts, git, mise, zellij, taskwarrior, chmod helpers, shell-switch aliases (`tobash`/`tozsh`/`tofish`/`tonu`). Init stanzas (guarded by `command -v ... &>/dev/null`) for `mise`, `starship`, `zoxide`, `atuin`, `fzf`; finishes with `eval "$(/usr/sbin/wsl2-ssh-agent)"`. Also binds `~/.local/share/omarchy/default/bash/inputrc` on interactive shells. |
| `config.fish` | Fish rc. Clears greeting, sets `TERM=xterm-256color`, `EDITOR=nvim`, `VISUAL=nvim`, `MANPAGER="nvim +Man!"`. `fish_user_key_bindings` binds vi-mode. Prepends PATH entries for `bin`, `~/bin`, `~/usr/bin`, `~/.local/bin`, `$CARGO/bin`, `$GOPATH/bin` (`$HOME/.config/go`), `$EMACS_PATH/bin` (`$HOME/.emacs.d/`). Helper funcs (`bk` for backups, `y` for yazi cwd-following). Aliases mirror `bashrc`. Init at the bottom: `starship init fish | source`, `zoxide init fish | source`, `mise activate fish | source`, `atuin init fish | source`, `eval (ssh-agent -c)`. |

## For AI Agents

### Working In This Directory

- Keep `bashrc` and `config.fish` aliased identically where both shells support it. The shell-switch aliases (`tobash`, `tozsh`, `tofish`, `tonu`) make switching shells trivial, so parity matters — adding an alias to one file but not the other is a papercut the user will hit.
- Init blocks for CLI tools MUST go at the end (after PATH and functions). Bash guards each with `command -v <tool> &>/dev/null`. Fish currently calls them unconditionally — safe only while `install/pkgs/good-tools.sh` + `tuis.sh` + `preflights/install-mise.sh` are guaranteed to have run. If you want fish-on-host-without-installer to work, add `if command -q <tool>` guards.
- Don't embed absolute paths that include a username — use `$HOME` / `~`.
- Known drift: `bashrc` line 1 binds `~/.local/share/omarchy/default/bash/inputrc` (not `firearchwsl`). If the user hasn't also installed Omarchy, every interactive bash start prints a bind error. Either replace the path with a `firearchwsl` one (and ship an `inputrc` here) or guard with `[[ -f ... ]]`.

### Testing Requirements

- After a fresh install, log in as the target user with each of bash and fish:
  - `echo $EDITOR` → `nvim`
  - `which ls` → eza alias
  - Prompt renders via starship (no fallback PS1/prompt).
  - `command -v mise && mise --version` works.

### Common Patterns

- PATH mutation uses `export PATH="./bin:$HOME/.local/bin:$PATH"` (bash) and `set -gx PATH ...` (fish).
- Aliases are grouped by intent with section headers (`## Editors ##`, `# Git`, etc.). Keep the grouping when adding.

## Dependencies

### Internal

- Copied to `~/` by `../config/config.sh`.

### External

- `nvim`, `eza`, `bat`, `starship`, `zoxide`, `atuin`, `fzf`, `mise`, `zellij`, `task`, `taskwarrior-tui`, `yazi`, `lazygit`, `lazydocker`, `wsl2-ssh-agent` — all installed by `../install/pkgs/*`. Plus `ffmpeg` and `magick` (imagemagick) for the transcoding functions.

<!-- MANUAL: -->
