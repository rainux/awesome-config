-- Standard awesome library
require('awful')
require('awful.autofocus')
require('awful.rules')
-- Theme handling library
require('beautiful')
-- Notification library
require('naughty')

require('vicious')
require('obvious.volume_alsa')

require('aweror')
require('markup')
require('calendar2')

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir('config')..'/'..'themes/default/theme.lua')

require('mocp')

-- This is used later as the default terminal and editor to run.
terminal = 'terminator'
editor = os.getenv('EDITOR') or 'editor'
editor_cmd = 'gvim'

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.magnifier,
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names  = { 'main', 'www', 'www', 'im', 5, 6, 7, 8, 9 },
    layouts = {
        layouts[2], layouts[4], layouts[4], layouts[1], layouts[1],
        layouts[1], layouts[1], layouts[1], layouts[1]
    }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layouts)
    -- tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { 'manual', terminal .. ' -e man awesome' },
   { 'edit config', editor_cmd .. ' ' .. awful.util.getdir('config') .. '/rc.lua' },
   { 'restart', awesome.restart },
   { 'quit', awesome.quit }
}

mymainmenu = awful.menu({ items = { { 'awesome', myawesomemenu, beautiful.awesome_icon },
                                    { 'open terminal', terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
space       = widget({ type = 'textbox' })
separator   = widget({ type = 'textbox' })
space.text = ' '
separator.text = ' || '

-- Network usage widget
netwidget = widget({ type = 'textbox' })
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${eth0 down_kb}</span> <span color="#7F9F7F">${eth0 up_kb}</span>', 3)

-- CPU usage widget (textbox)
cpuwidget = widget({ type = 'textbox' })
vicious.register(cpuwidget, vicious.widgets.cpu, '$1%')

-- CPU usage widget (graph)
-- cpuwidget = awful.widget.graph()
-- cpuwidget:set_width(50)
-- cpuwidget:set_background_color('#494B4F')
-- cpuwidget:set_color('#FF5656')
-- cpuwidget:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96' })
-- vicious.register(cpuwidget, vicious.widgets.cpu, '$1')

-- Memory usage widget (textbox)
memwidget = widget({ type = 'textbox' })
vicious.register(memwidget, vicious.widgets.mem, '$1% ($2MB/$3MB)', 13)

-- Memory usage widget (graph)
-- memwidget = awful.widget.progressbar()
-- memwidget:set_width(8)
-- memwidget:set_height(10)
-- memwidget:set_vertical(true)
-- memwidget:set_background_color('#494B4F')
-- memwidget:set_border_color(nil)
-- memwidget:set_color('#AECF96')
-- memwidget:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
-- vicious.register(memwidget, vicious.widgets.mem, '$1', 13)

-- mocp widget
mocpwidget = mocp.init({ max_chars = 50, width = 420 })

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = 'right' })
calendar2.addCalendarToWidget(mytextclock, markup.fg('green', '%s'))

-- Create a systray
mysystray = widget({ type = 'systray' })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = 'top', screen = s })

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            separator,
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        separator,
        netwidget,
        separator,
        memwidget,
        separator,
        cpuwidget,
        separator,
        obvious.volume_alsa(),
        mocpwidget,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    aweror.genkeys(modkey),

    awful.key({ modkey }, 'Up',     function() obvious.volume_alsa.raise(0, 'Master', 2) end),
    awful.key({ modkey }, 'Down',   function() obvious.volume_alsa.lower(0, 'Master', 2) end),

    awful.key({ modkey }, 'e',      function() awful.util.spawn(editor_cmd .. ' ' .. awful.util.getdir('config') .. '/rc.lua') end),


    awful.key({ modkey,           }, 'Left',   awful.tag.viewprev       ),
    awful.key({ modkey,           }, 'Right',  awful.tag.viewnext       ),
    awful.key({ modkey,           }, 'Escape', awful.tag.history.restore),

    awful.key({ modkey,           }, 'j',
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, 'k',
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, 'w', function () mymainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, 'Shift'   }, 'j', function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, 'Shift'   }, 'k', function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, 'Control' }, 'j', function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, 'Control' }, 'k', function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, 'u', awful.client.urgent.jumpto),
    awful.key({ modkey,           }, 'Tab',
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, 'Return', function () awful.util.spawn(terminal) end),
    awful.key({ modkey, 'Control' }, 'r', awesome.restart),
    awful.key({ modkey, 'Shift'   }, 'q', awesome.quit),

    awful.key({ modkey,           }, 'l',     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, 'h',     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, 'Shift'   }, 'h',     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, 'Shift'   }, 'l',     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, 'Control' }, 'h',     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, 'Control' }, 'l',     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, 'space', function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, 'Shift'   }, 'space', function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            'r',     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, 'x',
              function ()
                  awful.prompt.run({ prompt = 'Run Lua code: ' },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir('cache') .. '/history_eval')
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, 'f',      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, 'Shift'   }, 'c',      function (c) c:kill()                         end),
    awful.key({ modkey, 'Control' }, 'space',  awful.client.floating.toggle                     ),
    awful.key({ modkey, 'Control' }, 'Return', function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, 'o',      awful.client.movetoscreen                        ),
    awful.key({ modkey, 'Shift'   }, 'r',      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, 'n',      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, 'm',
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, '#' .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, 'Control' }, '#' .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, 'Shift' }, '#' .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = 'MPlayer' },
      properties = { floating = true } },
    { rule = { class = 'pinentry' },
      properties = { floating = true } },
    { rule = { class = 'gimp' },
      properties = { floating = true } },

    { rule = { class = 'Google-chrome'},
      properties = { tag = tags[1][2] } },
    { rule = { class = 'Pidgin'},
      properties = { tag = tags[1][4] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal('manage', function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal('mouse::enter', function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.add_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
-- }}}


awful.util.spawn('gnome-settings-daemon')
awful.util.spawn('ibus-daemon --xim')
awful.util.spawn('pidgin')


--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients.  Possible entries: any properties of the client object
function run_or_raise(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if table.getn(ctags) == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         awful.tag.viewonly(ctags[1])
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end
   awful.util.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match(table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
         return false
      end
   end
   return true
end
