set -euo pipefail

msg() { printf '\033[1;32m[+] %s\033[0m\n' "$*"; }
err() { printf '\033[1;31m[!] %s\033[0m\n' "$*" >&2; }

if ! command -v sudo >/dev/null 2>&1; then
  err "sudo é necessário para instalar pacotes."
  exit 1
fi

msg "Atualizando índices e instalando 'mise' do repositório Extra (evita upgrade parcial)..."
sudo pacman -Syu --needed --noconfirm mise

SHELL_NAME="$(basename "${SHELL:-}")"
case "$SHELL_NAME" in
bash)
  RC_FILE="$HOME/.bashrc"
  ACT_LINE='eval "$(mise activate bash)"'
  ;;
zsh)
  RC_FILE="$HOME/.zshrc"
  ACT_LINE='eval "$(mise activate zsh)"'
  ;;
fish)
  RC_FILE="$HOME/.config/fish/config.fish"
  mkdir -p "$(dirname "$RC_FILE")"
  ACT_LINE='mise activate fish | source'
  ;;
*)
  SHELL_NAME="bash"
  RC_FILE="$HOME/.bashrc"
  ACT_LINE='eval "$(mise activate bash)"'
  ;;
esac

if [ -f "$RC_FILE" ] && grep -Fq "$ACT_LINE" "$RC_FILE"; then
  msg "Ativação já presente em $RC_FILE"
else
  msg "Adicionando ativação do mise em $RC_FILE"
  {
    printf '\n# Mise: ativação automática\n'
    printf '%s\n' "$ACT_LINE"
  } >>"$RC_FILE"
fi

msg "Verificando versão do mise..."
mise --version || true

msg "Concluído. Mise instalado e configurad
