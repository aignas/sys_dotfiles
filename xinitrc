#!/bin/sh 
# 
# ~/.xinitrc 
# 
# Executed by startx (run your window manager from here) 
# Keyboard
setxkbmap gb -model thinkpad -option caps:super 
xmodmap ~/.Xmodmap 
# make use of v4l2 stuff 
export LD_PRELOAD=/usr/lib/libv4l/v4l2convert.so 
# Touchpad off 
synclient TouchpadOff=1 

# Trackpoint settings 
# Enable scrolling 

#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
#xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5

# Write down the command to execute your default session
DEFAULT_SESSION="awesome"

case $1 in
awesome-def)
	SESSION="awesome -c /etc/xdg/awesome/rc.lua"
	;;
awesome-shifty)
	SESSION="awesome -c ~/.config/shifty.rc.lua"
	;;
awesome)
        SESSION="awesome"
	;;
      *)
        SESSION=${DEFAULT_SESSION}
        ;;
esac

# this ensures that everything goes to a file .xsession-errors
exec $SESSION > ~/.xsession-errors 2>&1
