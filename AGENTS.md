<!-- Generated: 2026-04-20 | Updated: 2026-04-20 (idempotency + user-scope refactor) -->

# firearchwsl

## Purpose

Automated bootstrap for an Arch Linux WSL2 environment. Runs as root on a fresh Arch WSL distro, creates a non-root user, configures locale/git/mise, installs a curated pacman + AUR + mise toolchain, and lays down shell (bash, fish) and terminal (starship, zellij, yazi, lazygit, etc.) configs. User-facing output is in Portuguese (pt_BR). Author: Rogerio Junior.

## Key Files

| File | Description |
|------|-------------|
| `install.sh` | Top-level orchestrator. `set -eE`, sources every preflight / pkg / config script in fixed order. Finishes with a `tte` animation of `logo.txt` and prompts the user to `wsl --terminate archlinux`. |
| `logo.txt` | ASCII banner ("FIREARCHWSL") rendered by `tte` (python-terminaltexteffects) on install completion. |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `install/` | Preflight steps and package groups (see `install/AGENTS.md`) |
| `system/` | System-level config: user, locale, git, WSL shims (see `system/AGENTS.md`) |
| `config/` | Post-install config copiers + Docker daemon wiring (see `config/AGENTS.md`) |
| `config_files/` | Verbatim config payloads (starship.toml) (see `config_files/AGENTS.md`) |
| `default/` | Default bash / fish rc files (see `default/AGENTS.md`) |

## For AI Agents

### Working In This Directory

- **Entry-point is always `install.sh`.** Subscripts assume orchestrator context — they are not standalone-executable. Scripts user-scoped guardam `: "${TARGET_USER:?…}"` para falhar cedo se invocados fora.
- `install.sh` exporta `FIREARCH_ROOT` (raiz absoluta do repo) — subscripts que referenciam payloads usam `$FIREARCH_ROOT/...`, não `../`.
- Após `create_your_user.sh`, `install.sh` sourcia `install/preflights/lib.sh` e chama `ensure_target_user`. Isso exporta `TARGET_USER` e `TARGET_HOME` para todo o restante do pipeline.
- **Fonte única de `TARGET_USER`**: escrita em `/etc/firearchwsl/target_user` por `create_your_user.sh`; lida por `lib.sh::resolve_target_user`. Fallback: primeiro membro do grupo wheel.
- **Comandos user-scoped usam `as_user <cmd>`** (de `lib.sh`): `sudo -Hu "$TARGET_USER" env HOME="$TARGET_HOME" PATH=… -- <cmd>`. Sem prompt de senha porque root é sempre o caller.
- **Re-run sobrescreve config?** `config/config.sh` preserva edits locais em `~/.bashrc` e `~/.config/fish/config.fish` por default (`cp -n`). Use `FORCE_CONFIG=1 bash install.sh` para forçar sobrescrita.
- **Atomicidade**: falha no meio deixa sistema em estado parcial. `create_your_user.sh`, `repositories.sh`, pacman `--needed` etc. são idempotentes — re-run é seguro, mas não há rollback automático.
- Script order in `install.sh` is load-bearing. Summary: `pacman -Syu` → trap → user → **lib** → locale → wsl → essentials → git-user → repositories → mise → good-tools → tuis → langs → editors → config → docker. Do not reshuffle without understanding each dependency.
- User-facing strings (`echo`, `printf`, `read -rp`) are Portuguese. Preserve that tone.
- Scripts são `#!/bin/bash`. Novos scripts começam com `set -Eeuo pipefail`; `install.sh` usa `set -eE` para o `ERR` trap disparar.
- Log helpers `msg`/`warn`/`die` vivem em `install/preflights/lib.sh`. Alguns scripts legacy ainda têm duplicação local — OK para os self-contained, consolidar ao editar.

### Testing Requirements

- No tests, no CI, no lint config. Validation é: Arch WSL fresh + `bash install.sh` + segundo run não aborta.
- Antes de commitar: `bash -n` em cada `.sh` alterado; `shellcheck -x` se disponível.
- `fish -n default/config.fish` valida fish config.
- Teste unit do helper: `source install/preflights/lib.sh && TARGET_USER=$(whoami) TARGET_HOME=$HOME as_user whoami` deve imprimir seu user.
- Container Arch (`docker run --rm -it archlinux bash`) roda até `docker.sh` — guard `[[ -d /run/systemd/system ]]` pula systemd quando ausente.

### Common Patterns

- `PACMAN_PKGS=()` arrays grouped by intent (one per pkg file). Do not consolidate across groups.
- `pacman -Syu --noconfirm` só em 2 pontos: `install.sh` inicial + `repositories.sh` pós-keyring. Demais scripts só instalam via `-S --needed --noconfirm`.
- Idempotency checks antes de mutar `/etc` (ex: `grep -q "chaotic-aur" /etc/pacman.conf`, `visudo -c` pós-edit, `id -nG … | grep -qx docker` pré-`usermod`).
- Root-required scripts guard com `if [[ $EUID -ne 0 ]]` e `return 1 2>/dev/null || exit 1` (porque são sourced — `exit` mataria o orquestrador).
- Interactive `read -rp` para valores humanos (username, git name/email). `create_your_user.sh` pula o prompt se `/etc/firearchwsl/target_user` existe.
- Comandos user-scoped via `as_user`; nunca `$HOME`/`$USER` diretos (são do root).

## Dependencies

### External

- `pacman` — base Arch package manager.
- Omarchy repo (`https://pkgs.omarchy.org/`) and Chaotic-AUR — extra package sources added by `install/preflights/repositories.sh`.
- `mise` — polyglot language version manager (python, node, bun, rust, go).
- `tte` (python-terminaltexteffects) — renders the finale banner.
- LazyVim starter and doomemacs — cloned by `install/pkgs/editors.sh`.

<!-- MANUAL: Any manually added notes below this line are preserved on regeneration -->
