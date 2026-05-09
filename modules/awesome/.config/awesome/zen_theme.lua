-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local filesystem = require("gears.filesystem")

-- Alternative icon sets and widget icons:
--  * http://awesome.naquadah.org/wiki/Nice_Icons

-- {{{ Main
theme = {}
config_dir = os.getenv("HOME") .. "/.config/awesome/"
local wallpaper_override = config_dir .. "wall.override"

if filesystem.file_readable(wallpaper_override) then
    theme.wallpaper = wallpaper_override
else
    theme.wallpaper = config_dir .. "wall.jpg"
end
-- }}}

-- {{{ Styles
theme.font = "xos4 Terminus 8"

-- {{{ Colors
theme.fg_normal = "#DCDCCC"
theme.fg_focus  = "#F0DFAF"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#1F1F1F"
theme.bg_focus  = "#3F3F3F"
theme.bg_urgent = "#3F3F3F"
-- }}}

-- {{{ Borders
theme.border_width  = 1
theme.border_normal = "#3F3F3F"
theme.border_focus  = "#993300"
theme.border_marked = "#CC9393"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = 15
theme.menu_width  = 100
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = "/usr/share/awesome/themes/zenburn/taglist/squarefz.png"
theme.taglist_squares_unsel = "/usr/share/awesome/themes/zenburn/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Layout
theme.layout_tile       = config_dir .. "icons/layouts/tile.png"
theme.layout_fairv      = config_dir .. "icons/layouts/fairv.png"
theme.layout_fullscreen = config_dir .. "icons/layouts/max.png"
theme.layout_floating   = config_dir .. "icons/layouts/floating.png"
-- }}}

-- {{{ Widgets
theme.battery_ac    = config_dir .. "icons/widgets/ac.png"
theme.battery_empty = config_dir .. "icons/widgets/battery_empty.png"
theme.battery_low   = config_dir .. "icons/widgets/battery_low.png"
theme.battery       = config_dir .. "icons/widgets/battery.png"
theme.cpu           = config_dir .. "icons/widgets/cpu.png"
theme.hdd           = config_dir .. "icons/widgets/hdd.png"
theme.mem           = config_dir .. "icons/widgets/mem.png"
theme.net_wifi      = config_dir .. "icons/widgets/net.png"
theme.net_wired     = config_dir .. "icons/widgets/net_wired.png"
theme.net_up        = config_dir .. "icons/widgets/net_up.png"
theme.net_down      = config_dir .. "icons/widgets/net_down.png"
theme.temp          = config_dir .. "icons/widgets/temp.png"
theme.vol           = config_dir .. "icons/widgets/vol.png"
theme.vol_no        = config_dir .. "icons/widgets/vol_no.png"
theme.vol_mute      = config_dir .. "icons/widgets/vol_mute.png"
theme.vol_low       = config_dir .. "icons/widgets/vol_low.png"
-- }}}

-- }}}

return theme
