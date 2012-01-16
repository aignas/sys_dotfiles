#!/bin/sh 
#
# .profile
#
# This file should be executed by the DM

. ${HOME}/.scripts/set-env

startup()
{
  if ps -A | grep -q $1; then
    echo "$1 is already running"
  else
    `$@` &
    notify-send "$1"
  fi
}


# Keyboard
setxkbmap gb
xset +dpms 

startup "workrave"
