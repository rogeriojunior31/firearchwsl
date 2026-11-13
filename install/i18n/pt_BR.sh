# shellcheck shell=bash disable=SC2034
# name: Português (Brasil)
#
# Overrides for en.sh. Missing keys fall back to English.
# Values are printf formats — keep the %s / %d placeholders and their order.

I18N_LOCALE="pt_BR.UTF-8"
I18N_LANGUAGE="pt_BR:en_US"
I18N_YES_REGEX='^[sSyY]'
I18N_YES_NO_HINT="[S/n]"

## Generic UI
MSG[ui.yes]="Sim"
MSG[ui.no]="Não"
MSG[ui.on]="sim"
MSG[ui.off]="não"
MSG[ui.cancelled]="Cancelado."
MSG[ui.interrupted]="Interrompido pelo usuário."
MSG[ui.invalid_choice]="Valor inválido para %s: '%s' (opções: %s)"
MSG[ui.multi_hint]="espaço marca/desmarca · enter confirma"
MSG[ui.install_q]="Instalar %s?"
MSG[ui.pkg_count]="%s (%d pacotes)"

## Banner
MSG[banner.tagline]="Arch Linux + WSL2, do zero ao ambiente de dev completo."
MSG[banner.log]="Log completo: %s"

## Pre-checks and usage
MSG[pre.need_root]="Rode como root dentro do Arch WSL (ex.: wsl -d archlinux -u root)."
MSG[pre.need_pacman]="pacman não encontrado — este instalador é só para Arch Linux."
MSG[pre.unknown_opt]="Opção desconhecida: %s"
MSG[pre.unknown_lang]="Idioma desconhecido '%s'. Disponíveis: %s"
MSG[usage]="firearchwsl — bootstrap de Arch Linux no WSL2

Uso (como root, dentro do Arch WSL):
  bash install.sh [opções]

Opções:
  -y, --yes       não pede a confirmação final do resumo
  -v, --verbose   mostra a saída crua dos comandos (sem spinner)
  -h, --help      mostra esta ajuda

Variáveis de ambiente (todas opcionais no modo interativo):
  FIREARCH_LANG        idioma do instalador: en, pt_BR
  FIREARCH_USER        nome do usuário Linux a criar
  FIREARCH_PASSWORD    senha do usuário (sem ela, defina depois com passwd)
  FIREARCH_GIT_NAME    git config user.name
  FIREARCH_GIT_EMAIL   git config user.email
  FIREARCH_SHELL       shell padrão: bash (default) ou fish
  FIREARCH_SKIP        componentes a pular: langs,lazyvim,doom,docker
  FIREARCH_MISE_TOOLS  toolchains do mise (default: \"python node bun rust go\")
  FIREARCH_VERBOSE=1   igual a --verbose
  FIREARCH_LOG         caminho do arquivo de log
  FORCE_CONFIG=1       sobrescreve ~/.bashrc e config.fish (faz backup antes)
  DISABLE_CHAOTIC=1    não adiciona o repositório Chaotic-AUR

Exemplo 100%% não-interativo:
  FIREARCH_LANG=pt_BR FIREARCH_USER=fulano FIREARCH_PASSWORD='s3nha' \\
  FIREARCH_GIT_NAME='Fulano' FIREARCH_GIT_EMAIL='fulano@exemplo.com' \\
  FIREARCH_SKIP=doom bash install.sh --yes"

## Error trap
MSG[err.title]="A instalação do firearchwsl falhou"
MSG[err.step]="Etapa:"
MSG[err.command]="Comando:"
MSG[err.where]="Onde:"
MSG[err.log_tail]="Últimas linhas do log:"
MSG[err.log_full]="Log completo:"
MSG[err.rerun]="O instalador é idempotente — corrija o problema e rode de novo:"

## Step titles
MSG[step.base]="Preparando a base"
MSG[step.user]="Usuário e sudo"
MSG[step.locale]="Locale do sistema"
MSG[step.wsl]="Ajustes do WSL"
MSG[step.essentials]="Pacotes essenciais"
MSG[step.git]="Git"
MSG[step.repos]="Repositórios extras"
MSG[step.mise]="mise"
MSG[step.tools]="Ferramentas de linha de comando"
MSG[step.tuis]="TUIs"
MSG[step.langs]="Linguagens (mise)"
MSG[step.editors]="Editores"
MSG[step.config]="Configs do usuário"
MSG[step.docker]="Docker"

## Base
MSG[base.sync]="Atualizando o sistema (pacman -Syu)"
MSG[base.gum]="Instalando gum (prompts interativos)"
MSG[base.gum_fail]="gum indisponível — usando prompts simples."

## Wizard
MSG[wiz.user_known]="Usuário já registrado em execução anterior: %s"
MSG[wiz.user_q]="Nome do seu usuário Linux (minúsculas, sem espaço)"
MSG[wiz.user_invalid_env]="FIREARCH_USER ausente ou inválido ('%s'). Ex.: FIREARCH_USER=fulano bash install.sh"
MSG[wiz.user_invalid]="Nome inválido: use letras minúsculas, números, '-' ou '_' (e não 'root')."
MSG[wiz.pw_q]="Senha para %s (usada no sudo)"
MSG[wiz.pw_repeat]="Repita a senha"
MSG[wiz.pw_mismatch]="As senhas não conferem (ou estão vazias). Tente de novo."
MSG[wiz.git_name_q]="Seu nome para o Git — user.name (vazio = pular)"
MSG[wiz.git_email_q]="Seu email para o Git — user.email (vazio = pular)"
MSG[wiz.shell_q]="Shell padrão do usuário"
MSG[wiz.comp_q]="Componentes opcionais"
MSG[wiz.comp_langs]="Python · Node · Bun · Rust · Go via mise"
MSG[wiz.comp_lazyvim]="Neovim com LazyVim"
MSG[wiz.comp_doom]="Doom Emacs (demora 5 a 15 min)"
MSG[wiz.comp_docker]="Docker + buildx + compose"
MSG[wiz.sum_title]="Resumo da instalação"
MSG[wiz.sum_user]="Usuário"
MSG[wiz.sum_password]="Senha"
MSG[wiz.sum_git]="Git"
MSG[wiz.sum_shell]="Shell padrão"
MSG[wiz.sum_langs]="Linguagens"
MSG[wiz.sum_lazyvim]="LazyVim"
MSG[wiz.sum_doom]="Doom Emacs"
MSG[wiz.sum_docker]="Docker"
MSG[wiz.pw_set]="definida"
MSG[wiz.pw_kept]="mantida (usuário já existe)"
MSG[wiz.pw_unset]="não definida — defina depois com passwd"
MSG[wiz.confirm_q]="Tudo certo? Começar a instalação?"
MSG[wiz.aborted]="Instalação cancelada — nada foi alterado além da atualização da base."

## User
MSG[user.need_root]="Este script deve ser executado como root."
MSG[user.sudo]="Instalando sudo"
MSG[user.exists]="Usuário '%s' já existe — seguindo."
MSG[user.add_wheel]="Adicionando '%s' ao grupo wheel"
MSG[user.create]="Criando usuário '%s' (grupo wheel)"
MSG[user.pw_set]="Senha definida para '%s'."
MSG[user.no_pw]="Usuário '%s' criado SEM senha (sudo não vai funcionar). Defina com: wsl -d %s -u root passwd %s"
MSG[user.sudoers_invalid]="Drop-in de sudoers inválido — removido. Abortando."
MSG[user.sudo_ok]="sudo liberado para o grupo wheel."

## Locale
MSG[locale.gen]="Gerando locales (%s)"
MSG[locale.done]="Idioma padrão: %s (/etc/locale.conf)."

## WSL
MSG[wsl.default_user]="Usuário padrão do WSL: %s (/etc/wsl.conf)."
MSG[wsl.systemd]="systemd habilitado no boot do WSL."
MSG[wsl.libedit]="Shim libedit.so.2 criado."
MSG[wsl.libedit_skip]="libedit.so ausente — shim libedit.so.2 não é necessário agora."

## Packages
MSG[ess.install]="Instalando essenciais"
MSG[tools.install]="Instalando CLIs e fontes"
MSG[tuis.install]="Instalando TUIs e previews do yazi"
MSG[mise.install]="Instalando mise"

## Git
MSG[git.name_skip]="user.name não informado — depois: git config --global user.name \"Seu Nome\""
MSG[git.email_skip]="user.email não informado — depois: git config --global user.email \"voce@exemplo.com\""
MSG[git.defaults]="Defaults aplicados: branch main, pull.rebase, aliases co/br/ci/st."

## Repositories
MSG[repo.candy]="pacman: Color + ILoveCandy + VerbosePkgLists."
MSG[repo.omarchy]="Repositório Omarchy ativo."
MSG[repo.mirrors]="Mirrorlist: mirrors globais."
MSG[repo.chaotic_disabled]="Chaotic-AUR desativado (DISABLE_CHAOTIC)."
MSG[repo.chaotic_arch]="Chaotic-AUR só existe para x86_64 — pulando."
MSG[repo.chaotic_already]="Repositório Chaotic-AUR já ativo."
MSG[repo.chaotic_setup]="Instalando keyring e mirrorlist do Chaotic-AUR"
MSG[repo.chaotic_ok]="Repositório Chaotic-AUR ativo."
MSG[repo.chaotic_fail]="Chaotic-AUR falhou — seguindo sem ele (use DISABLE_CHAOTIC=1 para pular de vez)."
MSG[repo.sync]="Sincronizando repositórios (pacman -Syu)"

## Languages
MSG[langs.skip]="Linguagens puladas (FIREARCH_SKIP=langs)."
MSG[langs.fail]="Falha ao instalar %s — depois: mise use -g %s@latest"

## Editors
MSG[ed.lazy_skip]="LazyVim pulado (FIREARCH_SKIP=lazyvim)."
MSG[ed.lazy_exists]="~/.config/nvim já existe — LazyVim preservado."
MSG[ed.lazy_clone]="Clonando LazyVim starter"
MSG[ed.lazy_fail]="LazyVim falhou — veja o log e clone manualmente: https://www.lazyvim.org/installation"
MSG[ed.doom_skip]="Doom Emacs pulado (FIREARCH_SKIP=doom)."
MSG[ed.emacs]="Instalando Emacs"
MSG[ed.doom_exists]="Doom Emacs já instalado em ~/.emacs.d."
MSG[ed.doom_clone]="Clonando Doom Emacs"
MSG[ed.doom_note]="Doom Emacs baixa e compila pacotes: leva de 5 a 15 min. Bom momento pro café ☕"
MSG[ed.doom_fail]="doom install retornou erro — depois rode: ~/.emacs.d/bin/doom doctor"

## User config
MSG[cfg.payloads]="Payloads copiados para ~/.local/share/firearchwsl."
MSG[cfg.rc_installed]="%s instalado."
MSG[cfg.rc_current]="%s já está atualizado."
MSG[cfg.rc_overwritten]="%s sobrescrito (backup: %s)."
MSG[cfg.rc_preserved]="%s tem edições locais — preservado (FORCE_CONFIG=1 sobrescreve com backup)."
MSG[cfg.starship]="Starship apontando para o tema do firearchwsl."
MSG[cfg.shell_missing]="Shell %s não encontrado — mantendo o shell atual."
MSG[cfg.shell_already]="Shell padrão já é %s."
MSG[cfg.shell_set]="Definindo %s como shell padrão"

## Docker
MSG[docker.skip]="Docker pulado (FIREARCH_SKIP=docker)."
MSG[docker.install]="Instalando Docker"
MSG[docker.daemon_new]="/etc/docker/daemon.json criado (logs: 10 MB x 5 arquivos)."
MSG[docker.daemon_keep]="/etc/docker/daemon.json já existe — preservado."
MSG[docker.group_already]="%s já está no grupo docker."
MSG[docker.group_add]="Adicionando %s ao grupo docker"
MSG[docker.enable]="Habilitando e iniciando o serviço docker"
MSG[docker.enable_fail]="Não foi possível iniciar o docker — depois: sudo systemctl enable --now docker"
MSG[docker.no_systemd]="systemd não está ativo nesta sessão — após reiniciar o WSL rode: sudo systemctl enable --now docker"

## Finale
MSG[fin.title]="Tudo pronto, dog! 🔥"
MSG[fin.user]="Usuário"
MSG[fin.shell]="shell: %s"
MSG[fin.time]="Tempo total"
MSG[fin.warnings]="Avisos"
MSG[fin.log]="Log completo"
MSG[fin.warn_header]="Avisos desta execução:"
MSG[fin.next]="Próximos passos"
MSG[fin.step1]="No PowerShell do Windows, reinicie a distro:"
MSG[fin.step2]="Abra de novo com %s — você já entra como %s."
MSG[fin.step3]="Use uma Nerd Font no terminal do Windows para ver os ícones do prompt."
