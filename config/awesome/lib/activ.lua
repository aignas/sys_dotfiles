-- Written by Ignas Anikevicius (gns_ank)
--
-- Environment
local awful = require('awful')
local capi = {
    tag = tag,
    mouse = mouse,
    screen = screen,
    keygrabber = keygrabber,
    client = client
}
local ipairs = ipairs
local pairs = pairs
local table = table
local print = print

module('activ')

----------------- DESCRIPTION ---------------------
--[[
The module is basically a retarded implementation of KDE concept of activities.

There are several components of this module:
    * The widget indicating which in which activity you are in
    * Functions:
      <-> Jump to activity
      <-> Create a new activity
      <-> Dispose activity
      <-> Change the importance of the activity 
          (in which order they do appear in the list)
      <-> Attach a tag to 1 particular activity or several at the same time
      <-> Dettach a tag from an activity
      <-> There would be one master activity called "All" to return the 
          original behaviour
TODO  <-> Activities are not bound to a particular screen, but a particular 
          activity can be present only on one screen
    * Special filter for the taglist, which lists only tags from the selected 
      activities
    * 
--]]
--
-- Activities stuff
myactiv = {}
myactiv.index = {"sys", "prod", "prod1", "prod2", "media", "web"}
myactiv.current = {"sys"}
myactiv.i_table = {
    sys = { term, term2, term3 },
    prod = { TeX, TeX2, calc, calc2 },
    prod2 = { TeX, TeX2, calc, calc2 },
    prod3 = { TeX, TeX2, calc, calc2 },
    media = { gimp, ink, ard, ard2 },
    web = { www, email, irc, im_p, im_s }
}

myactiv.textfg = wibox.widget.textbox()
myactiv.textfg:set_markup("<span color='#cccccd'> main: </span>")
myactiv.widget = wibox.widget.background()
myactiv.widget:set_widget(myactiv.textfg)
myactiv.widget:set_bg('#7f9f7f')

-- jump to function where a is the name of the activity in the activity_index
myactiv.f_jumpto = function (a)
    if type(a)~="string" then return false end
    for i,k in ipairs(myactiv.index) do
        if k == a then 
            myactiv.textfg:set_markup("<span color='#ddddde'> "..a.." </span>")
        end
    end
end

myactiv.menu_table = {}
for i,k in ipairs(myactiv.index) do
    print(i)
    myactiv.menu_table[i] = { k, function() myactiv.f_jumpto(k) end }
end
myactiv.menu = awful.menu({items = myactiv.menu_table})

myactiv.widget:buttons(awful.util.table.join(
    awful.button({}, 1, function () myactiv.menu:toggle({keygrabber=true}) end),
    awful.button({}, 3, function () mymenu.main:toggle({keygrabber=true}) end)
))


-- vim: filetype=lua:shiftwidth=4:tabstop=4:softtabstop=4:textwidth=80
