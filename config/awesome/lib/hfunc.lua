-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment
local awful = require('awful')
local naughty = require('naughty')
local capi = {
    keygrabber = keygrabber,
    client = client,
    awesome = awesome
}

local ipairs = ipairs
local print = print
local type = type
local os = os

local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell
local function ssexec (args)
    if type(args)=="string" then
        sexec(os.getenv("HOME").."/.scripts/"..args)
        return 0
    end
    return 1
end
--}}}

module('hfunc')

--- {{{ Function definitions
-- Client info
function client_prop(c) 
    if prop_notif then naughty.destroy(prop_notif) end
    local f = function (prop, str) 
        local _string = ""
        if prop and str then
            _string = str
            .. ((type(prop)=="boolean") and "" or (" = " .. prop)) 
            .. "\n"
        else
            _string = ""
        end
        print(_string)
        return _string
    end 
        
    prop_notif = naughty.notify({ 
        title = "Client info", 
        text = "" 
        .. f(c.class, "class") 
        .. f(c.instance, "instance") 
        .. f(c.name, "name") 
        .. f(c.type, "type") 
        .. f(c.role, "role") 
        .. f(c.pid, "pid") 
        .. f(c.window, "window_id") 
        .. f(c.machine, "machine") 
        .. f(c.skip_taskbar, "skip taskbar") 
        .. f(c.floating, "floating") 
        .. f(c.minimized, "minimized") 
        .. f(c.maximized_horizontal, "maximized horizontal") 
        .. f(c.maximized_vertical, "maximized vertical") 
    }) 
end 

-- xev alternative in lua
function lua_xev()
    local notif = naughty.notify({title = "Key Pressed", text = "", timeout=0})
    capi.keygrabber.run(
    function(modifiers, key, event)
        local mod_t = {}
        local mod = ""
        if notif then naughty.destroy(notif) end
        for k, v in ipairs(modifiers) do mod_t[v] = true; mod = mod..v..";" end
        if mod_t.Control and key == "c" then
            return false
        end
        notif = naughty.notify({title = "Key Pressed", text = "Modifier = "..mod.."\n key - "..key.."\n"..event, timeout=0})
        return true
    end)
end

-- quit awesome
local fun = {}
function awesome_quit ()
    local b_halt,b_sleep,b_reboot,b_hib,b_log
    local quit_not = naughty.notify({title = "What would you like to do?",
        text = ""
        .. "1. "
        .. "(L)og out"
        .. "\n2. "
        .. "(H)alt"
        .. "\n3. "
        .. "(R)estart"
        .. "\n4. "
        .. "(S)uspend to Ram"
        .. "\n5. "
        .. "Suspend to (D)isk"
        .. "",
        timeout = 0 })
    capi.keygrabber.run(
    function(modifiers, key, event)
        local mod_t = {}
        local mod = ""
        for k, v in ipairs(modifiers) do mod_t[v] = true; mod = mod..v..";" end
        if event == "release"
          or key:find("Shift") then
          return true 
        end
        if key == "1" 
            or key == "l"
            or key == "L" then
            -- logout
            capi.awesome.quit()
        elseif key == "2"
            or key == "h"
            or key == "H" then
            -- Halt (aka shutdown)
            ssexec("dbus-halt")
        elseif key == "3"
            or key == "r"
            or key == "R" then
            -- Restart the machine
            ssexec("dbus-reboot")
        elseif key == "4"
            or key == "s"
            or key == "S" then
            -- Suspend to RAM (aka Sleep)
            --acpid-sleep
        elseif key == "5"
            or key == "d"
            or key == "D" then
            -- Suspend to Disk (aka Hibernate)
            --acpid-2disk
        end
        naughty.destroy(quit_not)
        return false
    end)
end

-- volume feedback
local vol_not
function volume_feed (args)
    title = args.title or ""
    text = args.text or ""
    naughty.destroy(vol_not)
    vol_not = naughty.notify({ args.title,
                     text  = text,
                     timeout = 0 })
end

---}}}
