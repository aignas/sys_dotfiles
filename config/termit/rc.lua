require("termit.colormaps")
require("termit.utils")

defaults = {}
defaults.windowTitle = 'Termit'
defaults.tabName = ''
defaults.encoding = 'UTF-8'
defaults.wordChars = '+-AA-Za-z0-9,./?%&#:_~'
defaults.scrollbackLines = 16384
defaults.font = 'Monospace 10'
defaults.geometry = ''
defaults.hideSingleTab = false
defaults.showScrollbar = false
defaults.fillTabbar = false
defaults.hideMenubar = false
defaults.allowChangingTitle = false
defaults.visibleBell = false
defaults.audibleBell = false
defaults.urgencyOnBell = true

defaults.colormap = termit.colormaps.tango

setOptions(defaults)

setKbPolicy('keysym')

-- remove default keybindings
--bindKey('Ctrl-t',       nil) -- openTab
bindKey('Alt-Left',     nil) -- prevTab
bindKey('Alt-Right',    nil) -- nextTab
bindKey('CtrlShift-w',  nil) -- closeTab
bindKey('Ctrl-Insert',  nil) -- copy
bindKey('Shift-Insert', nil) -- paste

-- Add some VIM like key bindings:
bindKey('XF86Back', prevTab)
bindKey('XF86Forward', nextTab)
bindKey('Alt-F11', toggleMenubar)

for i = 1, 12 do
    bindKey('Alt-F'..i, function () activateTab(i) end)
end

userMenu = {}
table.insert(userMenu, {name='tango', action=function () setColormap(termit.colormaps.tango) end})
table.insert(userMenu, {name='zenburn', action=function () setColormap(termit.colormaps.zenburn) end})
table.insert(userMenu, {name='delicate', action=function () setColormap(termit.colormaps.delicate) end})
table.insert(userMenu, {name='mikado', action=function () setColormap(termit.colormaps.mikado) end})
table.insert(userMenu, {name='parkerBrothers', action=function () setColormap(termit.colormaps.parkerBrothers) end})
table.insert(userMenu, {name='fishbone', action=function () setColormap(termit.colormaps.fishbone) end})
table.insert(userMenu, {name='bright', action=function () setColormap(termit.colormaps.bright) end})
addMenu(userMenu, "Colormaps")
addPopupMenu(userMenu, "Colormaps")
