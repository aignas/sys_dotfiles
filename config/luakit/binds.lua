-----------------
-- Keybindings --
-----------------

binds = {}

-- Binding aliases
local key, buf, but, cmd = lousy.bind.key, lousy.bind.buf, lousy.bind.but, lousy.bind.cmd

-- Globals or defaults that are used in binds
local scroll_step = globals.scroll_step or 20
local homepage    = globals.homepage or "http://luakit.org"

-- Add key bindings to be used across all windows in the given modes.
binds.mode_binds = {
     -- buf(Pattern,                    function (w, buffer, opts) .. end, opts),
     -- key({Modifiers}, Key name,      function (w, opts)         .. end, opts),
     -- but({Modifiers}, Button num,    function (w, opts)         .. end, opts),
    all = {
        key({},          "Escape",      function (w) w:set_mode() end),
        key({"Control"}, "[",           function (w) w:set_mode() end),

        but({},          8,             function (w) w:back()    end),
        but({},          9,             function (w) w:forward() end),
    },
    normal = {
        key({},          "i",           function (w) w:set_mode("insert")  end),
        key({},          ":",           function (w) w:set_mode("command") end),

        -- Scrolling
        key({},          "j",           function (w) w:scroll_vert("+"..scroll_step.."px") end),
        key({},          "k",           function (w) w:scroll_vert("-"..scroll_step.."px") end),
        key({},          "h",           function (w) w:scroll_horiz("-"..scroll_step.."px") end),
        key({},          "l",           function (w) w:scroll_horiz("+"..scroll_step.."px") end),
        key({"Control"}, "d",           function (w) w:scroll_page(0.5)    end),
        key({"Control"}, "u",           function (w) w:scroll_page(-0.5)   end),
        key({"Control"}, "f",           function (w) w:scroll_page(1.0)    end),
        key({"Control"}, "b",           function (w) w:scroll_page(-1.0)   end),
        key({},          "space",       function (w) w:scroll_page(1.0) end),
        key({},          "BackSpace",   function (w) w:scroll_page(-1.0) end),
        buf("^gg$",                     function (w) w:scroll_vert("0%")   end),
        buf("^G$",                      function (w) w:scroll_vert("100%") end),
        buf("^[\-\+]?[0-9]+[%%G]$",     function (w, b) w:scroll_vert(string.match(b, "^([\-\+]?%d+)[%%G]$") .. "%") end),

        -- Traditional scrolling commands
        key({},          "Down",        function (w) w:scroll_vert("+"..scroll_step.."px") end),
        key({},          "Up",          function (w) w:scroll_vert("-"..scroll_step.."px") end),
        key({},          "Left",        function (w) w:scroll_horiz("-"..scroll_step.."px") end),
        key({},          "Right",       function (w) w:scroll_horiz("+"..scroll_step.."px") end),
        key({},          "Page_Down",   function (w) w:scroll_page(1.0)    end),
        key({},          "Page_Up",     function (w) w:scroll_page(-1.0)   end),
        key({},          "Home",        function (w) w:scroll_vert("0%")   end),
        key({},          "End",         function (w) w:scroll_vert("100%") end),

        -- Zooming
        key({},          "+",           function (w) w:zoom_in()  end),
        key({},          "-",           function (w) w:zoom_out() end),
        key({},          "=",           function (w) w:zoom_set() end),
        buf("^zz$",                     function (w) w:zoom_set() end),
        buf("^zi$",                     function (w) w:zoom_in()  end),
        buf("^zo$",                     function (w) w:zoom_out() end),
        buf("^zI$",                     function (w) w:zoom_in(nil, true)  end),
        buf("^zO$",                     function (w) w:zoom_out(nil, true) end),

        -- Specific zoom
        buf("^%d+z$",                   function (w, b) w:zoom_set(tonumber(string.match(b, "^(.+)z$"))/100)       end),
        buf("^%d+Z$",                   function (w, b) w:zoom_set(tonumber(string.match(b, "^(.+)Z$"))/100, true) end),

        -- Clipboard
        key({},          "p",           function (w) w:navigate(luakit.get_selection()) end),
        key({},          "P",           function (w) w:new_tab(luakit.get_selection())  end),
        buf("^yy$",                     function (w) w:set_selection((w:get_current() or {}).uri or "") end),
        buf("^yt$",                     function (w) w:set_selection(w.win.title) end),

        -- Commands
        buf("^o$",                      function (w, c) w:enter_cmd(":open ")    end),
        buf("^t$",                      function (w, c) w:enter_cmd(":tabopen ") end),
        buf("^w$",                      function (w, c) w:enter_cmd(":winopen ") end),
        buf("^O$",                      function (w, c) w:enter_cmd(":open "    .. ((w:get_current() or {}).uri or "")) end),
        buf("^T$",                      function (w, c) w:enter_cmd(":tabopen " .. ((w:get_current() or {}).uri or "")) end),
        buf("^W$",                      function (w, c) w:enter_cmd(":winopen " .. ((w:get_current() or {}).uri or "")) end),

        buf("^,g$",                     function (w, c) w:enter_cmd(":open google ") end),
        buf("^,wi$",                    function (w, c) w:enter_cmd(":open Wiki ") end),
        buf("^,d$",                     function (w, c) w:enter_cmd(":open duckduckgo ") end),
        buf("^,y$",                     function (w, c) w: enter_cmd(":open youtube ") end),

        -- Arch site searches
        buf("^,aur$",                   function (w, c) w:enter_cmd(":open AUR ") end),
        buf("^,awi$",                   function (w, c) w:enter_cmd(":open ArchWiki ") end),
        buf("^,bbs$",                   function (w, c) w:enter_cmd(":open ArchForums ") end),

        -- Thinkwiki search
        buf("^,twi$",                   function (w, c) w:enter_cmd(":open ThinkWiki ") end),

        -- Searching
        key({},          "/",           function (w) w:start_search("/")  end),
        key({},          "?",           function (w) w:start_search("?") end),
        key({},          "n",           function (w) w:search(nil, true) end),
        key({},          "N",           function (w) w:search(nil, false) end),

        -- History
        buf("^[0-9]*H$",                function (w, b) w:back   (tonumber(string.match(b, "^(%d*)H$") or 1)) end),
        buf("^[0-9]*L$",                function (w, b) w:forward(tonumber(string.match(b, "^(%d*)L$") or 1)) end),
        key({},          "b",           function (w) w:back() end),
        key({},          "XF86Back",    function (w) w:back() end),
        key({},          "XF86Forward", function (w) w:forward() end),

        -- Tab
        key({"Control"}, "Page_Up",     function (w) w:prev_tab() end),
        key({"Control"}, "Page_Down",   function (w) w:next_tab() end),
        key({"Control"}, "n",           function (w) w:next_tab() end),
        key({"Control"}, "p",           function (w) w:prev_tab() end),
        key({"Control"}, "Tab",         function (w, b) w:next_tab() end),
        key({"Shift","Control"}, "Tab", function (w, b) w:prev_tab() end),
        buf("^[0-9]*gT$",               function (w, b) w:prev_tab(tonumber(string.match(b, "^(%d*)gT$") or 1)) end),
        buf("^[0-9]*gt$",               function (w, b) w:next_tab(tonumber(string.match(b, "^(%d*)gt$") or 1)) end),

        key({"Control"}, "t",           function (w) w:new_tab(homepage) end),
        key({"Control"}, "w",           function (w) w:close_tab()       end),
        key({},          "d",           function (w) w:close_tab()       end),
        key({},          "u",           function (w) w:undo_close_tab()  end),

        key({},          "<",           function (w) w.tabs:reorder(w:get_current(), w.tabs:current() -1) end),
        key({},          ">",           function (w) w.tabs:reorder(w:get_current(), (w.tabs:current() + 1) % w.tabs:count()) end),

        buf("^gH$",                     function (w) w:new_tab(homepage) end),
        buf("^gh$",                     function (w) w:navigate(homepage) end),

        key({},          "r",           function (w) w:reload() end),
        key({"Control"}, "c",           function (w) w:stop() end),

        -- Window
        buf("^ZZ$",                     function (w) w:close_win() end),
        buf("^D$",                      function (w) w:close_win() end),

        -- Bookmarking
        key({},          "B",           function (w) w:enter_cmd(":bookmark " .. ((w:get_current() or {}).uri or "http://") .. " ") end),
        buf("^gb$",                     function (w) w:navigate(bookmarks.dump_html()) end),
        buf("^gB$",                     function (w) w:new_tab (bookmarks.dump_html()) end),

        -- Mouse bindings
        but({},          2,             function (w)
                                            -- Open hovered uri in new tab
                                            local uri = w:get_current().hovered_uri
                                            if uri then w:new_tab(uri, false)
                                            else -- Open selection in current tab
                                                uri = luakit.get_selection()
                                                if uri then w:get_current().uri = uri end
                                            end
                                        end),
        but({"Control"},2,             function (w)
                                            -- Open hovered uri in new tab
                                            local uri = w:get_current().hovered_uri
                                            if uri then w:new_win(uri, false)
                                            else -- Open selection in current tab
                                                uri = luakit.get_selection()
                                                if uri then w:get_current().uri = uri end
                                            end
                                        end),
    },
    command = {
        key({"Shift"},   "Insert",      function (w) w:insert_cmd(luakit.get_selection()) end),
        key({},          "Tab",         function (w) w:cmd_completion() end),
        key({"Control"}, "w",           function (w) w:del_word() end),
        key({"Control"}, "u",           function (w) w:del_line() end),
    },
    search = {
        key({"Control"}, "j",           function (w) w:search(nil, true) end),
        key({"Control"}, "k",           function (w) w:search(nil, false) end),
    },
    insert = { },
}

-- Command bindings which are matched in the "command" mode from text
-- entered into the input bar.
binds.commands = {
 -- cmd({command, alias1, ...},         function (w, arg, opts) .. end, opts),
 -- cmd("co[mmand]",                    function (w, arg, opts) .. end, opts),
    cmd("o[pen]",                       function (w, a) w:navigate(w:search_open(a)) end),
    cmd("t[abopen]",                    function (w, a) w:new_tab(w:search_open(a)) end),
    cmd("w[inopen]",                    function (w, a) window.new{w:search_open(a)} end),
    cmd("back",                         function (w, a) w:back(tonumber(a) or 1) end),
    cmd("f[orward]",                    function (w, a) w:forward(tonumber(a) or 1) end),
    cmd("scroll",                       function (w, a) w:scroll_vert(a) end),
    cmd("q[uit]",                       function (w)    w:close_win() end),
    cmd("c[lose]",                      function (w)    w:close_tab() end),
    cmd("reload",                       function (w)    w:reload() end),
    cmd("print",                        function (w)    w:eval_js("print()", "rc.lua") end),
    cmd({"viewsource",  "vs" },         function (w)    w:toggle_source(true) end),
    cmd({"viewsource!", "vs!"},         function (w)    w:toggle_source() end),
    cmd({"bookmark",    "bm" },         function (w, a)
                                            local args = lousy.util.string.split(a)
                                            local uri = table.remove(args, 1)
                                            bookmarks.add(uri, args)
                                        end),
}

-- Helper functions which are added to the window struct
binds.helper_methods = {
    -- Navigate current view or open new tab
    navigate = function (w, uri, view)
        if not view then view = w:get_current() end
        if view then
            view.uri = uri
        else
            return w:new_tab(uri)
        end
    end,

    -- Intelligent open command which can detect a uri or search argument.
    search_open = function (w, arg)
        if not arg then return "about:blank" end
        local str = lousy.util.string
        args = str.split(str.strip(arg))
        -- Detect scheme:// or "." in string
        if #args == 1 and (string.match(args[1], "%.") or string.match(args[1], "^%w+://")) then
            return args[1]
        end
        -- Find search engine
        if #args >= 1 and string.match(args[1], "^%w+$") then
            -- Find exact match
            if search_engines[args[1]] then
                return ({string.gsub(search_engines[args[1]], "{%d}", table.concat(args, " ", 2))})[1]
            end
            -- Find partial match
            local part, len = args[1], #(args[1])
            for engine, uri in pairs(search_engines) do
                if string.sub(engine, 1, len) == part then
                    return ({string.gsub(uri, "{%d}", table.concat(args, " ", 2))})[1]
                end
            end
        end
        -- Fallback on google search
        return ({string.gsub(search_engines["google"], "{%d}", table.concat(args, " "))})[1]
    end,

    -- Tab traversing functions
    next_tab = function (w, n)
        w.tabs:switch((((n or 1) + w.tabs:current() -1) % w.tabs:count()) + 1)
    end,

    prev_tab = function (w, n)
        w.tabs:switch(((w.tabs:current() - (n or 1) -1) % w.tabs:count()) + 1)
    end,

    goto_tab = function (w, n)
        w.tabs:switch(n)
    end,

    -- If argument is form-active or root-active, emits signal. Ignores all
    -- other signals.
    emit_form_root_active_signal = function (w, s)
        if s == "form-active" then
            w:get_current():emit_signal("form-active")
        elseif s == "root-active" then
            w:get_current():emit_signal("root-active")
        end
    end,
}

-- Insert webview method lookup on window structure
table.insert(window.indexes, 1, function (w, k)
    -- Lookup bind helper method
    return binds.helper_methods[k]
end)

-- vim: et:sw=4:ts=8:sts=4:tw=80
