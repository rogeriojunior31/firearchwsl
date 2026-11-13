<!-- Parent: ../AGENTS.md -->

# install

## Purpose

Everything `install.sh` sources: the shared library and UI, the language catalogs, the preflight steps and the package groups.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `i18n/` | Language catalogs: `en.sh` (reference) and `pt_BR.sh`. One file per language. |
| `preflights/` | Library (`lib.sh`, `i18n.sh`, `ui.sh`), error trap, wizard, finale, and the base-system steps (see `preflights/AGENTS.md`) |
| `pkgs/` | CLI tools, TUIs, language toolchains, editors (see `pkgs/AGENTS.md`) |

## For AI Agents

### i18n catalogs (`i18n/`)

- Each file fills the global associative array `MSG` (`MSG[group.key]="printf format"`) and sets `I18N_LOCALE`, `I18N_LANGUAGE`, `I18N_YES_REGEX`, `I18N_YES_NO_HINT`.
- The `# name:` header line is the label shown in the language picker.
- `en.sh` must contain every key. Other catalogs are loaded on top of it, so a missing key falls back to English.
- Values are printf formats: keep `%s`/`%d` count and order identical across languages; write a literal percent as `%%`.
- Adding a language = adding one file. No code changes.
- Key coverage check: every `t <key>` used in the scripts must exist in `en.sh`, and `en.sh`/`pt_BR.sh` should define the same key set.

### Working In This Directory

- Ordering contract (enforced by the `STEPS` array in `install.sh`): preflights before pkgs. Within `pkgs/`: `good-tools.sh` → `tuis.sh` → `install_langs.sh` → `editors.sh`.
- Every script here is sourced, so `exit` kills the whole installer. Use `return` to leave a step early.

### Adding a new package group

1. Create `pkgs/<name>.sh`: a `PACMAN_PKGS=()` array plus `pac_install "$(t <name>.install)" "${PACMAN_PKGS[@]}"`.
2. Add `<name>.install` and `step.<name>` to every catalog in `i18n/`.
3. Add `"step.<name>|$FIREARCH_INSTALL/pkgs/<name>.sh"` to `STEPS` in `install.sh` and bump `UI_STEP_TOTAL`.

## Dependencies

- `../install.sh` — orchestrator.
- `pacman`, `gum`, `mise`.
