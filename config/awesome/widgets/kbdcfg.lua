--[[ Keyboard switcher widget

The initial version was basically a copy/paste from wiki.awesome.naquadah.org, but
later it has grown into something more elaborate and now it fulfills all my needs,
except probably for the window specific keymap switching, which I guess could be
implemented as one more function/event thing.

Features:
    *
    *
    *
    *

--]]

-- Keyboard map indicator and changer
command = "setxkbmap"
addargs = {
    "-model thinkpadz60 -option caps:hyper, terminate:ctrl_alt_bksp", -- Setxkbmap options
--    " xmodmap "..home.."/.Xmodmap"  -- Other commands to execute afterwards
}
img_dir = cfgdir.."/icons/flags/24/"
layout = {
    { "gb", "" },               -- id=1
    { "lt", "std" },            -- id=2
    { "ru", "phonetic" },       -- id=3
    { "fr", "" },               -- id=4
    { "lt", "" },               -- id=5
}
current = 1                     -- default layout
widget = wibox.widget.imagebox()
img = oocairo.image_surface_create_from_png
widget:set_image(img(cfgdir.."/icons/flags/24/" .. mykbdcfg.layout[mykbdcfg.current][1] .. ".png"))
mykbdcfg.naughty = nil

function mykbdcfg.tog (a,b)
    if mykbdcfg.naughty then naughty.destroy(mykbdcfg.naughty) end
    local l_len = #(mykbdcfg.layout)
    local l = mykbdcfg.current
    local changed = true
    if a == "j" then
        if l == b then changed = false 
        else l = b end
    elseif a == "s" and math.abs(b) == 1 then l = l + b
        if l == 0 then l = l_len
        elseif l == l_len + 1 then l = 1 end
    else
        naughty.notify({text = "Keyboard switcher - Invalid arguments"})
        changed = false 
        error()
    end
    local t, u = mykbdcfg.layout[l], mykbdcfg.addargs
    if changed then 
        mykbdcfg.current = l
        sexec(mykbdcfg.command .. " " .. t[1] .. " " .. t[2])
        sexec(u[2])
    end
    local nt = "Current layout - " .. t[1]
    if t[2] ~= "" then 
        nt = nt .. "\nLayout variant - " .. t[2] 
    else nt = nt .. "\nLayout variant - default" 
    end
    mykbdcfg.widget:set_image(img(cfgdir.."/icons/flags/24/" .. t[1] .. ".png"))
    mykbdcfg.naughty = naughty.notify({    
        title = "XKBmap", 
        text = nt,
        icon = img(cfgdir.."/icons/flags/48/" .. t[1] .. ".png"),
        width = 250,
        timeout = 1
    })
end

mykbdcfg.menu_table = {}
for i,k in ipairs(mykbdcfg.layout) do
    mykbdcfg.menu_table[i] = { k[1].." "..k[2], 
        function () mykbdcfg.tog("j", i) end, 
        img(cfgdir.."/icons/flags/32/" .. k[1]..".png")}
end
mykbdcfg.menu = awful.menu({items = mykbdcfg.menu_table})
