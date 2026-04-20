# install/preflights/

Steps that prepare the system before any opinionated packages land. All are sourced by `install.sh` while running as root.

## Files

- `trap-errors.sh` — defines `catch_errors` and wires it to the `ERR` trap. Prints the failing command and suggests `bash ./install.sh`. Source this first; every later script benefits from it.
- `essentials_pkgs.sh` — tiny `PACMAN_PKGS=()` of hard prerequisites (`sudo`, `base-devel`, `git`, `fish`, `btop`, `curl`, `wget`, `just`, `make`, `eza`, `bat`, `openssh`, `vim`). Gate further scripts on this running successfully.
- `repositories.sh` — edits `/etc/pacman.conf`:
  - Enables `Color`, `ILoveCandy`, `VerbosePkgLists`.
  - Adds the Omarchy repo (`https://pkgs.omarchy.org/`) with `SigLevel = Optional TrustAll`.
  - Overwrites `/etc/pacman.d/mirrorlist` with two global mirrors (`geo.mirror.pkgbuild.com`, `mirror.rackspace.com`).
  - On `x86_64`, adds Chaotic-AUR (key `3056513887B78AEB`, keyring + mirrorlist packages). Skippable via `DISABLE_CHAOTIC=1`.
  - Finishes with `pacman -Syu --noconfirm`.
- `install-mise.sh` — `pacman -S mise`, then appends the right `mise activate` line to the invoker's shell rc (`.bashrc`, `.zshrc`, or `~/.config/fish/config.fish`). Uses `$SHELL` to pick; falls back to bash. Idempotent via `grep -Fq`.

## Conventions here

- These scripts assume root (sourced from `install.sh`, which runs as root). They call `sudo` anyway so they can also be run standalone.
- Any edit to `/etc/pacman.conf` MUST be guarded with `grep -q` — the file is rewritten in place on every run.
- The Chaotic-AUR opt-out env var (`DISABLE_CHAOTIC`) is the pattern for conditional sections; reuse it for similar toggles.
