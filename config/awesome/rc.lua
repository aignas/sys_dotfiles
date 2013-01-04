-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:foldmethod=marker

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- MPD library
local mpc = require("lib/mpd").new({ hostname="localhost" })
-- Helper functions
local hfunc = require("lib/hfunc")
local acpid = require("lib/acpid")
local bim = require("lib/bim")

local kbdee = require("widgets/kbdee")
local smapi = require("widgets/smapi")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Some helper functions
-- FIXME put into a different file
modalbinds = function (keys, name, c)
    -- Debug thing
    -- if the keys table is not given stop executing the command
    if not keys then return false end

    -- from awful.key
    local ignore_modifiers = { "Lock", "Mod2" }

    -- create a new notification
    if modeNotification then naughty.destroy(modeNotification) end
    modeNotification = naughty.notify({
        title = 'Mode: ' .. (name or ""),
        text = "Press a key",
        timeout = 0
    })

    keygrabber.run(function( pressedMod, pressedKey, event)
        -- if the event is a release event or a key is a modifier, continue
        if event == "release" 
            or pressedKey:match("_Lock") 
            or pressedKey:match("_R") 
            or pressedKey:match("_L") then
            return
        end
        print(pressedKey)

        -- delete the modifiers from ignore_modifiers table
        for _,k in ipairs(pressedMod) do
            if awful.util.table.hasitem(ignore_modifiers,k) then
                pressedMod[_] = nil
            end
        end

        -- traverse the key table
        for _,k in ipairs(keys) do
            -- stop the keygrabber if no good keys were pressed
            if awful.key.match({ key = k[2], modifiers = k[1] }, pressedMod, pressedKey ) then
                -- if the continue grab option is set, continue grabbing after a
                -- press
                if k.stop_grab then 
                    keygrabber.stop()
                    if modeNotification then naughty.destroy(modeNotification) end
                end
                -- check for the type of the third argument, if it is a table,
                -- then do a recursion, if not, execute the function
                if type(k[3]) == "table" then
                    modalbinds(k[3], name .. ' (pressed ' .. k[2] .. ')', c)
                else
                    if c then k[3](c) else k[3]() end
                end
            end
        end
    end)
end

function start_once ( check, ex )
    -- error out
    if not check then return false end
    local ex = ex or check
    awful.util.spawn_with_shell('pgrep -u $USER -x ' .. check .. ' || (' .. ex .. ')')

    return true
end
-- }}}

-- {{{ Variable definitions
-- Some aliases for easier life
local home   = os.getenv("HOME")
local cfgdir = awful.util.getdir("config")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell
local docurl = "file:///usr/share/doc/awesome/luadoc/index.html"

-- Themes define colours, icons, and wallpapers
beautiful.init(cfgdir.."/themes/gns-ank/theme.lua")

-- Default application definitions.
local commands = {
    terminal = "urxvtc",
    editor = "gvim",
    browser = "firefox",
    mua = "urxvtc -e mutt",
    touchpad = 'xinput set-int-prop 13 133 8 ',
    trackpoint = 'xinput set-int-prop 14 133 8 ',
    locker = {
        start = "gnome-screensaver",
        lock = "gnome-screensaver-command -a --lock"
    },
}

local state = {
    touchpad = 0,
    trackpoint = 1,
    mic = 0,
    speakers = 1,
    bluetooth = 0,
    wifi = 1,
    camera = 0
}

-- Initialize the state of some things
-- Touchpad
sexec(commands.touchpad .. state.touchpad)
-- trackpoint
sexec(commands.trackpoint .. state.trackpoint)

--start_once('gnome-settings-daemon')
start_once('nm-applet')
start_once('skype')
start_once('gnome-screensaver')
start_once('workrave')
start_once('urxvtd')

-- Default modkey table
mod = {
    A = "Mod1",     -- Alt key
    C = "Control",  -- Control key
    S = "Shift",    -- Shift modifier
    M = "Mod4"      -- Super/Meta modifier
}


-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.max,                -- 1
    awful.layout.suit.tile,               -- 2
    awful.layout.suit.fair,               -- 3
    awful.layout.suit.fair.horizontal,    -- 4
    awful.layout.suit.floating,           -- 5
    awful.layout.suit.max.fullscreen,     -- 6
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    -- For the primary screen
    { 
        { "α", { layout = layouts[1] } },
        { "β", { layout = layouts[1] } },
        { "γ", { layout = layouts[2] } },
        { "δ", { layout = layouts[2] } },
        { "ε", { layout = layouts[2] } },
        { "ζ", { layout = layouts[2], mwfact = 0.3 } }
    },
    -- For the secondary screen
    {
        { "α", { layout = layouts[1] } },
        { "β", { layout = layouts[1] } },
        { "γ", { layout = layouts[1] } },
    }
}

-- Reformat the tags table
for s = 1, screen.count() do
    local tag = {}
    for i,k in ipairs(tags[s]) do
        table.insert(tag, i, awful.tag.add(k[1], k[2]))
        if i==1 then
            tag[i].selected = true
        end
    end

    tags[s] = tag
end
-- }}}

-- {{{ Menu
-- Default keygrabber keys
awful.menu.menu_keys = {
    up     = { "k", "v", "ж", "Up" },
    down   = { "j", "c", "ц", "Down"  },
    enter  = { "l", "p", "п", "Right" },
    exec   = { "l", "p", "п", "Right", "Return" },
    back   = { "h", "j", "й", "Left" },
    close  = { "Escape" }
}

-- Create a laucher widget and a main menu
mymenu = {}
mymenu.awesome = {
   { "&manual",         commands.terminal .. " -e man awesome" },
   { "LUA &docs",       commands.browser .. " " .. docurl },
   { "&edit config",    commands.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "awm&tt",          "awmtt start -D 2 " },
   { "&restart",        awesome.restart },
   { "&quit",           acpid.awesome_quit }
}

mymenu.docs = {
    { "&Matplotlib doc"    ,    commands.browser .. " /usr/share/doc/matplotlib-1.1.0/html/index.html" },
    { "&Matplotlib gallery",    commands.browser .. " /usr/share/doc/matplotlib-1.1.0/html/gallery.html" },
}

mymenu.main = awful.menu({ 
    items = { 
        { "a&wesome",       mymenu.awesome, beautiful.awesome_icon },
        { "---------",      nil },
        { "&Terminal",       commands.terminal .. " -e tmux" },
    },
    theme = {
        width = 130,
        --height = 20,
    }
})

-- Menubar configuration
menubar.utils.terminal = commands.terminal -- Set the terminal for applications that require it
menubar.utils.wm_name  = "GNOME"
-- }}}

-- {{{ Keyboard switching
-- configure the default layouts
kbdee.cfg.layout = {
    { "us", "dvorak" },
    { "lt", "std" },
    { "ru", "phonetic" },
    { "fr", "" },
    { "us", "" },
    { "lt", "" }
}

kbdee.cfg.setxkbmap = {
    model = "thinkpadz60"
}

kbdee.cfg.xmodmap = home .. "/.Xmodmap"

mykbdmenu = kbdee.layout.menu_gen()
mykbdwi = kbdee.new()
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock(" %d/%m/%y, %H:%M ",60)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ mod.M }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ mod.M }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

mybatterywi = smapi.new()

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylayoutbox[s])
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(mytextclock)
    -- systray is only on the first screen.
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mybatterywi)
    right_layout:add(mykbdwi)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymenu.main:toggle({keygrabber=true}) end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local mode = {}
mode.tag = {
    { {}, "Left",           awful.tag.viewprev },
    { {}, "Right",          awful.tag.viewnext },

    { {}, "j",  function ()
                    awful.client.focus.byidx( 1)
                    if client.focus then client.focus:raise() end
                end },
    { {}, "k",  function ()
                    awful.client.focus.byidx(-1)
                    if client.focus then client.focus:raise() end
                end },

    -- Layout manipulation
    { { mod.S }, "J",       function () awful.client.swap.byidx(  1) end },
    { { mod.S }, "K",       function () awful.client.swap.byidx( -1) end },
    { { mod.C }, "j",       function () awful.screen.focus_relative( 1) end },
    { { mod.C }, "k",       function () awful.screen.focus_relative(-1) end },
    { {       }, "u",       awful.client.urgent.jumpto, stop_grab = true },
 
    { {       }, "l",       function () awful.tag.incmwfact( 0.05)    end },
    { {       }, "h",       function () awful.tag.incmwfact(-0.05)    end },
    { { mod.S }, "l",       function () awful.tag.incnmaster(-1)      end },
    { { mod.S }, "h",       function () awful.tag.incnmaster( 1)      end },
    { { mod.C }, "l",       function () awful.tag.incncol(-1)         end },
    { { mod.C }, "h",       function () awful.tag.incncol( 1)         end },
    { {       }, " ",       function () awful.layout.inc(layouts,  1) end },
    { { mod.S }, " ",       function () awful.layout.inc(layouts, -1) end },
    { { mod.S }, "n",       function () awful.client.restore() end, stop_grab = true },
    { {}, "F1",             function () end, stop_grab = true }, -- Exit the mode
    { {}, "F12",            function () end, stop_grab = true }, -- Exit the mode
    { {}, "Escape",         function () end, stop_grab = true }, -- Exit the mode
    { { mod.A }, "l",       function () end, stop_grab = true }, -- Exit the mode
    { { mod.C }, "c",       function () end, stop_grab = true }  -- Exit the mode
}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({              }, "F1",       function () modalbinds (mode.tag, "tag") end),
    awful.key({              }, "F12",      function () modalbinds (mode.tag, "tag") end),

    -- Standard program
    awful.key({ mod.M        }, "Return",   function () exec(commands.terminal .. " -e tmux") end),
    awful.key({ mod.M        }, "\\",       function () exec(commands.browser) end),
    awful.key({ mod.M, mod.S }, "Return",   function () exec(commands.terminal) end),
    awful.key({ mod.M, mod.C }, "r",        function () awesome.restart() end),
    awful.key({ mod.M, mod.S }, "z",        function () acpid.awesome_quit() end),

    awful.key({ mod.M, mod.S }, "i",   function () hfunc.lua_xev() end),

    -- Menubar
    awful.key({ mod.M        }, "r", function() menubar.show() end),

    awful.key({ mod.M        }, "x",
              function ()
                  awful.prompt.run({ prompt = "Lua: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menu
    awful.key({ mod.M        }, "w", function () mymenu.main:toggle({keygrabber=true}) end),

    --[
    -- KBDee layout switching
    awful.key({ mod.S, mod.A }, "#43", function () mykbdmenu:toggle({ keygrabber = true }) end),
    awful.key({ mod.S, mod.A }, "#44", function () kbdee.layout.switch(1) end),
    awful.key({ mod.S, mod.A }, "#45", function () kbdee.layout.switch(2) end),
    awful.key({ mod.S, mod.A }, "#46", function () kbdee.layout.switch(3) end),
    awful.key({ mod.S, mod.A }, "#47", function () kbdee.layout.switch(5) end),
    --]]

    -- FIXME make it work properly. Now it just turns off.
    --[
    awful.key({ }, "XF86AudioPlay", 
        function () 
            sexec('![ pgrep mpd ] && mpd')
            mpc:toggle_play()
        end),
    awful.key({ }, "XF86AudioStop", function () mpc:stop() end),
    awful.key({ }, "XF86AudioPrev", function () mpc:previous() end),
    awful.key({ }, "XF86AudioNext", function () mpc:next() end),
    --]]
    awful.key({ }, "XF86AudioMute", 
            function () 
                local opt = '--output=alsa_output.pci-0000_00_1b.0.analog-stereo '
                sexec('ponymix ' .. opt .. 'toggle')
                hfunc.mixer.get({ 
                    cmd = 'get-volume',
                    icon = 'audio-volume-',
                    opt = opt
                })
            end),
    awful.key({ }, "XF86AudioRaiseVolume",  
            function ()
                local opt = '--output=alsa_output.pci-0000_00_1b.0.analog-stereo '
                sexec('ponymix ' .. opt .. 'increase 5')
                hfunc.mixer.get({ 
                    cmd = 'get-volume',
                    icon = 'audio-volume-',
                    opt = opt
                })
            end),
    awful.key({ }, "XF86AudioLowerVolume",  
            function ()
                local opt = '--output=alsa_output.pci-0000_00_1b.0.analog-stereo '
                sexec('ponymix ' .. opt .. 'decrease 5')
                hfunc.mixer.get({ 
                    cmd = 'get-volume',
                    icon = 'audio-volume-',
                    opt = opt
                })
            end),
    awful.key({ mod.S }, "XF86AudioRaiseVolume",  
            function ()
                local opt = '--input=alsa_input.pci-0000_00_1b.0.analog-stereo '
                sexec('ponymix ' .. opt .. 'increase 5')
                hfunc.mixer.get({ 
                    cmd = 'get-volume',
                    icon = 'microphone-sensitivity-',
                    opt = opt
                })
            end),
    awful.key({ mod.S }, "XF86AudioLowerVolume",  
            function ()
                local opt  = '--input=alsa_input.pci-0000_00_1b.0.analog-stereo '
                sexec('ponymix ' .. opt  .. 'decrease 5')
                hfunc.mixer.get({ 
                    cmd = 'get-volume',
                    icon = 'microphone-sensitivity-',
                    opt = opt
                })
            end),
    awful.key({ }, "XF86Launch2",  -- This is a remapped micmute key because of the keycode limit
            function () 
                local opt = '--input=alsa_input.pci-0000_00_1b.0.analog-stereo '
                sexec('ponymix ' .. opt .. 'toggle')
                hfunc.mixer.get({ 
                    cmd = 'get-volume',
                    icon = 'microphone-sensitivity-',
                    opt = opt
                })
            end),
    awful.key({ }, "XF86Launch1",
            function ()
                sexec("if pgrep pavucontrol; then pkill pavucontrol; else pavucontrol; fi") 
            end),

    -- ACPI
    -- Empty bindings to not have any special keys grabbed by programs.
    awful.key({ }, "XF86ScreenSaver",       function () acpid.Lock() end),   -- Fn + F2
    --awful.key({ }, "XF86Battery",           function () end),   -- Fn + F3
    awful.key({ }, "XF86Sleep",             function () acpid.Suspend("ram") end),   -- Fn + F4
    --awful.key({ }, "XF86WLAN",              function () end),   -- Fn + F5
    --FIXME: Think what to do with this button
    --awful.key({ }, "XF86WebCam",            function () end),   -- Fn + F6
    awful.key({ }, "XF86Display",
            function () 
                sexec("gnome-control-center display")
            end),   -- Fn + F7
    --FIXME: make a script
    awful.key({ }, "XF86TouchpadToggle", 
            function () 
                -- Use a simple quaternary encoding
                local s = state.touchpad * 2 + state.trackpoint

                -- Toggle the state
                s = ( s + 1 ) % 4
                -- Decode the state back
                state.trackpoint = s % 2
                state.touchpad = ( s - state.trackpoint ) / 2

                -- Toggle the devices
                sexec(commands.touchpad .. state.touchpad)
                sexec(commands.trackpoint .. state.trackpoint)

                local text = "TP  | Syn\n"
                -- Feedback
                if      s == 0 then text = text .. "Off | Off"
                elseif  s == 1 then text = text .. "On  | Off"
                elseif  s == 2 then text = text .. "Off | On "
                elseif  s == 3 then text = text .. "On  | On "
                end

                local icon = menubar.utils.lookup_icon('input-mouse')

                if touchpad_not then naughty.destroy(touchpad_not) end
                touchpad_not = naughty.notify({
                    title = "Active Mouse Device",
                    text = text,
                    icon = icon,
                    icon_size = 24,
                    timeout = 1
                })
            end),    -- Fn + F8
    awful.key({ }, "XF86Suspend",           function () acpid.Suspend("both") end),   -- Fn + F12
    awful.key({ }, "XF86MonBrightnessUp",   function () hfunc.backlight() end),
    awful.key({ }, "XF86MonBrightnessDown", function () hfunc.backlight() end)
)

mode.client = {
    -- Set client on top
    { {}, "t", function (c) c.ontop = not c.ontop end, stop_grab=true },
    -- Redraw the client
    { {}, "d", function (c) c:redraw() end, stop_grab=true },
    -- Toggle floating status of the client
    { {}, "u", awful.client.floating.toggle, stop_grab=true },
    -- make the client fullscreen
    { {}, "f", function (c) c.fullscreen = not c.fullscreen end, stop_grab=true },
    -- minimize the client
    { {}, "n", function (c) c.minimized = true end, stop_grab=true },
    -- maximize the client
    { {}, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical = not c.maximized_vertical
    end, stop_grab=true },
    -- move the client to another screen
    { {}, "o", awful.client.movetoscreen, stop_grab=true },
    -- resize the client
    { {}, "r", {
        { { mod.S }, "Up",     function (c) awful.client.moveresize( 0, 0, 0,-50, c) end },
        { { mod.S }, "Down",   function (c) awful.client.moveresize( 0, 0, 0, 50, c) end },
        { { mod.S }, "Right",  function (c) awful.client.moveresize( 0, 0, 50, 0, c) end },
        { { mod.S }, "Left",   function (c) awful.client.moveresize( 0, 0,-50, 0, c) end },
        { {}, "Up",     function (c) awful.client.moveresize( 0, 0, 0,-5, c) end },
        { {}, "Down",   function (c) awful.client.moveresize( 0, 0, 0, 5, c) end },
        { {}, "Right",  function (c) awful.client.moveresize( 0, 0, 5, 0, c) end },
        { {}, "Left",   function (c) awful.client.moveresize( 0, 0,-5, 0, c) end },
        { {}, "Escape", function (c) end, stop_grab=true }, -- Exit the mode
        { { mod.A }, "l", function (c) end, stop_grab=true }, -- Exit the mode
        { { mod.C }, "c", function (c) end, stop_grab=true }, -- Exit the mode
        }, stop_grab=true
    },
    -- move the client
    { {}, "c", {
        { { mod.S }, "Up",     function (c) awful.client.moveresize( 0,-50, 0, 0, c) end },
        { { mod.S }, "Down",   function (c) awful.client.moveresize( 0, 50, 0, 0, c) end },
        { { mod.S }, "Right",  function (c) awful.client.moveresize( 50, 0, 0, 0, c) end },
        { { mod.S }, "Left",   function (c) awful.client.moveresize(-50, 0, 0, 0, c) end },
        { {}, "Up",     function (c) awful.client.moveresize( 0,-5, 0, 0, c) end },
        { {}, "Down",   function (c) awful.client.moveresize( 0, 5, 0, 0, c) end },
        { {}, "Right",  function (c) awful.client.moveresize( 5, 0, 0, 0, c) end },
        { {}, "Left",   function (c) awful.client.moveresize(-5, 0, 0, 0, c) end },
        { {}, "Escape", function (c) end, stop_grab=true }, -- Exit the mode
        { { mod.A }, "l", function (c) end, stop_grab=true }, -- Exit the mode
        { { mod.C }, "c", function (c) end, stop_grab=true }, -- Exit the mode
        }, stop_grab=true
    },
    -- some special helper functions
    { {}, "i", function (c) hfunc.client_prop(c) end, stop_grab=true },
    { {}, "y", function (c) hfunc.client_prop_all(c) end, stop_grab=true },
    { {}, "F2", function (c) end, stop_grab = true }, -- Exit the mode
    { {}, "F11", function (c) end, stop_grab = true }, -- Exit the mode
    { {}, "Escape", function (c) end, stop_grab=true }, -- Exit the mode
    { { mod.A }, "l", function (c) end, stop_grab=true }, -- Exit the mode
    { { mod.C }, "c", function (c) end, stop_grab=true }, -- Exit the mode
}

clientkeys = awful.util.table.join(
    awful.key({ mod.M        }, "Escape", function (c) c:kill() end),

    -- Trigger client mode on mod4 + space. Perform actions on the client
    -- corresponding to the key pressed in client mode.
    -- found on https://github.com/yeban/awesomerc/
    awful.key({              }, "F2", function(c) modalbinds (mode.client, "Client", c) end),
    awful.key({              }, "F11", function(c) modalbinds (mode.client, "Client", c) end)
)

-- Compute the maximum number of digit we need, limited to 6
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(6, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ mod.M }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ mod.M, mod.C }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ mod.M, mod.S }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ mod.M, mod.C, mod.S }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ mod.M }, 1, awful.mouse.client.move),
    awful.button({ mod.M }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     keys = clientkeys,
                     focus = awful.client.focus.filter,
                     size_hints_honor = false,
                     buttons = clientbuttons,
                 } 
    },
    -- floating clients
    { rule_any = { 
        class = { "mplayer2", "fontforge" },
        instance = { "arandr", "gimp", "nitrogen", "pavucontrol", "matplotlib" }, 
        name = { "Event Tester", "Welcome to Wolfram Mathematica 8" }
    },
      properties = { floating = true } },
    -- Gnome3 stuff
    { rule = { class = "Nautilus", instance = "desktop_window" },
      properties = { sticky = true, border_width = 0, skip_taskbar = true, focus = false } },
    -- JACK stuff
    { rule = { instance = "qjackctl", name = "JACK [M-Audio-FTP]" },
      properties = { ontop = true, floating = true, sticky = true, 
                     geometry={
                         x=1100, y=20, 
                         width=340, height=100
                     } 
                   } 
    },
    -- Ardour:
    { rule = { class = "Ardour" },
      properties = { floating = true } },
    { rule = { instance = "ardour_editor" },
      properties = { floating = false, 
                     maximized_vertical = true,
                     maximized_horizontal = true } },
    -- Flash
    { rule = { class = "Plugin-container" },
      properties = { floating =  true } },
    -- Xephyr
    { rule = { instance = "Xephyr" },
        properties = { border_width = 0, floating = true } },
    -- Workrave
    { rule = { name = "Workrave", instance = "workrave", class = "Workrave" },
      properties = { ontop = true, floating = true, sticky = true } },
    { rule = { class = "Ipython"},
      properties = { floating = true, ontop = true, sticky = true } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][6] } },
    { rule = { name = "Call with", class = "Skype" },
      properties = { floating = true, ontop = true } },
    { rule = { class = "Skype", instance = "skype", name = "Options" },
      properties = { floating = true } },
    -- Web browsers and MUAs
    { rule_any = { 
        instance = { "Navigator" },
        class = { "Icecat", "Firefox", "Chromium", "luakit" }
    },
      properties = { tag = tags[screen.count()][2] } },
    { rule = { class = "Sushi-start", instance = "sushi-start" },
      properties = { floating = true, border_width = 0,
            --[[callback = function (c)
                geo = c:geometry()
                wa = screen[c.screen].workarea
                geo.x = (wa.width - geo.width)/2
                geo.y = (wa.height - geo.height)/2
                c:geometry(geo)
            end --]]
        } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][5] } },
    -- Icon defeinitions
    { rule = { instance = "urxvtc" },
      properties = { icon = menubar.utils.lookup_icon('utilities-terminal') } },
    { rule = { instance = "gvim" },
      properties = { icon = menubar.utils.lookup_icon('accessories-text-editor') } },
}
-- }}}

-- {{{ Signals

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end) -- }}}
