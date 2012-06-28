#!/bin/sh 
#
# .profile
#
# This file should be executed by the DM

# set the environmental variables correctly
. ${HOME}/.scripts/set-env

startup()
{
  if ps -A | grep -q "$1"; then
    echo "$1 is already running"
    return 0
  fi
  if [ ! -z $2 ]; then
    shift
  fi

  `$@` &
}


# Xsettings
xset +dpms 

# Startup programs
startup kbdd
startup workrave
startup nm-applet
startup polkit-gnome "/usr/libexec/polkit-gnome-authentication-agent-1"
#startup unagi
