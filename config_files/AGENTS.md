<!-- Parent: ../AGENTS.md -->

# config_files

## Purpose

Opaque configuration payloads copied as-is by `../config/config.sh` into `~/.local/share/firearchwsl/config/`. Nothing here is sourced or evaluated during install.

## Key Files

| File | Description |
|------|-------------|
| `starship.toml` | Starship prompt. Banded format (os → user → dir → lang → docker → git → time/duration → character) with nerd-font icons. Four palettes (`opal`, `tokyonight`, `tokyonight-storm`, `github_dark`); the active one is `palette = "tokyonight"`. `command_timeout = 200`. Active through the `~/.config/starship.toml` symlink created by `config.sh`. |

## For AI Agents

### Working In This Directory

- Anything dropped here lands at `~/.local/share/firearchwsl/config/<name>` and is overwritten on every run. To make a new payload take effect, symlink it from its canonical path in `../config/config.sh` (as done for starship) or point an env var at it in both `../default/bashrc` and `../default/config.fish`.
- Payloads are config blobs, not scripts: no shebang, no shell substitutions.
- Files are UTF-8 with nerd-font glyphs; keep LF line endings.

### Testing Requirements

- After an install, as the target user: `cmp ~/.local/share/firearchwsl/config/starship.toml <repo>/config_files/starship.toml` is silent, and `readlink ~/.config/starship.toml` points at the share copy.

## Dependencies

- Copied by `../config/config.sh`. `starship` is installed by `../install/pkgs/good-tools.sh`.
