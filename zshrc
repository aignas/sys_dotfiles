# Created by newuser for 4.3.10

# completion
autoload -U compinit 
compinit

# correction
#setopt correctall

# prompt
autoload -U promptinit
promptinit

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

function dae () {
  if [ "x$1"!="x" -a "$1"!="start" -a "$1"!="restart" \
    -a "$1"!="stop" -a "x$2"!="x" ]; then
      sudo /etc/rc.d/${1} ${2}
  else
    echo 'Error: Parameters are invalid.'
  fi
}

function ranger() {
  command ranger --fail-unless-cd $@ &&
    cd "$(grep \^\' ~/.config/ranger/bookmarks | cut -b3-)"
}

# truncated directory
local prmpt_j="%F{red}%B%(1j.[%j] .)%b%f"
local prmpt_d="[%B%(!.%F{red}.%F{yellow})%20<...<%d%<<%f%b]"
local prmpt_s="%B%(!.%F{red}#%f.%F{purple}$%f%b) "
local prmpt_n="%(!.%B%n@%m%b.%F{green}%n@%U%m%u)%f"
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
    echo -en "\e]P01e2320" # zenburn black (normal black)
    echo -en "\e]P8709080" # bright-black  (darkgrey)
    echo -en "\e]P1705050" # red           (darkred)
    echo -en "\e]P9dca3a3" # bright-red    (red)
    echo -en "\e]P260b48a" # green         (darkgreen)
    echo -en "\e]PAc3bf9f" # bright-green  (green)
    echo -en "\e]P3dfaf8f" # yellow        (brown)
    echo -en "\e]PBf0dfaf" # bright-yellow (yellow)
    echo -en "\e]P4506070" # blue          (darkblue)
    echo -en "\e]PC94bff3" # bright-blue   (blue)
    echo -en "\e]P5dc8cc3" # purple        (darkmagenta)
    echo -en "\e]PDec93d3" # bright-purple (magenta)
    echo -en "\e]P68cd0d3" # cyan          (darkcyan)
    echo -en "\e]PE93e0e3" # bright-cyan   (cyan)
    echo -en "\e]P7dcdccc" # white         (lightgrey)
    echo -en "\e]PFffffff" # bright-white  (white)
    export PROMPT="%B%(?..[%?] )%b${prmpt_j}${prmpt_d}${prmpt_s}"
    export RPROMPT="%(!.%b%F{red}.)${prmpt_n}${prmpt_t}"
    ;;
  *)
    export PROMPT="%B%(?..[%?] )%b${prmpt_j}${prmpt_d}${prmpt_s}"
    export RPROMPT="%(!.%b%F{red}.)${prmpt_n}${prmpt_t}"
    ;;
esac

prompt_opts=(cr percent)

# vim mode and key bindings
export EDITOR=/usr/bin/vim
bindkey -v
bindkey '\e[A'  history-beginning-search-backward
bindkey '\e[B'  history-beginning-search-forward
bindkey '^?'     backward-delete-char
bindkey '^[[3~'          vi-delete-char
bindkey '^[3;5~'         vi-delete-char

# Normal aliases
alias visudo='sudo -E EDITOR=vim visudo'

alias ls='ls --color=auto -F'
alias lsd='ls --color=auto -d *(-/DN)'
alias lsa='ls --color=auto -d .*'
alias ll='ls --color=auto -Fl'
alias lld='ls --color=auto -dl *(-/DN)'
alias lla='ls --color=auto -dl .*'

alias ..='cd ..'

alias cdaw='cd ~/.config/awesome'
alias cdawl='cd /usr/share/awesome/lib'

alias s='sudo -E'
alias ss='sudo -Es'
alias v='vim'
alias gv='gvim'
alias sv='sudo -E vim'

alias r='ranger'
alias t='urxvt &!'
alias tt='urxvt &! urxvt &!'

# Package managment aliases
alias p='pacman'
alias sp='sudo pacman'
alias c='cower'

#sufix aliases
alias -s pdf=zathura

#pulseaudio stuff
if ! ( ps -A | grep X && ps -A |grep pulseaudio || ps -A | grep pulseaudio ) > /dev/null
then
  pulseaudio -D
fi

xset -b
