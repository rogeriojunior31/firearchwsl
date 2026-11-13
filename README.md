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

Português · **[English](README.en.md)**

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
- [Comando `firearch`](#comando-firearch)
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
  │  Hostname ........ meuarch
  │  Shell padrão .... fish
  │  Perfil .......... dev
  │  TUIs ............ sim
  │  Linguagens ...... sim (python node bun rust go)
  │  LazyVim ......... sim
  │  Doom Emacs ...... não
  │  Docker .......... sim
  ╰─

━━ [02/14] Usuário e sudo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ▱▱▱▱▱▱▱▱▱▱   7% · 1m04s
  ✔ Instalando sudo (2s)
  ✔ Criando usuário 'fulano' (grupo wheel) (0s)
  ✔ Senha definida para 'fulano'.
  ✔ sudo liberado para o grupo wheel.

━━ [09/14] Ferramentas de linha de comando ━━━━━━━━━━━━━━━━ ▰▰▰▰▰▱▱▱▱▱  57% · 2m31s
  ⠹ Instalando CLIs e fontes (35 pacotes) (41s) downloading starship...
```

- **Progresso geral** no cabeçalho de cada etapa (barra, % e tempo decorrido), no título da aba e no anel de progresso da aba/barra de tarefas do Windows Terminal (fica vermelho se algo falhar).
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
- Pastas `~/Projects`, `~/Work` e `~/Notes` já criadas na sua home (`FIREARCH_HOME_DIRS` muda a lista).
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

### Um comando, pelo Windows

No **PowerShell**:

```powershell
irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/main/bootstrap.ps1 | iex
```

O `bootstrap.ps1` instala a distro oficial do Arch (se você ainda não tiver), baixa o firearchwsl para `/opt/firearchwsl` dentro dela e roda o instalador. Depois ele instala a **CaskaydiaMono Nerd Font** no seu usuário do Windows, cria o perfil **FireArch** no Windows Terminal (fonte + tema Tokyo Night + ícone 🔥) e reinicia a distro. Nada disso pede administrador, e rodar de novo é seguro.

O perfil é um *fragment* do Windows Terminal (`%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\firearchwsl\`): o seu `settings.json` não é tocado. Para usá-lo como padrão, escolha **FireArch** em *Configurações → Inicialização → Perfil padrão*.

Com opções:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/main/bootstrap.ps1))) -Name archdev
```

| Parâmetro | Efeito |
|-----------|--------|
| `-Name <distro>` | Nome da distro a criar ou reaproveitar (default `archlinux`) |
| `-Branch <branch>` | Branch a clonar (default `main`) |
| `-Source <caminho>` | Copia um checkout local em vez de clonar |
| `-Yes` | Pula a confirmação final do instalador |
| `-VerboseInstall` | Saída crua dos comandos, sem spinner |
| `-NoFont` | Não instala a Nerd Font (ou `$env:FIREARCH_NO_FONT = '1'`) |
| `-NoTerminal` | Não cria o perfil do Windows Terminal (ou `$env:FIREARCH_NO_TERMINAL = '1'`) |

As variáveis `FIREARCH_*` definidas no PowerShell (`$env:FIREARCH_USER = '...'`) são repassadas para dentro do WSL.

### Manual, dentro do Arch WSL

Como `root`:

```bash
pacman -Syu --noconfirm git
git clone https://github.com/rogeriojunior31/firearchwsl.git
cd firearchwsl
bash install.sh
```

### As perguntas

O instalador pergunta, tudo de uma vez:

1. **Idioma** do instalador.
2. **Usuário** Linux a criar. Contas do sistema (`root`, `bin`, `http`…) e nomes inválidos são recusados na hora.
3. **Senha** do usuário, digitada duas vezes. Não pode ficar vazia: é a senha do `sudo`.
4. **Nome** e **email** do Git (pode deixar vazio para pular).
5. **Hostname** da distro. Enter mantém o nome da máquina Windows.
6. **Shell padrão**: `bash` ou `fish`.
7. **Perfil de instalação**:
   - `minimal`: só CLIs, shells e prompt (o mais rápido);
   - `dev` *(padrão)*: tudo menos o Doom Emacs;
   - `full`: tudo, com Doom Emacs (+5 a 15 min);
   - `custom`: você escolhe cada componente (TUIs, linguagens, LazyVim, Doom Emacs, Docker) e cada linguagem (Python, Node, Bun, Rust, Go).

Depois ele mostra o resumo e pede confirmação:

- **Sim** começa a instalação, que segue sozinha até o fim.
- **Não** volta ao formulário com as respostas já preenchidas, para você corrigir só o que quiser (a senha é pedida de novo).
- **Ctrl+C** cancela sem mudar nada além da atualização da base.

Ao terminar, reinicie a distro no **PowerShell**:

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
FIREARCH_SHELL=fish FIREARCH_PROFILE=minimal \
bash install.sh --yes
```

`FIREARCH_PROFILE` escolhe o perfil; `FIREARCH_SKIP` (`tuis,langs,lazyvim,doom,docker`) escolhe componente por componente e tem prioridade. Sem nenhuma das duas, o modo não-interativo usa o perfil `dev`.

Sem terminal (CI, `wsl -- bash install.sh` capturado), o spinner é desligado e cada comando vira uma linha `✔`/`✖`.

Nesse modo, um usuário novo **exige** `FIREARCH_PASSWORD`: sem ela o instalador para antes de mudar qualquer coisa. Nunca é criado usuário sem senha.

Os prompts leem direto do terminal (`/dev/tty`), então continuam funcionando mesmo se a entrada padrão for um pipe.

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
| `FIREARCH_PASSWORD` | Senha do usuário (obrigatória sem terminal, se o usuário for novo) |
| `FIREARCH_GIT_NAME` / `FIREARCH_GIT_EMAIL` | Identidade do Git |
| `FIREARCH_HOSTNAME` | Hostname da distro. Default: o nome da máquina Windows |
| `FIREARCH_SHELL` | Shell padrão: `bash` (default) ou `fish` |
| `FIREARCH_PROFILE` | Perfil: `minimal`, `dev` (default), `full` ou `custom` |
| `FIREARCH_SKIP` | Componentes a pular: `tuis`, `langs`, `lazyvim`, `doom`, `docker` (separe por vírgula). Se definida, o perfil não é perguntado |
| `FIREARCH_MISE_TOOLS` | Toolchains do mise. Default: `python node bun rust go` |
| `FIREARCH_HOME_DIRS` | Pastas criadas na home. Default: `Projects Work Notes` (`""` não cria nenhuma) |
| `FIREARCH_VERBOSE=1` | Igual a `--verbose` |
| `FIREARCH_LOG` | Caminho do log. Default: `/var/log/firearchwsl/install-<data>.log` |
| `FORCE_CONFIG=1` | Sobrescreve `~/.bashrc` e `config.fish` (com backup `.bak-<data>`) |
| `DISABLE_CHAOTIC=1` | Não adiciona o Chaotic-AUR |
| `NO_COLOR=1` | Desliga as cores |
| `FIREARCH_NO_GUM=1` | Prompts simples (`read`) em vez do `gum` |

---

## Etapas do instalador

O `install.sh` é um orquestrador que dá `source` em cada script. **A ordem importa.**

| # | Etapa | Script | O que faz |
|---|-------|--------|-----------|
| 1 | Base | `install.sh` | `pacman -Syu`; instala `gum` para os prompts |
| — | Questionário | `install/preflights/wizard.sh` | Pergunta tudo, mostra o resumo, confirma ou volta para corrigir |
| 2 | Usuário e sudo | `system/create_your_user.sh` | Cria o usuário no `wheel` com a senha escolhida, drop-in em `/etc/sudoers.d` |
| 3 | Locale | `system/configure_locale.sh` | Gera `en_US.UTF-8` e o locale do idioma escolhido (pula se já existem) |
| 4 | WSL | `system/wsl_config.sh` | `/etc/wsl.conf`: usuário padrão, hostname, systemd; mise ignora a config do Windows; shim do `libedit` |
| 5 | Essenciais | `install/preflights/essentials_pkgs.sh` | `base-devel`, `git`, `fish`, `curl`… |
| 6 | Git | `system/configure_git_user.sh` | `git config --global` |
| 7 | Repositórios | `install/preflights/repositories.sh` | Mirrors (com backup), Chaotic-AUR, Omarchy por último, `pacman -Syu` |
| 8 | mise | `install/preflights/install-mise.sh` | Instala o `mise` |
| 9 | CLIs | `install/pkgs/good-tools.sh` | CLIs, fontes, `yay`/`paru` |
| 10 | TUIs | `install/pkgs/tuis.sh` | TUIs e previews do yazi *(opcional)* |
| 11 | Linguagens | `install/pkgs/install_langs.sh` | `mise use -g <tool>@latest` *(opcional)* |
| 12 | Editores | `install/pkgs/editors.sh` | LazyVim e Doom Emacs *(opcionais)* |
| 13 | Configs | `config/config.sh` | rc files, starship, pastas `~/Projects`, `~/Work`, `~/Notes`, comando `firearch`, shell padrão |
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
├── bootstrap.ps1              # Windows: instala a distro e roda o instalador
├── install.sh                 # Orquestrador: sempre o ponto de entrada no Linux
├── bin/firearch              # Comando do dia a dia: update, doctor, setup, logs
├── logo.txt                   # Banner ASCII
├── tests/                     # check.sh (estático) e container.sh (ponta a ponta)
├── .github/workflows/ci.yml   # CI: os dois testes acima
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

**CLIs e fontes** — `jq` · `yq` · `stow` · `fx` · `fd` · `ripgrep` · `7zip` · `zip` · `unzip` · `task` · `zellij` · `neovim` · `glow` · `gum` · `harper` · `figlet` · `asciinema` · `dust` · `less` · `man-db` · `starship` · `tldr` · `tree-sitter-cli` · `zoxide` · `python-poetry-core` · `python-terminaltexteffects` · `bash-completion` · `yay` · `paru` · `luarocks` · `ttf-cascadia-mono-nerd` · `ttf-jetbrains-mono` · `ttf-hack-nerd` · `fastfetch`

**TUIs** — `taskwarrior-tui` · `tabiew` · `lazygit` · `television` · `navi` · `yazi` · `imagemagick` · `poppler` · `fzf` · `atuin` · `rsync` · `chafa` · `resvg` · `ffmpegthumbnailer` · `libcaca` · `lynx` · `mediainfo` · `odt2txt` · `perl-image-exiftool` · `python-pillow` · `python-chardet` · `ueberzug` · `w3m` · `lazydocker` · `superfile`

**Opcionais** — mise: `python` `node` `bun` `rust` `go` · `emacs` + Doom · LazyVim · `docker` `docker-buildx` `docker-compose`

O Rust vem do mise. Se você pular as linguagens (ou tirar `rust` de `FIREARCH_MISE_TOOLS`), o instalador põe o `rust` do pacman no lugar, para o `cargo` continuar existindo.

Um pacote que sumiu dos repositórios não derruba mais o grupo inteiro: ele é pulado e vira um aviso no resumo final.

### Repositórios

- **Chaotic-AUR** (assinado) entra antes do **Omarchy**. O Omarchy não tem assinatura (`SigLevel = Optional TrustAll`), então fica por último: o pacman pega cada pacote do primeiro repositório que o tem, e assim o Omarchy só entrega o que nenhum repositório assinado oferece (hoje, o `python-terminaltexteffects`).
- O `mirrorlist` original fica guardado em `/etc/pacman.d/mirrorlist.firearchwsl.bak`.

### mise e o home do Windows

O WSL abre em `/mnt/c/Users/<você>`, e o mise procura configs subindo a partir da pasta atual: sem ajuste, ele leria o `~/.config/mise` do **Windows** e listaria aquelas ferramentas como `missing`. O instalador cria `~/.config/mise/miserc.toml` ignorando só essa pasta; o `mise.toml` dos seus projetos em `/mnt/c` continua valendo.

---

## Comando `firearch`

Depois da instalação, o comando `firearch` fica disponível para o seu usuário. Sem argumentos ele abre um menu:

| Comando | O que faz |
|---------|-----------|
| `firearch update` | `pacman -Syu`, `mise upgrade` e atualiza o próprio firearchwsl (`/opt/firearchwsl`) |
| `firearch doctor` | Verifica WSL, systemd, usuário padrão, sudo, integração com o Windows, DNS, locale, espaço em disco, mise e Docker. Cada problema vem com a correção |
| `firearch setup` | Roda o instalador de novo (refaz as perguntas) |
| `firearch logs` | Abre o último log do instalador |
| `firearch version` | Mostra a versão instalada |

Ele fala o idioma escolhido na instalação (gravado em `/etc/firearchwsl/lang`; `FIREARCH_LANG` troca).

---

## Re-execução

O instalador pode ser rodado de novo com segurança:

- `pacman -S --needed` não reinstala nada.
- O usuário fica registrado em `/etc/firearchwsl/target_user`: não é perguntado de novo.
- Edições em `/etc/pacman.conf` e `/etc/wsl.conf` não duplicam.
- LazyVim e Doom só são instalados se ainda não existem.
- `~/.bashrc` e `config.fish` que você **não editou** são atualizados para a versão nova do repositório. Os que **têm edições suas** são preservados; `FORCE_CONFIG=1` sobrescreve, guardando um backup.
- `/etc/pacman.conf` é reorganizado para o Omarchy ficar por último, inclusive em instalações antigas.
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
bash tests/check.sh       # bash -n, shellcheck, fish -n, catálogos de idioma, fins de linha
bash tests/container.sh   # instalação completa, duas vezes, num contêiner Arch limpo (precisa de Docker)
```

O `check.sh` confere também que toda chave usada no código existe no `en.sh` e que cada tradução tem as mesmas chaves e os mesmos `%s` do inglês.

O CI (`.github/workflows/ci.yml`) roda os dois em todo push e pull request.

Teste no WSL de verdade, sem mexer na sua distro: `.\bootstrap.ps1 -Name firearch-test -Source .` cria uma distro separada a partir do seu checkout. Depois, `wsl --unregister firearch-test`.

---

## Troubleshooting

| Sintoma | Causa provável | Resolução |
|---------|----------------|-----------|
| Aviso "Chaotic-AUR falhou" | Rede bloqueia o keyserver ou `cdn-mirror.chaotic.cx` | Rode de novo, ou use `DISABLE_CHAOTIC=1` |
| Aviso "Não encontrado em nenhum repositório" | O pacote vem do Chaotic-AUR, que não foi ativado, ou mudou de nome | Resolva o Chaotic-AUR ou corrija o nome no array |
| "Um usuário novo precisa de senha" | Rodou sem terminal e sem `FIREARCH_PASSWORD` | Rode num terminal, ou passe `FIREARCH_PASSWORD` |
| Esqueci a senha do usuário | — | `wsl -d archlinux -u root passwd <usuario>` |
| Hostname novo não aparece | O WSL só aplica no próximo start | `wsl --terminate archlinux` |
| WSL ainda abre como root | A distro não foi reiniciada | `wsl --terminate archlinux` no PowerShell |
| `docker` exige `sudo` | O grupo `docker` só vale após novo login | `wsl --terminate archlinux` |
| Ícones do prompt aparecem como quadrados | Terminal sem Nerd Font | Use o perfil **FireArch** do Windows Terminal (o bootstrap instala a fonte), ou escolha uma Nerd Font no seu perfil |
| Algo estranho e não sei o quê | — | `firearch doctor` |
| Doom Emacs com erro | Download interrompido | `~/.emacs.d/bin/doom doctor` e `doom sync` |
| Quero ver tudo que aconteceu | — | `less /var/log/firearchwsl/install-*.log` |

---

## Créditos

- **Autor:** Rogerio Junior
- **Inspirações:** [Omarchy](https://omarchy.org/), [Chaotic-AUR](https://aur.chaotic.cx/), [LazyVim](https://www.lazyvim.org/), [Doom Emacs](https://github.com/doomemacs/doomemacs), [mise](https://mise.jdx.dev/), [starship](https://starship.rs/), [yazi](https://yazi-rs.github.io/).
- **Interface:** [gum](https://github.com/charmbracelet/gum) e [terminaltexteffects](https://github.com/ChrisBuilds/terminaltexteffects).
