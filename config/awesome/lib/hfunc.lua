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
    local quit_not = naughty.notify({title = "Are you sure you want to quit?",
        text = "Press Y/y to quit or any other key to cancel",
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
        if key == "y" or key == "Y" then
          capi.awesome.quit()
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
