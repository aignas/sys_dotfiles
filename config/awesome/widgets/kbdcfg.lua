-- Keyboard map indicator and changer

local command = "setxkbmap"
local addargs = {
    "-model thinkpad -option caps:super", -- Setxkbmap options
    " xmodmap ~/.Xmodmap"  -- Other commands to execute afterwards
}
i_kbdcfg.layout = {
    { "gb", "" },
    { "lt", "std" },
    { "ru", "phonetic" },
    { "fr", "" },
    { "gb", "dvorakukp" }
}
local current = 1  -- default layout
local widget = widget({ type = "textbox", align = "right" })
local widget.text = " " .. wi_kbdcfg.layout[wi_kbdcfg.current]:sub(0,2) .. " "

tog = function (a,b)
    local l = #(wi_kbdcfg.layout)
    if not ( a == "s" or a == "j" or b > 0 ) then
        naughty.notify({text = "Keyboard switcher - Invalid arguments"})
        error()
    elseif a == "j" then
        wi_kbdcfg.current = b
    elseif a == "sb" then
        for v = b, 1, -1 do
            wi_kbdcfg.current = ( wi_kbdcfg.current + l - 2 ) % l + 1
        end
    elseif a == "sf" then
        for v = b, 1, -1 do
            wi_kbdcfg.current = wi_kbdcfg.current % l + 1
        end
    else
        naughty.notify({text = "Keyboard switcher - Invalid arguments"})
        error()
    end
    local t, u = wi_kbdcfg.layout[wi_kbdcfg.current], wi_kbdcfg.addargs
    --os.execute(wi_kbdcfg.command .. " " .. t[1] .. " " .. t[2] .. " " .. u[1] .. " &")
    exec(wi_kbdcfg.command .. " \"" .. t .. "\" " .. u[1])
    --os.execute(wi_kbdcfg.command .. " \"" .. t .. "\" " .. u[1])
    wi_kbdcfg.widget.text = " " .. t:sub(0,2) .. " "
    naughty.notify({    
        title = "XKBmap", 
        text = "Current layout - " .. t })
end

