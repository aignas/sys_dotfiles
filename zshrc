# My zshrc
#       by gns-ank

# completion and prompt 
autoload -U compinit 
autoload -U promptinit
promptinit
compinit

# set environmental variables
. ${HOME}/.scripts/set-env

# {{{ Manual pages
#     - colorize, since man-db fails to do so
export LESS_TERMCAP_mb=$'\E[01;31m'   # begin blinking
export LESS_TERMCAP_md=$'\E[01;31m'   # begin bold
export LESS_TERMCAP_me=$'\E[0m'       # end mode
export LESS_TERMCAP_se=$'\E[0m'       # end standout-mode
export LESS_TERMCAP_so=$'\E[1;33;40m' # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'       # end underline
export LESS_TERMCAP_us=$'\E[1;32m'    # begin underline
# }}}

# extract files in a good way :)
function extract () {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tbz2 | *.tar.bz2) tar -xvjf  "$1"     ;;
      *.txz | *.tar.xz)   tar -xvJf  "$1"     ;;
      *.tgz | *.tar.gz)   tar -xvzf  "$1"     ;;
      *.tar | *.cbt)      tar -xvf   "$1"     ;;
      *.zip | *.cbz)      unzip      "$1"     ;;
      *.rar | *.cbr)      unrar x    "$1"     ;;
      *.arj)              unarj x    "$1"     ;;
      *.ace)              unace x    "$1"     ;;
      *.bz2)              bunzip2    "$1"     ;;
      *.xz)               unxz       "$1"     ;;
      *.gz)               gunzip     "$1"     ;;
      *.7z)               7z x       "$1"     ;;
      *.Z)                uncompress "$1"     ;;
      *.gpg)       gpg2 -d "$1" | tar -xvzf - ;;
      *) echo 'Error: failed to extract "$1"' ;;
    esac
  else
    echo 'Error: "$1" is not a valid file for extraction'
  fi
}

function ranger() {
  command ranger --fail-unless-cd $@ &&
    cd "$(grep \^\' ~/.config/ranger/bookmarks | cut -b3-)"
}

# truncated directory
local prmpt_j="%F{red}%B%(1j.[%j] .)%b%f"
local prmpt_d="%B%F{yellow}%30<...<%d%<<%f%b"
local prmpt_s="%(!.%F{red}.%F{green})%B%(!.#.$%b)%f "
local prmpt_n="%(!.%B%F{red}.%F{green})%n%f%b at %F{green}%m%f"
local prmpt_t="[%F{green}%T%f]"

precmd () (
    #Other commands
    #highlight after a finished command
    echo -ne '\a'
)

# Customized promt which at first was derived from Walters prompt
case "${TERM}" in
  dumb)
    export PROMPT="%D{%H:%M}-%(?..[%?] )%n@%m:%~> "
    ;;
  linux)
    export PROMPT="${prmpt_j}${prmpt_d} on ${prmpt_n}
${prmpt_s}%B%(?..[%?] )%b"
    export RPROMPT=""
    # Path stuff
    PATH=$PATH:${HOME}/bin:/opt/ChemAxon/MarvinBeans/bin/
    export PATH
    ;;
  *)
#   export PROMPT="%B%(?..[%?] )%b${prmpt_j}${prmpt_d}${prmpt_s}"
#   export RPROMPT="%(!.%b%F{red}.)${prmpt_n}${prmpt_t}"
    export PROMPT="${prmpt_j}${prmpt_d} on ${prmpt_n}
${prmpt_s}%B%(?..[%?] )%b"
    export RPROMPT=""
    ;;
esac

prompt_opts=(cr percent)

# vim mode and key bindings
bindkey -v
bindkey '\e[A'  history-beginning-search-backward
bindkey '\e[B'  history-beginning-search-forward
bindkey '^?'     backward-delete-char
bindkey '^[[7~' vi-beginning-of-line
bindkey '^[[1~' vi-beginning-of-line
bindkey '^[[8~' vi-end-of-line
bindkey '^[[4~' vi-end-of-line
bindkey '^[[3~'          vi-delete-char
bindkey '^[3;5~'         vi-delete-char
bindkey '^[.'   insert-last-word

# Normal aliases
alias visudo='sudo -E EDITOR=vim visudo'

alias ls='ls --color=auto -FX'
alias lsd='ls --color=auto -dX *(-/DN)'
alias lsa='ls --color=auto -dX .*'
alias ll='ls --color=auto -FlhX'
alias lld='ls --color=auto -dlhX *(-/DN)'
alias lla='ls --color=auto -dlhX .*'

alias ..='cd ..'

alias cdc='cd ~/.config/'
alias cdaw='cd ~/.config/awesome'
alias cdawl='cd /usr/share/awesome/lib'

function mkcd() {
    mkdir $1
    cd $1
}

alias s='sudo -E'
alias ss='sudo -Es'
alias v='vim'
alias gv='gvim'
alias sv='sudo -E vim'

alias r='ranger'
alias t='tmux -u'

#sufix aliases
alias -s pdf=mupdf
