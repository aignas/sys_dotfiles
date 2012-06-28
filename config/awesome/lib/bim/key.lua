--[[ 
This will contain the necessary variable to configure the key bindings
The modes are not predefined and they can be configured from one's rc.lua
The reason behind modes is:
    - Have an easy way to manage clients without always holding "Mod4"
    - Have an easy way to control widgets
    - Have an easy way to access menus.... differently
    - Later there will be more things to add?
    - multikey keybindings:
        e.g. if one starts with Mod4+l and there is a binding Mod4+ll, then it will be waited for 2 or less second for another l, which can be pressed without a modifier
--]]

--- Define a multikey:
-- Way to run the command
--
-- {"l","l","F1"}
-- or
-- "ll<F1>"
--
-- mymode:multi({"Mod4"}, {"l","l","F1"}, function() naughty.notify({text="Hello, world"}) end)
-- or ?
-- a = key.multi("Mymode", {"Mod4"},{"l","l","F1"},function() naughty.notify({text="Hello, world"}) end)
--
-- <F1> should be denoted as <F1>
-- Maybe I should change awful.key to better suit my needs?
function multi(mode,mod,keys,command)
    -- FIXME finish parsing
    -- firstkey - the first key in the combination
    -- keyg_command a command to execute keygrabber
    awful.key(mod,firstkey,keyg_command)
    -- output to a feedback which key is pressed
    run_keygrabber
    -- output everykeypress
    -- change a mode definition:
    --      add awful.key
    change mode
    send signals
end

function define_mode(mode)
    initialize a mode
    make a keybinding to switch to it later.
end

--- Switch modes:
-- This works by setting globalkeys to some keydefinition of the modes
function mode_sw (mode)
    global data_table_mode = mode
    send some signal t
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80:foldmethod=marker
