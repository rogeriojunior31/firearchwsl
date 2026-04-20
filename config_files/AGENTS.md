<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# config_files

## Purpose

Opaque configuration payloads copied as-is by `../config/config.sh` into `~/.local/share/firearchwsl/config/`. Nothing here is sourced or evaluated during install; edits take effect on the user's next shell start (once something references them).

## Key Files

| File | Description |
|------|-------------|
| `starship.toml` | Starship prompt. Banded format (os → user → dir → lang → docker → git → time/duration → character) with nerd-font icons. Four palettes (`opal`, `tokyonight`, `tokyonight-storm`, `github_dark`) defined; active one selected by `palette = "tokyonight"`. `command_timeout = 200`. |

## For AI Agents

### Working In This Directory

- Anything dropped here is available at `~/.local/share/firearchwsl/config/<name>` after a fresh install. To actually consume it, add an env var / path in both `../default/bashrc` and `../default/config.fish` (e.g. `export STARSHIP_CONFIG=~/.local/share/firearchwsl/config/starship.toml`). Currently nothing does that, so Starship uses its default path and this file is dormant.
- Keep payloads minimal and self-contained. No `#!/bin/bash`, no shell substitutions — these are config blobs, not scripts.

### Testing Requirements

- After a fresh install, on the target user: `diff ~/.local/share/firearchwsl/config/starship.toml <repo>/config_files/starship.toml` should be empty.

### Common Patterns

- Use nerd-font icon glyphs directly (file is UTF-8).

## Dependencies

### Internal

- Copied by `../config/config.sh`.

### External

- `starship` — installed by `../install/pkgs/good-tools.sh`.

<!-- MANUAL: -->
