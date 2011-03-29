#!/bin/sh 
# 
# ~/.xinitrc 
# 
# Executed by startx (run your window manager from here) 
export SAGE_BROWSER=/usr/bin/chromium
export BROWSER=/usr/bin/chromium

# Write down the command to execute your default session
DEFAULT_SESSION="awesome"

case $1 in
awesome-def)
	SESSION="awesome -c /etc/xdg/awesome/rc.lua"
	;;
awesome)
        SESSION="awesome"
	;;
      *)
        SESSION=${DEFAULT_SESSION}
        ;;
esac

# this ensures that everything goes to a file .xsession-errors
exec dbus-launch ck-launch-session ${SESSION} > ~/.xsession-errors 2>&1
