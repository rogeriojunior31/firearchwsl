<!-- Parent: ../AGENTS.md -->

# default

## Purpose

Default shell rc files. `../config/config.sh` copies them into `~/.local/share/firearchwsl/default/` and installs `bashrc` → `~/.bashrc` and `config.fish` → `~/.config/fish/config.fish` (local edits are preserved unless `FORCE_CONFIG=1`).

## Key Files

| File | Description |
|------|-------------|
| `bashrc` | Bash rc. Binds `inputrc` from the share dir on interactive shells. Sets `EDITOR=nvim`, `BAT_THEME=ansi`, d3d12 GPU driver vars, history (`HISTSIZE=32768`, `ignoreboth`), PATH (`./bin:$HOME/.local/bin`). Media helper functions (`transcode-video-*`, `img2jpg*`, `img2png`). Alias blocks: eza, pacman/paru/yay, git, mise, zellij, taskwarrior, chmod, shell switching (`tobash`/`tofish`/…). Guarded inits for `mise`, `starship`, `zoxide`, `atuin`, `fzf`, and `wsl2-ssh-agent` when present. |
| `config.fish` | Fish rc. Vi key bindings, `EDITOR`/`VISUAL=nvim`, `MANPAGER="nvim +Man!"`, PATH entries (`~/.local/bin`, cargo, go, Doom `bin`). Functions `bk` (backup) and `y` (yazi with cwd follow). Aliases mirror `bashrc`. Guarded inits for `starship`, `zoxide`, `mise`, `atuin`, `ssh-agent`. |
| `inputrc` | Readline defaults for bash: case-insensitive completion, show-all-if-ambiguous, colored stats. |

## For AI Agents

### Working In This Directory

- Keep `bashrc` and `config.fish` aliases in parity — users switch shells with `tobash`/`tofish`.
- Tool init blocks go at the end and must be guarded by `command -v <tool>`: optional components (mise toolchains, Doom, Docker) may not be installed.
- No absolute paths containing a username — use `$HOME` / `~`.
- Comments in English. These files are not translated: they contain no installer output.
- LF line endings only (`fish -n` and bash both choke on CRLF).

### Testing Requirements

- `bash -n default/bashrc` and `fish -n default/config.fish`.
- After an install, as the target user in bash and in fish: prompt renders through starship, `ls` is the eza alias, `mise --version` works, no errors on shell start.

## Dependencies

- Installed by `../config/config.sh`.
- `nvim`, `eza`, `bat`, `starship`, `zoxide`, `atuin`, `fzf`, `mise`, `zellij`, `task`, `yazi` — from `../install/pkgs/*`; `ffmpeg`/`magick` for the media functions.
