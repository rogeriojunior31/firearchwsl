<#
.SYNOPSIS
  Installs an Arch Linux WSL distro (if needed) and runs firearchwsl inside it.

.DESCRIPTION
  1. Checks that WSL is available.
  2. Installs the official Arch Linux distro under -Name, unless it exists.
  3. Puts firearchwsl in /opt/firearchwsl inside the distro (git clone, or a
     copy of a local checkout with -Source).
  4. Runs install.sh as root. It asks its own questions (language, user,
     password...) in this terminal.
  5. Restarts the distro so the new default user, groups and hostname apply.

  Every FIREARCH_* variable set in this PowerShell session (plus FORCE_CONFIG
  and DISABLE_CHAOTIC) is forwarded to the installer, so unattended runs work:
    $env:FIREARCH_USER = 'jane'; $env:FIREARCH_PASSWORD = '...'; .\bootstrap.ps1 -Yes

.EXAMPLE
  irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/main/bootstrap.ps1 | iex

.EXAMPLE
  .\bootstrap.ps1 -Name archdev -Branch my-branch

.EXAMPLE
  .\bootstrap.ps1 -Source .     # use this local checkout instead of cloning
#>
[CmdletBinding()]
param(
  # WSL distro name to install into / create.
  [string]$Name = 'archlinux',
  # Git repository and branch to clone.
  [string]$Repo = 'https://github.com/rogeriojunior31/firearchwsl.git',
  [string]$Branch = 'main',
  # Local checkout to copy instead of cloning (Windows path).
  [string]$Source,
  # Skip the installer's final confirmation (install.sh --yes).
  [switch]$Yes,
  # Raw command output instead of spinners (install.sh --verbose).
  [switch]$VerboseInstall
)

$ErrorActionPreference = 'Stop'
# wsl.exe writes UTF-16 by default; this makes its output readable.
$env:WSL_UTF8 = '1'

## Messages ###################################################################
# The installer itself is fully translated; these are only the few lines the
# bootstrap prints before it starts.
$lang = $env:FIREARCH_LANG
if (-not $lang) { if ((Get-Culture).Name -like 'pt*') { $lang = 'pt_BR' } else { $lang = 'en' } }
$messages = @{
  en    = @{
    noWsl      = 'WSL is not available. Install it first (as administrator):  wsl --install --no-distribution'
    installing = 'Installing the Arch Linux distro as "{0}"...'
    installFail = 'Could not install the distro (wsl --install exit {0}).'
    exists     = 'Distro "{0}" already exists — using it.'
    fetching   = 'Fetching firearchwsl into /opt/firearchwsl...'
    fetchFail  = 'Could not fetch firearchwsl (exit {0}).'
    running    = 'Starting the installer...'
    runFail    = 'The installer stopped (exit {0}). Fix the problem and run this script again — it is safe to re-run.'
    restarting = 'Restarting the distro so the new settings apply...'
    done       = 'Done! Open your new environment with:'
  }
  pt_BR = @{
    noWsl      = 'O WSL não está disponível. Instale primeiro (como administrador):  wsl --install --no-distribution'
    installing = 'Instalando a distro Arch Linux como "{0}"...'
    installFail = 'Não foi possível instalar a distro (wsl --install saiu com {0}).'
    exists     = 'A distro "{0}" já existe — usando ela.'
    fetching   = 'Baixando o firearchwsl para /opt/firearchwsl...'
    fetchFail  = 'Não foi possível baixar o firearchwsl (saída {0}).'
    running    = 'Iniciando o instalador...'
    runFail    = 'O instalador parou (saída {0}). Corrija o problema e rode este script de novo — é seguro repetir.'
    restarting = 'Reiniciando a distro para as novas configurações valerem...'
    done       = 'Pronto! Abra o seu novo ambiente com:'
  }
}
if (-not $messages.ContainsKey($lang)) { $lang = 'en' }
function Say([string]$key, $arg) {
  $text = $messages[$lang][$key] -f $arg
  Write-Host "  $([char]0x2022) $text" -ForegroundColor DarkYellow
}
function Fail([string]$key, $arg) {
  Write-Host "  $([char]0x2716) $($messages[$lang][$key] -f $arg)" -ForegroundColor Red
  exit 1
}

## 1. WSL ######################################################################
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { Fail 'noWsl' }
& wsl.exe --status *> $null
if ($LASTEXITCODE -ne 0) { Fail 'noWsl' }

## 2. Distro ###################################################################
$distros = @(& wsl.exe --list --quiet) | ForEach-Object { $_.Trim() } | Where-Object { $_ }
if ($distros -contains $Name) {
  Say 'exists' $Name
} else {
  Say 'installing' $Name
  $installArgs = @('--install', 'archlinux', '--no-launch')
  if ($Name -ne 'archlinux') { $installArgs += @('--name', $Name) }
  & wsl.exe @installArgs
  if ($LASTEXITCODE -ne 0) { Fail 'installFail' $LASTEXITCODE }
}

## 3. Fetch firearchwsl ########################################################
# Parameters travel as environment variables through WSLENV (the /p flag
# translates a Windows path), and the script itself as base64 — nothing is
# spliced into a command line, so quoting cannot break.
$fetchScript = @'
set -euo pipefail
dest=/opt/firearchwsl
log=/tmp/firearchwsl-bootstrap.log
if [[ -n "${FA_SOURCE:-}" ]]; then
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -a "$FA_SOURCE/." "$dest/"
else
  # A distro installed with --no-launch skipped the image's first-login
  # setup, which is what creates the pacman keyring (install.sh does the same).
  if ! pacman-key --list-secret-keys 2>/dev/null | grep -q '^sec'; then
    { pacman-key --init && pacman-key --populate archlinux; } >"$log" 2>&1
  fi
  # Keyring alone with -Sy (the one sanctioned exception), then a full
  # upgrade with git: never a partial upgrade.
  if ! { pacman -Sy --noconfirm --needed archlinux-keyring &&
    pacman -Su --noconfirm --needed git; } >"$log" 2>&1; then
    tail -n 20 "$log"
    exit 1
  fi
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" fetch --depth 1 origin "$FA_BRANCH"
    git -C "$dest" checkout -q -B "$FA_BRANCH" FETCH_HEAD
  else
    rm -rf "$dest"
    git clone -q --depth 1 --branch "$FA_BRANCH" "$FA_REPO" "$dest"
  fi
fi
'@
$env:FA_REPO = $Repo
$env:FA_BRANCH = $Branch
$forward = @('FA_REPO', 'FA_BRANCH')
if ($Source) {
  $env:FA_SOURCE = (Resolve-Path -LiteralPath $Source).Path
  $forward += 'FA_SOURCE/p'
} else {
  Remove-Item Env:FA_SOURCE -ErrorAction SilentlyContinue
}

# Forward the installer's own settings too (see the description above).
Get-ChildItem Env: | Where-Object { $_.Name -like 'FIREARCH_*' -or $_.Name -in @('FORCE_CONFIG', 'DISABLE_CHAOTIC', 'NO_COLOR') } |
  ForEach-Object { $forward += $_.Name }
$previousWslEnv = $env:WSLENV
$env:WSLENV = (@($forward) + @($previousWslEnv | Where-Object { $_ })) -join ':'

try {
  Say 'fetching'
  $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes(($fetchScript -replace "`r`n", "`n")))
  & wsl.exe -d $Name -u root --exec bash -c "echo $encoded | base64 -d | bash"
  if ($LASTEXITCODE -ne 0) { Fail 'fetchFail' $LASTEXITCODE }

  ## 4. Run the installer ######################################################
  Say 'running'
  $installerArgs = @()
  if ($Yes) { $installerArgs += '--yes' }
  if ($VerboseInstall) { $installerArgs += '--verbose' }
  & wsl.exe -d $Name -u root --cd /opt/firearchwsl --exec bash /opt/firearchwsl/install.sh @installerArgs
  if ($LASTEXITCODE -ne 0) { Fail 'runFail' $LASTEXITCODE }
} finally {
  $env:WSLENV = $previousWslEnv
  Remove-Item Env:FA_REPO, Env:FA_BRANCH, Env:FA_SOURCE -ErrorAction SilentlyContinue
}

## 5. Restart ##################################################################
Say 'restarting'
& wsl.exe --terminate $Name | Out-Null
Write-Host ''
Say 'done'
Write-Host "      wsl -d $Name" -ForegroundColor Yellow
Write-Host ''
