-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment
local awful = require('awful')
local naughty = require('naughty')
local utils = require('menubar.utils')
local capi = {
    keygrabber = keygrabber,
    client = client,
    awesome = awesome
}

local ipairs = ipairs
local pairs = pairs
local print = print
local type = type
local os = os
local socket = socket

local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell
--}}}

local hfunc = { }

--- {{{ Function definitions
-- Client info
function hfunc.client_prop(c) 
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
function hfunc.lua_xev()
    local notif = naughty.notify({title = "Key Pressed", text = "", timeout=0})
    capi.keygrabber.run(
    function(modifiers, key, event)
        local mod_t = {}
        local mod = ""
        for k, v in ipairs(modifiers) do mod_t[v] = true; mod = mod..v..";" end
        if notif then naughty.destroy(notif) end
        notif = naughty.notify({
            title = "Key " .. event, 
            text = "Modifier = "..mod.."\nkey - "..key, timeout=0})
        if mod_t.Control and key == "c" then
            if notif then naughty.destroy(notif) end
            capi.keygrabber.stop()
        end
    end)
end

-- volume feedback
local osd_not
hfunc.mixer = {}

function hfunc.mixer.get (args)
    local cmd = args.cmd or ''
    local icon = args.icon or 'audio-volume-'
    local opt = args.opt or ''

    local file = assert(io.popen('ponymix ' .. opt .. cmd))
    local output = file:read()
    file:close()

    local file = assert(io.popen('ponymix ' .. opt .. 'is-muted'))
    local state = file:close()

    -- Setting the icon
    if state then
        icon = icon .. 'muted'
        output = 'mutted'
    elseif tonumber(output) < 33 then
        icon = icon .. "low"
    elseif tonumber(output) < 66 then
        icon = icon .. "medium"
    else
        icon = icon .. "high"
    end
    icon = utils.lookup_icon(icon)

    if osd_not then naughty.destroy(osd_not) end
    osd_not = naughty.notify({
        title = "PulseAudio Volume",
        text = 'Volume level: ' .. output,
        icon = icon,
        icon_size = 24,
        timeout = 1
    })
end

function hfunc.mixer.change ()
    -- FIXME

    return true
end

-- backlight
function hfunc.backlight()
    local dir = '/sys/class/backlight/intel_backlight/'
    local file = assert(io.open(dir .. 'max_brightness'))
    local max = file:read()
    file:close()

    local file = assert(io.open(dir .. 'actual_brightness'))
    local current = file:read()
    file:close()

    local function round(what, precision)
        return math.floor(what*math.pow(10,precision)+0.5) / math.pow(10,precision)
    end

    -- Feedback
    local text = "Brightness: " .. round(current/max*100, 0)

    local icon = utils.lookup_icon('display-brightness-symbolic')

    if osd_not then naughty.destroy(osd_not) end
    osd_not = naughty.notify({
        title = "Brightness",
        text = text,
        icon = icon,
        icon_size = 24,
        timeout = 1
    })
end

-- mounter
function hfunc.lua_mount()
    local cliname = ""
    awful.prompt.run({ prompt = "Enter Client Name: " },
    mypromptbox[mouse.screen].widget,
    function(...)
        naughty.notify({text=unpack(arg)})
        c:name(unpack(arg))
    end,nil)
end

-- Check config in Xephyr
function hfunc.awe_Xephyr()
    -- Start Xephyr with the right resolution
    sexec('Xephyr -ac -br -noreset -screen 1152x720 :1')
    -- Sleep for 0.2 seconds
    local sec = 0.2
    socket.select(nil, nil, sec)
    -- Start awesome
    sexec('DISPLAY=:1 awesome -c ~/.config/awesome/rc.lua')
end

return hfunc

---}}}
