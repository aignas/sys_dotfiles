-- ACPID abstraction lib
--
-- This library will deal with everything what I need in terms of
-- abstraction. This will make things much more easy 

-- Grab the environment

local awful = require("awful")
local naughty = require("naughty")
local capi = {
    keygrabber = keygrabber,
    awesome = awesome
}

local tonumber = tonumber
local os = os
local ipairs = ipairs

local exec = awful.util.spawn
local sexec = awful.util.spawn_with_shell
local rorexec = awful.client.run_or_raise

local prg = {
    screen = "arandr",
    locker = { "lualock", " -n" }
}

local dbus_halt      = 'dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
local dbus_restart   = 'dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'
local dbus_suspend   = "dbus-send --system --print-reply --dest=org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower.Suspend"
local dbus_hibernate = "dbus-send --system --print-reply --dest=org.freedesktop.UPower /org/freedesktop/UPower org.freedesktop.UPower.Hibernate"

module('acpid')

--- Notification helper for acpi
-- This basically wraps the naughty.notify
-- @param args: this parameter is a table consisting of text, title,
--              timeout and preset entries.
function notify (args)
    -- Set the required parameters
    local text = args.text or ""
    local title = args.title or "ACPI"
    local timeout = args.timeout or 5
    local preset = naughty.config.presets[args.preset] or naughty.config.presets.normal

    -- Destroy the old notification if we need to do so
    if acpi_naughty then
        naughty.destroy(acpi_naughty)
    end

    -- New notification
    acpi_naughty = naughty.notify({
        title = title,
        text = text,
        timeout = timeout,
        preset = preset
    })
end

function lock (...)
    local t = {...}
    if #t == 0 then t = prg.locker end

    local running = os.execute("pgrep " .. t[1] .. " > /dev/null")

    if running == 256 then
        local cmd = ""
        for _,k in ipairs(t) do
            cmd = cmd .. k
        end
        sexec(cmd)
    end
    return true
end

function suspend (method)
    -- Select a method
    local method = method or "ram"

    notify({ text="Computer is going to suspend to " .. method })
    -- Actually do something
    if method == "ram" then
        sexec("sudo pm-suspend")
    elseif method == "disk" then
        sexec("sudo pm-hibernate")
    elseif method == "both" then
        sexec("sudo pm-suspend-hybrid")
    end

    -- Lock the screen
    lock()
end

-- Poweroff or do something different
function awesome_quit ()
    local quit_not = naughty.notify({title = "What would you like to do?",
        text = "" .. "1. "   .. "(L)og out"
                  .. "\n2. " .. "(H)alt"
                  .. "\n3. " .. "(R)estart"
                  .. "\n4. " .. "(S)uspend to Ram"
                  .. "\n5. " .. "Suspend to (D)isk"
                  .. "\n6. " .. "Suspend to (B)oth"
        .. "", timeout = 0 }) 
    capi.keygrabber.run(
    function(modifiers, key, event)
        local mod_t = {}
        local mod = ""
        -- Have the modifiers as a boolean table.
        for k, v in ipairs(modifiers) do mod_t[v] = true; mod = mod..v..";" end
        -- Do not do anything when the keys are released or Shift is pressed.
        if event == "release"
          or key:find("Shift") then
          return true 
        end
        -- Do the right acpi event
        if     key == "1" or key == "l" or key == "L" then
            capi.awesome.quit()
        elseif key == "2" or key == "h" or key == "H" then
            sexec(dbus_halt)
        elseif key == "3" or key == "r" or key == "R" then
            sexec(dbus_restart)
        elseif key == "4" or key == "s" or key == "S" then
            suspend("ram")
        elseif key == "5" or key == "d" or key == "D" then
            suspend("disk")
        elseif key == "6" or key == "b" or key == "B" then
            suspend("both")
        end
        naughty.destroy(quit_not)
        capi.keygrabber.stop()
    end)
end


-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:foldmethod=marker
