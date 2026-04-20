<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# preflights

## Purpose

Steps that prepare the system before any opinionated packages land. Sourced by `install.sh` while running as root, in the order listed in Key Files.

## Key Files

| File | Description |
|------|-------------|
| `trap-errors.sh` | Defines `catch_errors` and wires it to the `ERR` trap. Prints the failing command and suggests `bash ./install.sh`. Source first — every later script benefits. |
| `essentials_pkgs.sh` | Minimal `PACMAN_PKGS=()`: `sudo`, `base-devel`, `git`, `fish`, `btop`, `curl`, `wget`, `just`, `make`, `eza`, `bat`, `openssh`, `vim`. Gate further scripts on this succeeding. |
| `repositories.sh` | Edits `/etc/pacman.conf`: enables `Color`, `ILoveCandy`, `VerbosePkgLists`; adds Omarchy repo (`SigLevel = Optional TrustAll`); overwrites `/etc/pacman.d/mirrorlist` with two global mirrors; on `x86_64` installs Chaotic-AUR (key `3056513887B78AEB`, keyring + mirrorlist pkgs — skippable via `DISABLE_CHAOTIC`). Ends with `pacman -Syu`. |
| `install-mise.sh` | `pacman -S mise`, then appends the right `mise activate` line to the invoker's shell rc (bash/zsh/fish detected from `$SHELL`; fallback bash). Idempotent via `grep -Fq`. |

## For AI Agents

### Working In This Directory

- Scripts assume root (sourced from `install.sh`, which runs as root). They still call `sudo` so they can also be run standalone.
- Any edit to `/etc/pacman.conf` MUST be guarded with `grep -q` — the file is rewritten in place on every run.
- Use the `DISABLE_CHAOTIC` env-var pattern for conditional sections; reuse it for similar toggles.

### Testing Requirements

- Rerun on an already-configured distro: `/etc/pacman.conf` should remain unchanged, mise activation line should not duplicate in the rc file.

### Common Patterns

- `set -euo pipefail` + ANSI `msg`/`err` helpers.
- `command -v sudo >/dev/null 2>&1` guards before calling sudo-dependent commands.

## Dependencies

### Internal

- Sourced by `../../install.sh` in the preparation phase.

### External

- `pacman`, `sudo`, `pacman-key`, `mise`.

<!-- MANUAL: -->
