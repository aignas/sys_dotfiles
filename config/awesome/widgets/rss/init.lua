-- Newsbeuter widget
-- Written by Ignas Anikevicius (gns_ank)
--
--{{{ Environment


local awful = require('awful')
local beautiful = require('beautiful')
local naughty = require('naughty')
local wibox = require('wibox')
local capi = {
    awesome = awesome,
    timer = timer
}

local io = require('io')
local assert = assert
local setmetatable = setmetatable
local tostring = tostring
local string = string
local cfgdir = awful.util.getdir("config")
local sexec  = awful.util.spawn_with_shell
--}}}

local newsbeuter = { mt = {} }

function newsbeuter.set_text(args)
    local text = args.text or "0"
    --text = string.match(text, "%d+")
    local widget = args.widget or mynewscount.wi or nil
    if not widget then
        return false
    else
        widget:set_text(text)
    end
end

function newsbeuter.new()
    mynewscount = {}
    mynewscount.wi = wibox.widget.textbox()
    mynewscount.wi:set_text('%%')
    mynewscount.l_wi = wibox.layout.margin(
      mynewscount.wi,    -- widget to use
      2,1,2,2       -- l,r,t,b
    )
    local myicon = {}
    myicon.wi = wibox.widget.imagebox()
    myicon.wi:set_image(capi.awesome.load_image(cfgdir .. "/widgets/rss.png"))
    myicon.l_wi = wibox.layout.margin(
      myicon.wi,    -- widget to use
      4,1,2,2       -- l,r,t,b
    )

    local mywi = wibox.layout.fixed.horizontal()
    mywi:add(myicon.l_wi)
    mywi:add(mynewscount.l_wi)

    local file = assert(io.popen('newsbeuter -x print-unread'))
    local output = file:read('*all')
    file:close()
    output = string.match(output, "%d+")
    newsbeuter.set_text({text= "?/" .. output})

    return mywi
end

-- Set the metatable, like other awful widgets
function newsbeuter.mt:__call(...)
    return newsbeuter.new(...)
end

return setmetatable(newsbeuter, newsbeuter.mt)
