```
███████╗██╗██████╗ ███████╗ █████╗ ██████╗  ██████╗██╗  ██╗██╗    ██╗███████╗██╗
██╔════╝██║██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║██║    ██║██╔════╝██║
█████╗  ██║██████╔╝█████╗  ███████║██████╔╝██║     ███████║██║ █╗ ██║███████╗██║
██╔══╝  ██║██╔══██╗██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║██║███╗██║╚════██║██║
██║     ██║██║  ██║███████╗██║  ██║██║  ██║╚██████╗██║  ██║╚███╔███╔╝███████║███████╗
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝
                                                                    by Rogerio Junior
```

# firearchwsl 🔥

Bootstrap de um **Arch Linux no WSL2**: um único `bash install.sh` leva um Arch recém-instalado (só com `root`) a um ambiente de desenvolvimento completo.

Você responde algumas perguntas no começo, confirma o resumo e vai tomar um café. O instalador roda sozinho até o fim, mostrando cada etapa com spinner e tempo, e guarda a saída completa num arquivo de log.

> O instalador é **multilíngue** (Português e English hoje). O código e os comentários são em inglês; todo texto de tela vem de catálogos em `install/i18n/`.

---

## Sumário

- [Como fica na tela](#como-fica-na-tela)
- [O que você ganha](#o-que-você-ganha)
- [Pré-requisitos](#pré-requisitos)
- [Instalação](#instalação)
- [Modo não-interativo](#modo-não-interativo)
- [Opções e variáveis](#opções-e-variáveis)
- [Etapas do instalador](#etapas-do-instalador)
- [Idiomas (i18n)](#idiomas-i18n)
- [Estrutura do repositório](#estrutura-do-repositório)
- [Pacotes instalados](#pacotes-instalados)
- [Re-execução](#re-execução)
- [Estendendo](#estendendo)
- [Validação](#validação)
- [Troubleshooting](#troubleshooting)
- [Créditos](#créditos)

---

## Como fica na tela

```
  ╭─ Resumo da instalação
  │  Usuário ......... fulano
  │  Senha ........... definida
  │  Git ............. Fulano <fulano@exemplo.com>
  │  Shell padrão .... fish
  │  Linguagens ...... sim
  │  LazyVim ......... sim
  │  Doom Emacs ...... não
  │  Docker .......... sim
  ╰─

━━ [02/14] Usuário e sudo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✔ Instalando sudo (2s)
  ✔ Criando usuário 'fulano' (grupo wheel) (0s)
  ✔ Senha definida para 'fulano'.
  ✔ sudo liberado para o grupo wheel.

━━ [09/14] Ferramentas de linha de comando ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⠹ Instalando CLIs e fontes (35 pacotes) (41s) downloading starship...
```

- **Spinner** com tempo decorrido e a última linha do log ao lado.
- **✔ / ⚠ / ↷ / ✖** para feito, aviso, pulado e erro.
- Em caso de erro: etapa, comando, as últimas linhas do log e como retomar.
- No final: resumo, avisos acumulados e os próximos passos.

---

## O que você ganha

- Usuário não-root no grupo `wheel`, com `sudo`, e já definido como **usuário padrão do WSL**.
- Locale do idioma escolhido (`pt_BR.UTF-8` ou `en_US.UTF-8`) gerado e configurado.
- Git global configurado (nome, email, `init.defaultBranch=main`, `pull.rebase=true`, aliases `co/br/ci/st`).
- Repositórios **Omarchy** e **Chaotic-AUR** ativos.
- **mise** com Python, Node, Bun, Rust e Go em `latest` *(opcional)*.
- **Shells**: `bash` e `fish` prontos (PATH, aliases, histórico, `starship`/`zoxide`/`atuin`/`mise`/`fzf`). Você escolhe qual é o padrão.
- **Prompt**: `starship` com nerd-font e paleta `tokyonight`.
- **Editores**: **LazyVim** e **Doom Emacs** *(opcionais)*.
- **TUIs**: `lazygit`, `lazydocker`, `yazi` (com previews), `zellij`, `taskwarrior-tui`, `tabiew`, `television`, `navi`, `superfile`, `atuin`, `fzf`.
- **CLIs**: `eza`, `bat`, `fd`, `ripgrep`, `jq`, `yq`, `dust`, `zoxide`, `glow`, `gum`, `tldr`, `fastfetch`, `7zip`…
- **Docker** nativo com `buildx` e `compose`, logs limitados e serviço habilitado *(opcional)*.

---

## Pré-requisitos

- Windows 10/11 com **WSL2**.
- Uma distro **Arch Linux** recém-criada: `wsl --install archlinux`.
- Internet.
- Rodar como **`root`** (é o padrão de um Arch WSL novo).

> Não é recomendado rodar em cima de um Arch WSL já customizado: o instalador reescreve `/etc/pacman.d/mirrorlist` e `/etc/locale.conf`, e edita `/etc/pacman.conf` e `/etc/wsl.conf`.

---

## Instalação

No terminal do Arch WSL, como `root`:

```bash
pacman -Sy --noconfirm git
git clone https://github.com/rogeriojunior31/firearchwsl.git
cd firearchwsl
bash install.sh
```

O instalador pergunta, tudo de uma vez:

1. **Idioma** do instalador.
2. **Usuário** Linux a criar e a **senha** dele.
3. **Nome** e **email** do Git (pode deixar vazio para pular).
4. **Shell padrão**: `bash` ou `fish`.
5. **Componentes opcionais**: linguagens, LazyVim, Doom Emacs, Docker.

Depois ele mostra o resumo, pede confirmação e segue sozinho. Ao terminar, reinicie a distro no **PowerShell**:

```powershell
wsl --terminate archlinux
```

Abra o WSL de novo e você já entra como o usuário criado.

---

## Modo não-interativo

Toda pergunta tem uma variável de ambiente equivalente. Com elas e `--yes`, nada é perguntado:

```bash
FIREARCH_LANG=pt_BR \
FIREARCH_USER=fulano FIREARCH_PASSWORD='s3nha' \
FIREARCH_GIT_NAME='Fulano' FIREARCH_GIT_EMAIL='fulano@exemplo.com' \
FIREARCH_SHELL=fish FIREARCH_SKIP=doom \
bash install.sh --yes
```

Sem terminal (CI, `wsl -- bash install.sh` capturado), o spinner é desligado e cada comando vira uma linha `✔`/`✖`.

Sem `FIREARCH_PASSWORD` nesse modo, o usuário é criado **sem senha** e o instalador avisa como definir depois (`wsl -d archlinux -u root passwd <usuario>`).

---

## Opções e variáveis

| Opção | Efeito |
|-------|--------|
| `-y`, `--yes` | Não pede a confirmação final do resumo |
| `-v`, `--verbose` | Mostra a saída crua dos comandos, sem spinner |
| `-h`, `--help` | Ajuda |

| Variável | Efeito |
|----------|--------|
| `FIREARCH_LANG` | Idioma do instalador: `pt_BR`, `en` |
| `FIREARCH_USER` | Usuário Linux a criar |
| `FIREARCH_PASSWORD` | Senha do usuário |
| `FIREARCH_GIT_NAME` / `FIREARCH_GIT_EMAIL` | Identidade do Git |
| `FIREARCH_SHELL` | Shell padrão: `bash` (default) ou `fish` |
| `FIREARCH_SKIP` | Componentes a pular: `langs`, `lazyvim`, `doom`, `docker` (separe por vírgula) |
| `FIREARCH_MISE_TOOLS` | Toolchains do mise. Default: `python node bun rust go` |
| `FIREARCH_VERBOSE=1` | Igual a `--verbose` |
| `FIREARCH_LOG` | Caminho do log. Default: `/var/log/firearchwsl/install-<data>.log` |
| `FORCE_CONFIG=1` | Sobrescreve `~/.bashrc` e `config.fish` (com backup `.bak-<data>`) |
| `DISABLE_CHAOTIC=1` | Não adiciona o Chaotic-AUR |
| `NO_COLOR=1` | Desliga as cores |

---

## Etapas do instalador

O `install.sh` é um orquestrador que dá `source` em cada script. **A ordem importa.**

| # | Etapa | Script | O que faz |
|---|-------|--------|-----------|
| 1 | Base | `install.sh` | `pacman -Syu`; instala `gum` para os prompts |
| — | Questionário | `install/preflights/wizard.sh` | Pergunta tudo, mostra o resumo, confirma |
| 2 | Usuário e sudo | `system/create_your_user.sh` | Cria o usuário no `wheel`, senha, drop-in em `/etc/sudoers.d` |
| 3 | Locale | `system/configure_locale.sh` | Gera `en_US.UTF-8` e o locale do idioma escolhido |
| 4 | WSL | `system/wsl_config.sh` | `/etc/wsl.conf`: usuário padrão e systemd; shim do `libedit` |
| 5 | Essenciais | `install/preflights/essentials_pkgs.sh` | `base-devel`, `git`, `fish`, `curl`… |
| 6 | Git | `system/configure_git_user.sh` | `git config --global` |
| 7 | Repositórios | `install/preflights/repositories.sh` | Omarchy, Chaotic-AUR, mirrors, `pacman -Syu` |
| 8 | mise | `install/preflights/install-mise.sh` | Instala o `mise` |
| 9 | CLIs | `install/pkgs/good-tools.sh` | CLIs, fontes, `yay`/`paru` |
| 10 | TUIs | `install/pkgs/tuis.sh` | TUIs e previews do yazi |
| 11 | Linguagens | `install/pkgs/install_langs.sh` | `mise use -g <tool>@latest` *(opcional)* |
| 12 | Editores | `install/pkgs/editors.sh` | LazyVim e Doom Emacs *(opcionais)* |
| 13 | Configs | `config/config.sh` | rc files, starship, shell padrão |
| 14 | Docker | `config/docker.sh` | Pacotes, `daemon.json`, grupo, serviço *(opcional)* |
| ∎ | Final | `install/preflights/finale.sh` | Logo animado (`tte`), resumo, próximos passos |

---

## Idiomas (i18n)

Nenhum script tem texto de tela fixo. Tudo passa pela função `t`:

```bash
ok "$(t user.exists "$username")"
```

Os catálogos ficam em `install/i18n/<idioma>.sh` e preenchem o array `MSG`:

```bash
MSG[user.exists]="Usuário '%s' já existe — seguindo."
```

- `en.sh` é a **referência**: toda chave existe nele.
- Os outros idiomas só sobrescrevem. Chave faltando cai no inglês.
- Cada catálogo também define `I18N_LOCALE` (o locale do sistema) e o padrão de "sim/não".

**Para adicionar um idioma:**

1. Copie `install/i18n/en.sh` para `install/i18n/<codigo>.sh` (ex.: `es.sh`).
2. Troque o cabeçalho `# name:` (é o nome que aparece no seletor) e as variáveis `I18N_*`.
3. Traduza os valores, mantendo os `%s` / `%d` na mesma ordem.

Pronto: o seletor de idioma e `FIREARCH_LANG=<codigo>` passam a aceitar o novo idioma sem mexer em mais nada.

---

## Estrutura do repositório

```
firearchwsl/
├── install.sh                 # Orquestrador: sempre o ponto de entrada
├── logo.txt                   # Banner ASCII
├── install/
│   ├── i18n/                  # Catálogos de idioma (en.sh, pt_BR.sh)
│   ├── preflights/
│   │   ├── lib.sh             # Carrega i18n + ui; helpers do usuário-alvo (as_user)
│   │   ├── i18n.sh            # t, i18n_load, seletor de idioma
│   │   ├── ui.sh              # step, run (spinner), prompts, log
│   │   ├── trap-errors.sh     # Tela de erro
│   │   ├── wizard.sh          # Questionário inicial
│   │   ├── finale.sh          # Tela final
│   │   ├── essentials_pkgs.sh · repositories.sh · install-mise.sh
│   └── pkgs/                  # good-tools, tuis, install_langs, editors
├── system/                    # Usuário, locale, git, wsl.conf
├── config/                    # rc files do usuário + Docker
├── config_files/              # Payloads copiados como estão (starship.toml)
└── default/                   # bashrc, config.fish, inputrc
```

Cada diretório tem um `AGENTS.md` com contratos, ordem e armadilhas.

---

## Pacotes instalados

**Essenciais** — `sudo` · `base-devel` · `diffutils` · `git` · `fish` · `btop` · `curl` · `wget` · `just` · `make` · `eza` · `bat` · `openssh` · `vim`

**CLIs e fontes** — `jq` · `yq` · `stow` · `fx` · `fd` · `ripgrep` · `7zip` · `zip` · `unzip` · `task` · `zellij` · `neovim` · `glow` · `gum` · `harper` · `figlet` · `asciinema` · `dust` · `less` · `man` · `starship` · `tldr` · `tree-sitter-cli` · `zoxide` · `cargo` · `python-poetry-core` · `python-terminaltexteffects` · `bash-completion` · `yay` · `paru` · `luarocks` · `ttf-cascadia-mono-nerd` · `ttf-jetbrains-mono` · `ttf-hack-nerd` · `fastfetch`

**TUIs** — `taskwarrior-tui` · `tabiew` · `lazygit` · `television` · `navi` · `yazi` · `imagemagick` · `poppler` · `fzf` · `atuin` · `rsync` · `chafa` · `resvg` · `ffmpegthumbnailer` · `libcaca` · `lynx` · `mediainfo` · `odt2txt` · `perl-image-exiftool` · `python-pillow` · `python-chardet` · `ueberzug` · `w3m` · `lazydocker` · `superfile`

**Opcionais** — mise: `python` `node` `bun` `rust` `go` · `emacs` + Doom · LazyVim · `docker` `docker-buildx` `docker-compose`

---

## Re-execução

O instalador pode ser rodado de novo com segurança:

- `pacman -S --needed` não reinstala nada.
- O usuário fica registrado em `/etc/firearchwsl/target_user`: não é perguntado de novo.
- Edições em `/etc/pacman.conf` e `/etc/wsl.conf` não duplicam.
- LazyVim e Doom só são instalados se ainda não existem.
- `~/.bashrc` e `config.fish` com edições suas são **preservados**. `FORCE_CONFIG=1` sobrescreve, guardando um backup.
- `/etc/docker/daemon.json` existente é preservado.

Não há rollback: se uma etapa falhar, corrija e rode de novo.

---

## Estendendo

**Novo grupo de pacotes** — crie `install/pkgs/<nome>.sh`:

```bash
#!/bin/bash
PACMAN_PKGS=("pacote-a" "pacote-b")
pac_install "$(t meugrupo.install)" "${PACMAN_PKGS[@]}"
```

Adicione a chave `meugrupo.install` e o título `step.meugrupo` em `install/i18n/en.sh` (e nos outros idiomas), inclua a linha no array `STEPS` do `install.sh` e some 1 em `UI_STEP_TOTAL`.

**Comando como o usuário** — use sempre `as_user`; `$HOME` e `$USER` são do root:

```bash
run "$(t minha.chave)" as_user git clone … "$TARGET_HOME/.config/foo"
```

**Convenções**

- Código, variáveis e comentários em **inglês**.
- Texto de tela **só** via `t` + catálogo.
- Comando demorado sempre dentro de `run "rótulo" …`.
- Etapa não-fatal: `run … || warn "$(t …)"`. O aviso reaparece no resumo final.
- Scripts são `source`d: use `return`, nunca `exit`, para sair cedo.

---

## Validação

```bash
find . -name '*.sh' -exec bash -n {} \;      # sintaxe
shellcheck -x install.sh                      # se disponível
fish -n default/config.fish                   # rc do fish
bash install.sh --help                        # catálogo carrega
```

Teste completo: `wsl --unregister archlinux`, `wsl --install archlinux`, clone e rode `bash install.sh` duas vezes. A segunda execução não pode abortar.

---

## Troubleshooting

| Sintoma | Causa provável | Resolução |
|---------|----------------|-----------|
| Aviso "Chaotic-AUR falhou" | Rede bloqueia o keyserver ou `cdn-mirror.chaotic.cx` | Rode de novo, ou use `DISABLE_CHAOTIC=1` |
| `target not found: <pacote>` | O pacote vinha do Chaotic-AUR, que não foi ativado | Resolva o Chaotic-AUR ou remova o pacote do array |
| `sudo` pede senha que não existe | Rodou sem TTY e sem `FIREARCH_PASSWORD` | `wsl -d archlinux -u root passwd <usuario>` |
| WSL ainda abre como root | A distro não foi reiniciada | `wsl --terminate archlinux` no PowerShell |
| `docker` exige `sudo` | O grupo `docker` só vale após novo login | `wsl --terminate archlinux` |
| Ícones do prompt aparecem como quadrados | Terminal sem Nerd Font | Configure uma Nerd Font no Windows Terminal |
| Doom Emacs com erro | Download interrompido | `~/.emacs.d/bin/doom doctor` e `doom sync` |
| Quero ver tudo que aconteceu | — | `less /var/log/firearchwsl/install-*.log` |

---

## Créditos

- **Autor:** Rogerio Junior
- **Inspirações:** [Omarchy](https://omarchy.org/), [Chaotic-AUR](https://aur.chaotic.cx/), [LazyVim](https://www.lazyvim.org/), [Doom Emacs](https://github.com/doomemacs/doomemacs), [mise](https://mise.jdx.dev/), [starship](https://starship.rs/), [yazi](https://yazi-rs.github.io/).
- **Interface:** [gum](https://github.com/charmbracelet/gum) e [terminaltexteffects](https://github.com/ChrisBuilds/terminaltexteffects).
