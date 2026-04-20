```
███████╗██╗██████╗ ███████╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗    ██╗███████╗██╗
██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║    ██║██╔════╝██║
█████╗  ██║██████╔╝█████╗  ███████║██████╔╝██║     ███████║██║ █╗ ██║███████╗██║
██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║██║███╗██║╚════██║██║
██║     ██║██║  ██║███████╗██║  ██║██║  ██║╚██████╗██║  ██║╚███╔███╔╝███████║███████╗
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝
                                                                    by Rogerio Junior
```

# firearchwsl

Bootstrap automatizado de uma distribuição **Arch Linux rodando em WSL2**. Um único `bash install.sh` sai de um Arch recém-instalado (só com `root`) para um ambiente de desenvolvimento completo: usuário não-root no `wheel`, locale `pt_BR.UTF-8`, repositórios extras (Omarchy + Chaotic-AUR), toolchain polyglot via `mise`, uma coleção curada de CLIs/TUIs modernas, LazyVim, Doom Emacs e Docker com systemd.

> Linguagem do instalador: **Português (pt_BR)**. Todos os prompts e mensagens são nessa língua.

---

## Sumário

- [O que você ganha](#o-que-você-ganha)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [O que o instalador faz (em ordem)](#o-que-o-instalador-faz-em-ordem)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Pacotes instalados](#pacotes-instalados)
- [Variáveis de ambiente / flags](#variáveis-de-ambiente--flags)
- [Idempotência e re-runs](#idempotência-e-re-runs)
- [Contribuindo / estendendo](#contribuindo--estendendo)
- [Validação e testes](#validação-e-testes)
- [Troubleshooting](#troubleshooting)
- [Créditos](#créditos)

---

## O que você ganha

- Usuário não-root no grupo `wheel` com `sudo` liberado.
- Locale `pt_BR.UTF-8` gerado e configurado (`LANG`, `LANGUAGE`).
- Git global já configurado (nome, email, `init.defaultBranch=main`, `pull.rebase=true`, aliases `co/br/ci/st`).
- Repositórios **Omarchy** e **Chaotic-AUR** ativos no `pacman.conf`.
- **mise** como gerenciador de versões polyglot (Python, Node, Bun, Rust, Go — todos em `latest`).
- **Shells**: `bash` + `fish` com `rc` prontos (PATH, aliases, histórico, inits de `starship`/`zoxide`/`atuin`/`mise`/`fzf`).
- **Prompt**: `starship` com preset nerd-font e paleta `tokyonight`.
- **Editores**: **LazyVim** (em `~/.config/nvim`) e **Doom Emacs** (em `~/.emacs.d`) clonados e instalados.
- **TUIs**: `lazygit`, `lazydocker`, `yazi` (com preview stack completo), `zellij`, `taskwarrior-tui`, `tabiew`, `television`, `navi`, `superfile`, `atuin`, `fzf`.
- **CLIs modernas**: `eza`, `bat`, `fd`, `ripgrep`, `jq`, `yq`, `dust`, `zoxide`, `glow`, `tldr`, `fastfetch`, `7zip`…
- **Docker** + `docker-buildx` + `docker-compose`, `daemon.json` customizado (log cap 10MB/5 files, bridge `172.17.0.1/16`), `systemd-resolved` drop-in, serviço habilitado.
- Banner final animado pelo `tte` (terminaltexteffects) ao concluir.

---

## Pré-requisitos

- Windows 10/11 com **WSL2** habilitado.
- Uma distro **Arch Linux WSL** recém-criada (use a imagem oficial do Arch no WSL ou equivalente).
- Conexão com internet.
- Acesso como **`root`** para o primeiro run (o instalador é quem cria o usuário não-root).

> Não é recomendado rodar em cima de um Arch WSL já customizado — o script assume estado inicial limpo e sobrescreve `/etc/pacman.conf`, `/etc/pacman.d/mirrorlist`, `/etc/locale.conf`, `/etc/docker/daemon.json`, entre outros.

---

## Instalação

Do terminal do Arch WSL, como `root`:

```bash
# 1. Clone o repo
git clone https://github.com/<seu-user>/firearchwsl.git
cd firearchwsl

# 2. Rode o bootstrap
bash install.sh
```

Durante o run, o instalador irá pedir, nessa ordem:

1. **Username** do novo usuário não-root (vai pro grupo `wheel` com `sudo`).
2. **Senha** desse usuário (prompt do `passwd`).
3. **Nome** e **email** para o `git config --global`.

Depois disso é "sit back and relax" — a instalação demora (principalmente o Doom Emacs, que recompila pacotes: 5–15 min).

Ao terminar, o instalador mostra um banner animado e pede para você rodar no PowerShell:

```powershell
wsl --terminate archlinux
```

Isso derruba a distro para que os novos grupos (`wheel`, `docker`) e o locale entrem em vigor. Abra o WSL de novo e você já loga como o usuário criado.

---

## O que o instalador faz (em ordem)

O `install.sh` é um **orquestrador** que usa `source` para rodar cada script no contexto correto. A ordem é load-bearing:

| Fase | Script | Responsabilidade |
|------|--------|------------------|
| 0 | `pacman -Syu` inicial | Atualiza a base antes de qualquer coisa |
| 1 | `install/preflights/trap-errors.sh` | Instala `ERR trap` com mensagem útil |
| 2 | `system/create_your_user.sh` | Cria usuário, adiciona ao `wheel`, libera `sudo`, grava `/etc/firearchwsl/target_user` |
| 3 | `install/preflights/lib.sh` + `ensure_target_user` | Exporta `TARGET_USER` / `TARGET_HOME` e define `as_user` para tudo que vem depois |
| 4 | `system/configure_locale.sh` | Gera `pt_BR.UTF-8` + `en_US.UTF-8`, escreve `/etc/locale.conf` |
| 5 | `system/wsl_config.sh` | Symlink de `libedit` (shim WSL) |
| 6 | `install/preflights/essentials_pkgs.sh` | `sudo base-devel git fish btop curl wget just make eza bat openssh vim` |
| 7 | `system/configure_git_user.sh` | `git config --global` user/email + aliases |
| 8 | `install/preflights/repositories.sh` | Ativa Color/ILoveCandy, adiciona Omarchy + Chaotic-AUR, força mirrorlist |
| 9 | `install/preflights/install-mise.sh` | Instala `mise` e ativa no rc |
| 10 | `install/pkgs/good-tools.sh` | ~40 pacotes pacman (CLIs, fonts nerd, `yay`/`paru`, `tte`) |
| 11 | `install/pkgs/tuis.sh` | TUIs + stack de preview do yazi |
| 12 | `install/pkgs/install_langs.sh` | `mise use -g python@latest node@latest bun@latest rust@latest go@latest` |
| 13 | `install/pkgs/editors.sh` | Clona LazyVim starter e Doom Emacs |
| 14 | `config/config.sh` | Copia `config_files/*` e `default/*` pro home do `TARGET_USER`, `chown -R` |
| 15 | `config/docker.sh` | Escreve `/etc/docker/daemon.json`, drop-in do `systemd-resolved`, habilita `docker` |
| ∎ | `tte` | Renderiza `logo.txt` + instrução final |

> **Importante:** cada subscript assume o contexto do orquestrador. Eles *não* são standalone — scripts user-scoped fazem `: "${TARGET_USER:?…}"` para explodir cedo se invocados fora.

---

## Estrutura do repositório

```
firearchwsl/
├── install.sh                 # Orquestrador — sempre o ponto de entrada
├── logo.txt                   # ASCII banner renderizado pelo tte no final
├── AGENTS.md                  # Documentação hierárquica para AI/agents (raiz)
│
├── install/
│   ├── preflights/            # Trap de erros, essentials, repos, mise, lib.sh
│   └── pkgs/                  # good-tools, tuis, install_langs, editors
│
├── system/                    # Scripts que tocam /etc ou criam user/groups
│   ├── create_your_user.sh    # Cria usuário, libera wheel/sudo
│   ├── configure_locale.sh    # pt_BR.UTF-8 + en_US.UTF-8
│   ├── configure_git_user.sh  # git config --global
│   └── wsl_config.sh          # libedit shim
│
├── config/                    # Pós-install: copia payloads + Docker
│   ├── config.sh              # Copia config_files/ e default/ pro home
│   └── docker.sh              # daemon.json + systemd-resolved + enable
│
├── config_files/              # Payloads opacos (copiados verbatim)
│   └── starship.toml
│
└── default/                   # RCs default de shell
    ├── bashrc                 # → ~/.bashrc
    ├── config.fish            # → ~/.config/fish/config.fish
    └── inputrc                # readline
```

Cada subdiretório tem seu próprio `AGENTS.md` com detalhes de contrato, ordem, testes e padrões.

---

## Pacotes instalados

### Pacman — essentials (`essentials_pkgs.sh`)
`sudo` · `base-devel` · `git` · `fish` · `btop` · `curl` · `wget` · `just` · `make` · `eza` · `bat` · `openssh` · `vim`

### Pacman — good-tools (`good-tools.sh`)
`jq` · `yq` · `stow` · `fx` · `fd` · `ripgrep` · `7zip` · `zip` · `unzip` · `task` · `zellij` · `neovim` · `glow` · `harper` · `figlet` · `asciinema` · `docker` · `docker-buildx` · `docker-compose` · `dust` · `less` · `man` · `starship` · `tldr` · `tree-sitter-cli` · `zoxide` · `cargo` · `python-poetry-core` · `python-terminaltexteffects` · `bash-completion` · `yay` · `paru` · `luarocks` · `ttf-cascadia-mono-nerd` · `ttf-jetbrains-mono` · `ttf-hack-nerd` · `fastfetch` · `emacs`

### Pacman — TUIs (`tuis.sh`)
`taskwarrior-tui` · `tabiew` · `lazygit` · `television` · `navi` · `yazi` · `imagemagick` · `poppler` · `fzf` · `atuin` · `rsync` · `chafa` · `resvg` · `ffmpegthumbnailer` · `libcaca` · `lynx` · `mediainfo` · `odt2txt` · `perl-image-exiftool` · `python-pillow` · `python-chardet` · `ueberzug` · `w3m` · `lazydocker` · `superfile`

### mise — toolchains (`install_langs.sh`)
`python@latest` · `node@latest` · `bun@latest` · `rust@latest` · `go@latest`

### Editores (`editors.sh`)
- **LazyVim** starter → `~/.config/nvim`
- **Doom Emacs** → `~/.emacs.d` (roda `doom install --no-fonts --no-hooks --yes`)

---

## Variáveis de ambiente / flags

Podem ser exportadas **antes** de rodar `bash install.sh`:

| Variável | Efeito |
|----------|--------|
| `DISABLE_CHAOTIC=1` | Pula instalação do Chaotic-AUR (útil em ARM ou redes restritas) |
| `FORCE_CONFIG=1` | Força `config/config.sh` a sobrescrever `~/.bashrc` e `~/.config/fish/config.fish`. Default é preservar (`cp -n`) |

Variáveis **exportadas pelo próprio instalador** (úteis ao adicionar novos scripts):

| Variável | Origem | Conteúdo |
|----------|--------|----------|
| `FIREARCH_ROOT` | `install.sh` | Caminho absoluto da raiz do repo |
| `FIREARCH_INSTALL` | `install.sh` | `$FIREARCH_ROOT/install` |
| `FIREARCH_SYSTEM` | `install.sh` | `$FIREARCH_ROOT/system` |
| `FIREARCH_CONFIG` | `install.sh` | `$FIREARCH_ROOT/config` |
| `TARGET_USER` | `lib.sh::ensure_target_user` | Usuário não-root alvo |
| `TARGET_HOME` | `lib.sh::ensure_target_user` | `$HOME` do `TARGET_USER` |

---

## Idempotência e re-runs

O instalador foi desenhado para ser **re-executável**:

- `pacman -S --needed --noconfirm` evita reinstalação.
- `create_your_user.sh` pula o prompt se `/etc/firearchwsl/target_user` já existe.
- Edits em `/etc/pacman.conf` são guardados com `grep -q` antes de escrever.
- `editors.sh` só clona se os diretórios ainda não existem.
- `config/config.sh` **preserva** `~/.bashrc` e `config.fish` existentes por default (`cp -n`). Use `FORCE_CONFIG=1` para sobrescrever.
- Ativação do `mise` no rc usa `grep -Fq` antes de append.

**Atenção:** não há rollback automático. Falha no meio do pipeline deixa o sistema em estado parcial — re-rode após corrigir.

---

## Contribuindo / estendendo

### Adicionar um novo grupo de pacotes

1. Crie `install/pkgs/<nome>.sh` modelado em `good-tools.sh` (shebang, `set -Eeuo pipefail`, `PACMAN_PKGS=()`, `msg`/`warn`/`die`, `ensure_sudo`, `main`, `main "$@"`).
2. Adicione `source "$FIREARCH_INSTALL/pkgs/<nome>.sh"` no `install.sh` no slot de fase correto.
3. Mantenha o array **estreito** (um intent por arquivo). Não funda grupos.

### Adicionar um comando user-scoped

Use sempre o helper `as_user` de `install/preflights/lib.sh`:

```bash
as_user mise use -g rust@latest
as_user git clone … "$TARGET_HOME/.config/foo"
```

Nunca use `$HOME` ou `$USER` diretamente — o script roda como root, então esses apontam pra `/root`.

### Adicionar um payload opaco

Drop em `config_files/`. Ele será copiado para `~/.local/share/firearchwsl/config/<arquivo>`. Para torná-lo ativo, aponte uma env var (`STARSHIP_CONFIG=…` etc.) em `default/bashrc` **e** `default/config.fish` — mantenha paridade entre os dois shells.

### Convenções de estilo

- `#!/bin/bash` em todo script. Novos scripts começam com `set -Eeuo pipefail`; `install.sh` usa `set -eE` (para o trap `ERR`).
- Strings user-facing em **pt_BR**.
- Log helpers `msg` / `warn` / `die` vivem em `install/preflights/lib.sh` — prefira-os ao escrever scripts novos.
- Scripts root-required guardam com `if [[ $EUID -ne 0 ]]; then ... return 1 2>/dev/null || exit 1; fi` (porque são `source`d).

---

## Validação e testes

Não há CI nem suíte de testes. Validação é manual:

```bash
# Lint estático
bash -n install.sh
find . -name '*.sh' -exec bash -n {} \;
shellcheck -x install.sh      # se disponível

# Validar fish rc
fish -n default/config.fish

# Smoke test do helper as_user (fora do install.sh)
source install/preflights/lib.sh
TARGET_USER=$(whoami) TARGET_HOME=$HOME as_user whoami
# → deve imprimir seu usuário
```

**Teste de fumaça completo:** `wsl --unregister archlinux && wsl --install -d archlinux`, clone o repo e rode `bash install.sh` duas vezes. Segundo run não deve abortar.

Teste em container (parcial — pula `docker.sh` onde não há systemd):

```bash
docker run --rm -it archlinux bash
```

---

## Troubleshooting

| Sintoma | Causa provável | Resolução |
|---------|----------------|-----------|
| `Failed to install Chaotic-AUR` | Rede bloqueia `cdn-mirror.chaotic.cx` ou arch não é `x86_64` | Re-rodar com `DISABLE_CHAOTIC=1 bash install.sh` |
| `bind: ~/.local/share/omarchy/default/bash/inputrc: No such file` ao abrir bash | `bashrc` ainda referencia Omarchy. Drift conhecido | Instalar Omarchy *ou* editar `default/bashrc` linha 1 |
| `docker` não roda sem `sudo` para o usuário | `docker.sh` adiciona `${USER}` (root) ao grupo | Após install: `sudo usermod -aG docker <seu-user>` + `wsl --terminate archlinux` |
| `locale -a` não mostra `pt_BR.utf8` | `locale-gen` falhou silenciosamente | `sudo locale-gen` manualmente, verificar `/etc/locale.gen` |
| Doom Emacs trava / reclama | Download interrompido | `DOOMLOCALDIR=~/.emacs.d/.local ~/.emacs.d/bin/doom doctor` |
| Re-run sobrescreveu meu `.bashrc` customizado | Usou `FORCE_CONFIG=1` | Default é preservar — não passe essa flag |

---

## Créditos

- **Autor:** Rogerio Junior
- **Inspirações:** [Omarchy](https://pkgs.omarchy.org/), [Chaotic-AUR](https://aur.chaotic.cx/), [LazyVim](https://www.lazyvim.org/), [Doom Emacs](https://github.com/doomemacs/doomemacs), [mise](https://mise.jdx.dev/), [starship](https://starship.rs/), [yazi](https://yazi-rs.github.io/).
- **Banner final:** [terminaltexteffects](https://github.com/ChrisBuilds/terminaltexteffects) (`tte`).

---

> Dúvidas sobre arquitetura interna? Leia os `AGENTS.md` hierárquicos em cada diretório — eles documentam contratos, ordem de execução, testes e armadilhas conhecidas.
