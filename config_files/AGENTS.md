# config_files/

Opaque configuration payloads copied as-is by `config/config.sh` into `~/.local/share/firearchwsl/config/`. Nothing in here is sourced or evaluated during install — edits take effect only after the user's next shell-restart picks them up from wherever they're referenced.

## Files

- `starship.toml` — Starship prompt. Uses a banded format (os → user → dir → lang → docker → git → time/duration → character) with nerd-font icons. Four palettes defined (`opal`, `tokyonight`, `tokyonight-storm`, `github_dark`); active one selected by the `palette = "tokyonight"` line. `command_timeout = 200`.

## Conventions here

- New files dropped here are available at `~/.local/share/firearchwsl/config/<name>` after a fresh install. Reference them from shell rc files in `default/` (e.g., `STARSHIP_CONFIG=~/.local/share/firearchwsl/config/starship.toml`) — currently nothing does that, so Starship picks up its default path. If you change that, do it in both `default/bashrc` and `default/config.fish`.
- Keep payloads minimal and self-contained. No `#!/bin/bash` or shell substitutions — these are config blobs, not scripts.
