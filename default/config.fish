## Fish Config -> Arch
## Author: Rogerio Junior 

### EXPORT
set fish_greeting ""
set TERM xterm-256color
set EDITOR nvim
set VISUAL nvim

# Set "nvim" as manpager
set -x MANPAGER "nvim +Man!"

#### Set VI ou Emacs mode. 
function fish_user_key_bindings
    # fish_default_key_bindings
    fish_vi_key_bindings
end

### PATHS
set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/usr/bin $PATH
set -gx PATH ~/.local/bin $PATH

# Rust
set -g RUST_PATH $HOME/.cargo
set -gx PATH $RUST_PATH/bin $PATH

# Go
set -g GOPATH $HOME/.config/go
set -gx PATH $GOPATH/bin $PATH

# Emacs
set -g EMACS_PATH $HOME/.emacs.d/
set -gx PATH $EMACS_PATH/bin $PATH

### Functions

# Function for creating a backup file
function bk --argument filename
    cp $filename $filename.bak
end

# Yazi Function
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

### Aliases ###
## Editors ##
# Helix
alias h="helix"
alias hx="helix"

# Neovim
alias v="nvim"
alias vi="nvim"

# Emacs
alias emacs="emacsclient -c -a 'emacs'"
alias em='/usr/bin/emacs -nw'
alias rem="killall emacs || echo 'Emacs server not running'; /usr/bin/emacs --daemon"

## File Managers ##
# Yazi
alias yz="yazi"

## Directories ##
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Changing "ls" to "eza"
alias ls='eza --color=always --icons=always'
alias la='eza -a --color=always --group-directories-first --icons=always' # all files and dirs
alias ll='eza -al --color=always --group-directories-first --icons=always' # long format
alias l.='eza -al --color=always --group-directories-first ../ --icons=always' # ls on the PARENT directory
alias l..='eza -al --color=always --group-directories-first ../../ --icons=always' # ls on directory 2 levels up
alias l...='eza -al --color=always --group-directories-first ../../../ --icons=always' # ls on directory 3 levels up

## Package managers ##
# Pacman
alias pacsyu='sudo pacman -Syu'
alias pacsyyu='sudo pacman -Syyu'
alias unlock='sudo rm /var/lib/pacman/db.lck' # remove pacman lock

# Paru
alias parsua='paru -Sua --noconfirm'
alias parsyu='paru -Syu --noconfirm'

# Yay
alias yaysyu='yay -Syu --noconfirm'

## Tools ##
# Git
alias gaddall='git add .'
alias gadd='git add -u'
alias gcheckout='git checkout'
alias gclone='git clone'
alias gcommit='git commit -m'
alias gpull='git pull origin'
alias gpush='git push origin'
alias gbranch='git branch'

# Mise
alias ms="mise"
alias msr="mise run"
alias msup="mise upgrade"
alias msu="mise use"
alias msi="mise install"

# Zellij
alias zlj="zellij"
alias zljs="zellij -s"
alias zlsa="zellij a"
alias zljds="zellij delete-all-sessions"

# TaskWarrior
alias t='task'
alias ta='task add'
alias td='task done'
alias tn='task next'
alias tl='task list'
alias tdaily='~/.scripts/bash/task_scripts/daily_task_report.sh'
alias tweekly='~/.scripts/bash/task_scripts/weeky_task_report.sh'
alias taskui="taskwarrior-tui"

### Utils ###
# change default USER shell
alias tobash="chsh $USER -s /usr/bin/bash && echo 'Log out and log back in for change to take effect.'"
alias tozsh="chsh $USER -s /usr/bin/zsh && echo 'Log out and log back in for change to take effect.'"
alias tofish="chsh $USER -s /usr/bin/fish && echo 'Log out and log back in for change to take effect.'"
alias tonu="chsh $USER -s /usr/bin/nu && echo 'Log out and log back in for change to take effect.'"

# alias chmod commands
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Rickroll
alias rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'

### Init ###
## Starship
starship init fish | source

## Zoxide
zoxide init fish | source

## Mise
mise activate fish | source

## Atuin
atuin init fish | source

## SSH
eval (ssh-agent -c)
