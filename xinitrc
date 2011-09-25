#!/bin/sh 
# 
# ~/.xinitrc 
# 
# Executed by startx (run your window manager from here) 
export BROWSER=/usr/bin/icecat
export SAGE_BROWSER=$BROWSER
export PDFVIEWER=/usr/bin/mupdf
#export PDFVIEWER=/usr/bin/zathura
export XDG_MAILER=/usr/bin/thunderbird
export MAILER=$XDG_MAILER
export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on'

# Path stuff
PATH=$PATH:${HOME}/bin:/opt/ChemAxon/MarvinBeans/bin/
export PATH

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
exec dbus-launch ck-launch-session ${SESSION} # > ~/.xsession-errors 2>&1
