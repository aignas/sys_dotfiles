# My zshrc configuration. Use or reuse however you like.
#       by gns-ank

setopt CORRECT					# command CORRECTION
setopt EXTENDED_HISTORY		# puts timestamps in history

# set environmental variables
if [[ -f ~/bin/set-env ]]; then
    . ${HOME}/bin/set-env
fi

# Make zsh-git work
fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

# source the aliases
if [[ -f ~/.zsh/aliases ]]; then
	. ~/.zsh/aliases
fi

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

setopt promptsubst

# Load the prompt theme system
autoload -U promptinit; promptinit
autoload -U compinit; compinit

# Use the otype prompt theme
prompt gns-ank

############################## Keybindings #####################################
bindkey -v      # vim keybinding mode
bindkey '\e[A'  history-beginning-search-backward
bindkey '\e[B'  history-beginning-search-forward
bindkey '^?'    backward-delete-char
bindkey '^[OH~' vi-beginning-of-line
bindkey '^[OF~' vi-end-of-line
bindkey '^[[3~' vi-delete-char
bindkey '^[3;5~' vi-delete-char
bindkey '^[.'   insert-last-word

# vim tw=80
