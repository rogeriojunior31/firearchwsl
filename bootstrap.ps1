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
  5. Installs CaskaydiaMono Nerd Font for the Windows user and adds a
     "FireArch (<distro>)" Windows Terminal profile (font + Tokyo Night).
     Both per user, no admin; -NoFont / -NoTerminal skip them.
  6. Restarts the distro so the new default user, groups and hostname apply.

  Every FIREARCH_* variable set in this PowerShell session (plus FORCE_CONFIG
  and DISABLE_CHAOTIC) is forwarded to the installer, so unattended runs work:
    $env:FIREARCH_USER = 'jane'; $env:FIREARCH_PASSWORD = '...'; .\bootstrap.ps1 -Yes

.EXAMPLE
  irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/main/bootstrap.ps1 | iex

.EXAMPLE
  $env:FIREARCH_BRANCH = 'my-branch'; irm https://raw.githubusercontent.com/rogeriojunior31/firearchwsl/my-branch/bootstrap.ps1 | iex

.EXAMPLE
  .\bootstrap.ps1 -Name archdev -Branch my-branch

.EXAMPLE
  .\bootstrap.ps1 -Source .     # use this local checkout instead of cloning
#>
[CmdletBinding()]
param(
  # WSL distro name to install into / create. `irm | iex` cannot pass
  # parameters, so these three also read FIREARCH_DISTRO / _REPO / _BRANCH.
  [string]$Name = $(if ($env:FIREARCH_DISTRO) { $env:FIREARCH_DISTRO } else { 'archlinux' }),
  # Git repository and branch to clone.
  [string]$Repo = $(if ($env:FIREARCH_REPO) { $env:FIREARCH_REPO } else { 'https://github.com/rogeriojunior31/firearchwsl.git' }),
  [string]$Branch = $(if ($env:FIREARCH_BRANCH) { $env:FIREARCH_BRANCH } else { 'main' }),
  # Local checkout to copy instead of cloning (Windows path).
  [string]$Source,
  # Skip the installer's final confirmation (install.sh --yes).
  [switch]$Yes,
  # Raw command output instead of spinners (install.sh --verbose).
  [switch]$VerboseInstall,
  # Do not install the Nerd Font (also FIREARCH_NO_FONT=1).
  [switch]$NoFont,
  # Do not add the Windows Terminal profile (also FIREARCH_NO_TERMINAL=1).
  [switch]$NoTerminal
)
if ($env:FIREARCH_NO_FONT -eq '1') { $NoFont = $true }
if ($env:FIREARCH_NO_TERMINAL -eq '1') { $NoTerminal = $true }

$ErrorActionPreference = 'Stop'
# wsl.exe writes UTF-16 by default; this makes its output readable.
$env:WSL_UTF8 = '1'

## Messages ###################################################################
# The installer itself is fully translated; these are only the few lines the
# bootstrap prints before it starts.
# This file must stay pure ASCII without a BOM: `irm | iex` keeps a BOM as a
# U+FEFF character that breaks parsing, and Windows PowerShell 5.1 reads a
# BOM-less file as ANSI. Non-ASCII characters are written as \uXXXX escapes
# and decoded by Msg.
$lang = $env:FIREARCH_LANG
if (-not $lang) { if ((Get-Culture).Name -like 'pt*') { $lang = 'pt_BR' } else { $lang = 'en' } }
$messages = @{
  en    = @{
    noWsl      = 'WSL is not available. Install it first (as administrator):  wsl --install --no-distribution'
    installing = 'Installing the Arch Linux distro as "{0}"...'
    installFail = 'Could not install the distro (wsl --install exit {0}).'
    exists     = 'Distro "{0}" already exists \u2014 using it.'
    fetching   = 'Fetching firearchwsl into /opt/firearchwsl...'
    fetchFail  = 'Could not fetch firearchwsl (exit {0}).'
    running    = 'Starting the installer...'
    runFail    = 'The installer stopped (exit {0}). Fix the problem and run this script again \u2014 it is safe to re-run.'
    restarting = 'Restarting the distro so the new settings apply...'
    done       = 'Done! Open your new environment with:'
    fontExists = '{0} is already installed.'
    fontInstalling = 'Installing {0} for your Windows user (prompt icons)...'
    fontDone   = '{0} installed.'
    fontFail   = 'Could not install the Nerd Font ({0}). The prompt icons may look like boxes.'
    wtMissing  = 'Windows Terminal not found \u2014 skipping its profile.'
    wtDone     = 'Windows Terminal profile "{0}" added (Nerd Font + Tokyo Night). Reopen Windows Terminal and pick it in the tab menu.'
    wtFail     = 'Could not write the Windows Terminal profile ({0}).'
  }
  pt_BR = @{
    noWsl      = 'O WSL n\u00e3o est\u00e1 dispon\u00edvel. Instale primeiro (como administrador):  wsl --install --no-distribution'
    installing = 'Instalando a distro Arch Linux como "{0}"...'
    installFail = 'N\u00e3o foi poss\u00edvel instalar a distro (wsl --install saiu com {0}).'
    exists     = 'A distro "{0}" j\u00e1 existe \u2014 usando ela.'
    fetching   = 'Baixando o firearchwsl para /opt/firearchwsl...'
    fetchFail  = 'N\u00e3o foi poss\u00edvel baixar o firearchwsl (sa\u00edda {0}).'
    running    = 'Iniciando o instalador...'
    runFail    = 'O instalador parou (sa\u00edda {0}). Corrija o problema e rode este script de novo \u2014 \u00e9 seguro repetir.'
    restarting = 'Reiniciando a distro para as novas configura\u00e7\u00f5es valerem...'
    done       = 'Pronto! Abra o seu novo ambiente com:'
    fontExists = 'A {0} j\u00e1 est\u00e1 instalada.'
    fontInstalling = 'Instalando a {0} para o seu usu\u00e1rio do Windows (\u00edcones do prompt)...'
    fontDone   = '{0} instalada.'
    fontFail   = 'N\u00e3o foi poss\u00edvel instalar a Nerd Font ({0}). Os \u00edcones do prompt podem aparecer como quadrados.'
    wtMissing  = 'Windows Terminal n\u00e3o encontrado \u2014 pulando o perfil.'
    wtDone     = 'Perfil "{0}" criado no Windows Terminal (Nerd Font + Tokyo Night). Reabra o Windows Terminal e escolha ele no menu de abas.'
    wtFail     = 'N\u00e3o foi poss\u00edvel gravar o perfil do Windows Terminal ({0}).'
  }
}
if (-not $messages.ContainsKey($lang)) { $lang = 'en' }
function Msg([string]$key, $arg) { [regex]::Unescape($messages[$lang][$key]) -f $arg }
function Say([string]$key, $arg) {
  Write-Host "  $([char]0x2022) $(Msg $key $arg)" -ForegroundColor DarkYellow
}
function Warn([string]$key, $arg) {
  Write-Host "  $([char]0x26A0) $(Msg $key $arg)" -ForegroundColor Yellow
}
function Fail([string]$key, $arg) {
  Write-Host "  $([char]0x2716) $(Msg $key $arg)" -ForegroundColor Red
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
# translates a Windows path), and the script itself as base64 - nothing is
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
  # A checkout with local changes (e.g. an earlier -Source copy) is moved
  # aside, never overwritten.
  if [[ -d "$dest/.git" && -n "$(git -C "$dest" status --porcelain 2>/dev/null)" ]]; then
    backup="$dest.bak-$(date +%Y%m%d-%H%M%S)"
    mv "$dest" "$backup"
    echo "  local changes kept in $backup"
  fi
  if [[ -d "$dest/.git" ]]; then
    # The checkout may come from an earlier -Source copy (origin = the
    # developer's SSH remote) or another -Repo: always fetch from -Repo.
    git -C "$dest" remote set-url origin "$FA_REPO" 2>/dev/null ||
      git -C "$dest" remote add origin "$FA_REPO"
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

## 5. Nerd Font and Windows Terminal ##########################################
# Both per user, no administrator rights: the font goes to
# %LOCALAPPDATA%\Microsoft\Windows\Fonts (registered under HKCU) and the
# terminal profile is a JSON fragment, so settings.json is never touched.
$fontFamily = 'CaskaydiaMono Nerd Font'
$fontBaseUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono'

function Test-FontInstalled {
  foreach ($key in @('HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts',
      'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts')) {
    $props = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
    if ($props -and ($props.PSObject.Properties.Name | Where-Object { $_ -like "$fontFamily*" })) { return $true }
  }
  return $false
}

function Install-NerdFont {
  if (Test-FontInstalled) { Say 'fontExists' $fontFamily; return $true }
  Say 'fontInstalling' $fontFamily
  $tmp = Join-Path $env:TEMP ('firearchwsl-font-' + [guid]::NewGuid())
  $previousProgress = $ProgressPreference
  try {
    # 5.1 progress bars make downloads crawl; older defaults lack TLS 1.2.
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    New-Item -ItemType Directory -Path $tmp | Out-Null
    # The .tar.xz is 3.5 MB, the .zip 56 MB: use the small one whenever the
    # built-in tar.exe (Windows 11) can unpack xz.
    $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
    $xz = (Test-Path $tar) -and ((& $tar --version 2>$null) -match 'liblzma')
    if ($xz) {
      $archive = Join-Path $tmp 'font.tar.xz'
      Invoke-WebRequest -UseBasicParsing -Uri "$fontBaseUrl.tar.xz" -OutFile $archive
      & $tar -xf $archive -C $tmp
      if ($LASTEXITCODE -ne 0) { throw "tar exit $LASTEXITCODE" }
    } else {
      $archive = Join-Path $tmp 'font.zip'
      Invoke-WebRequest -UseBasicParsing -Uri "$fontBaseUrl.zip" -OutFile $archive
      Expand-Archive -Path $archive -DestinationPath $tmp -Force
    }
    $dest = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
    $fontsKey = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    if (-not (Test-Path $fontsKey)) { New-Item -Path $fontsKey -Force | Out-Null }
    # "CaskaydiaMonoNerdFont-<Style>.ttf": the Mono/Propo variants are left out.
    Get-ChildItem -Path $tmp -Recurse -Filter 'CaskaydiaMonoNerdFont-*.ttf' | ForEach-Object {
      $target = Join-Path $dest $_.Name
      Copy-Item -LiteralPath $_.FullName -Destination $target -Force
      $style = ($_.BaseName -split '-', 2)[1]
      New-ItemProperty -Path $fontsKey -Name "$fontFamily $style (TrueType)" -Value $target -PropertyType String -Force | Out-Null
    }
    Say 'fontDone' $fontFamily
    return $true
  } catch {
    Warn 'fontFail' $_.Exception.Message
    return $false
  } finally {
    $ProgressPreference = $previousProgress
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Install-TerminalProfile([bool]$withFont) {
  if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) { Say 'wtMissing'; return }
  $profileName = "FireArch ($Name)"
  try {
    $dir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\firearchwsl'
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    # A missing font face makes Windows Terminal complain: only when installed.
    $font = ''
    if ($withFont) { $font = "`n      `"font`": { `"face`": `"$fontFamily`", `"size`": 11 }," }
    # The icon is the fire emoji as a JSON escape: this file stays ASCII.
    $json = @"
{
  "profiles": [
    {
      "name": "$profileName",
      "commandline": "wsl.exe -d $Name --cd ~",
      "icon": "\ud83d\udd25",$font
      "colorScheme": "firearchwsl Tokyo Night"
    }
  ],
  "schemes": [
    {
      "name": "firearchwsl Tokyo Night",
      "background": "#1A1B26", "foreground": "#C0CAF5",
      "cursorColor": "#C0CAF5", "selectionBackground": "#33467C",
      "black": "#15161E", "red": "#F7768E", "green": "#9ECE6A", "yellow": "#E0AF68",
      "blue": "#7AA2F7", "purple": "#BB9AF7", "cyan": "#7DCFFF", "white": "#A9B1D6",
      "brightBlack": "#414868", "brightRed": "#F7768E", "brightGreen": "#9ECE6A",
      "brightYellow": "#E0AF68", "brightBlue": "#7AA2F7", "brightPurple": "#BB9AF7",
      "brightCyan": "#7DCFFF", "brightWhite": "#C0CAF5"
    }
  ]
}
"@
    [IO.File]::WriteAllText((Join-Path $dir "$Name.json"), ($json -replace "`r`n", "`n"), (New-Object Text.UTF8Encoding $false))
    Say 'wtDone' $profileName
  } catch {
    Warn 'wtFail' $_.Exception.Message
  }
}

$fontReady = $false
if (-not $NoFont) { $fontReady = Install-NerdFont } elseif (Test-FontInstalled) { $fontReady = $true }
if (-not $NoTerminal) { Install-TerminalProfile $fontReady }

## 6. Restart ##################################################################
Say 'restarting'
& wsl.exe --terminate $Name | Out-Null
Write-Host ''
Say 'done'
Write-Host "      wsl -d $Name" -ForegroundColor Yellow
Write-Host ''
