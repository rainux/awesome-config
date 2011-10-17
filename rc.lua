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
require('revelation')

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
    awful.layout.suit.tile.left,
    awful.layout.suit.magnifier,
    awful.layout.suit.max,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal
    -- awful.layout.suit.tile,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names  = { 'main', 'www', 'www', 'terminal', 'im', 'files', 'dict', 'download', 9 },
    layouts = {
        layouts[2], layouts[4], layouts[4], layouts[4], layouts[1],
        layouts[1], layouts[4], layouts[4], layouts[4]
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
-- cpuwidget = widget({ type = 'textbox' })
-- vicious.register(cpuwidget, vicious.widgets.cpu, '$1%')

-- CPU usage widget (graph)
cpuwidget = awful.widget.graph()
cpuwidget:set_width(60)
cpuwidget:set_height(30)
cpuwidget:set_background_color('#494B4F')
cpuwidget:set_color('#FF5656')
cpuwidget:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96' })
vicious.register(cpuwidget, vicious.widgets.cpu, '$1')

-- Memory usage widget (textbox)
-- memwidget = widget({ type = 'textbox' })
-- vicious.register(memwidget, vicious.widgets.mem, '$1% ($2MB/$3MB)', 13)

-- Memory usage widget (graph)
memwidget = awful.widget.progressbar()
memwidget:set_width(100)
memwidget:set_height(30)
memwidget:set_background_color('#494B4F')
memwidget:set_border_color(nil)
memwidget:set_color('#AECF96')
memwidget:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)

volumewidget = obvious.volume_alsa():set_layout(awful.widget.layout.horizontal.rightleft).widget

-- {{{ Cmus info
musicicon = widget({ type = 'imagebox' })
musicicon.image = image(beautiful.widget_music)
-- Initialize widget
cmus_widget = widget({ type = 'textbox' })
-- Register widget
vicious.register(cmus_widget, vicious.widgets.cmus,
    function (widget, args)
        if args['{status}'] == 'Stopped' then
            return nil
        else
            return args['{status}']..': '.. args['{artist}']..' - '.. args['{title}']
        end
    end, 7)
--}}}

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = 'right' })
calendar2.addCalendarToWidget(mytextclock, markup.fg('green', '%s'))

-- Create a systray
mysystray = widget({ type = 'systray' })

-- Create a wibox for each screen and add it
mywibox = {}
mywibox2 = {}
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
mycurrenttask = {}
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

    mycurrenttask[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.focused(c, s)
                                          end)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = 'top', screen = s })
    mywibox2[s] = awful.wibox({ position = 'bottom', screen = s, width = 600 })
    awful.wibox.align(mywibox2[s], 'right', s)
    awful.widget.layout.margins[mytaglist[s]] = { left = 15 }

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        separator,
        netwidget,
        separator,
        memwidget.widget,
        separator,
        cpuwidget.widget,
        separator,
        volumewidget,
        separator,
        cmus_widget,
        s == 1 and mysystray or nil,
        mypromptbox[s],
        mycurrenttask[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
    mywibox2[s].widgets = {
        mytaglist[s],
        layout = awful.widget.layout.horizontal.leftright
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

    awful.key({ modkey, 'Control' }, 'e', function() awful.util.spawn(editor_cmd .. ' ' .. awful.util.getdir('config') .. '/rc.lua') end),
    awful.key({ modkey }, 'e', revelation),

    -- {{{ sdcv/stardict
    awful.key({ modkey }, 'd', function ()
        local f = io.popen('xsel -o')
        local new_word = f:read('*a')
        f:close()

        if frame ~= nil then
            naughty.destroy(frame)
            frame = nil
            if old_word == new_word then
                return
            end
        end
        old_word = new_word

        local fc = ''
        local f  = io.popen("sdcv -n --utf8-output -u 'The CMU Pronouncing Dictionary' -u 'Collins Cobuild English Dictionary' -u 'English irregular forms' -u 'English Etymology' -u '牛津英汉双解美化版' "..new_word)

        for line in f:lines() do
            fc = fc .. line .. '\n'
        end
        f:close()
        frame = naughty.notify({ text = fc, timeout = 10, width = 480 })
    end),

    awful.key({ modkey, 'Shift' }, 'd', function ()
        awful.prompt.run({prompt = 'Dict: '}, mypromptbox[mouse.screen].widget, function(cin_word)
            naughty.destroy(frame)
            if cin_word == '' then
                return
            end

            local fc = ''
            local f  = io.popen("sdcv -n --utf8-output -u 'The CMU Pronouncing Dictionary' -u 'Collins Cobuild English Dictionary' -u 'English irregular forms' -u 'English Etymology' -u '牛津英汉双解美化版' "..cin_word)
            for line in f:lines() do
                fc = fc .. line .. '\n'
            end
            f:close()
            frame = naughty.notify({ text = fc, timeout = 10, width = 480 })
        end, nil, awful.util.getdir('cache')..'/dict')
    end),


    awful.key({ modkey, 'Control' }, 'w', function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
        mywibox2[mouse.screen].visible = not mywibox2[mouse.screen].visible
    end),
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

    awful.key({ 'Mod1' }, 'h', function() awful.client.focus.bydirection('left') end),
    awful.key({ 'Mod1' }, 'j', function() awful.client.focus.bydirection('down') end),
    awful.key({ 'Mod1' }, 'k', function() awful.client.focus.bydirection('up') end),
    awful.key({ 'Mod1' }, 'l', function() awful.client.focus.bydirection('right') end),

    awful.key({ modkey }, 'Next',  function () awful.client.moveresize( 20,  20, -40, -40) end),
    awful.key({ modkey }, 'Prior', function () awful.client.moveresize(-20, -20,  40,  40) end),
    awful.key({ modkey }, 'Down',  function () awful.client.moveresize(  0,  20,   0,   0) end),
    awful.key({ modkey }, 'Up',    function () awful.client.moveresize(  0, -20,   0,   0) end),
    awful.key({ modkey }, 'Left',  function () awful.client.moveresize(-20,   0,   0,   0) end),
    awful.key({ modkey }, 'Right', function () awful.client.moveresize( 20,   0,   0,   0) end),

    awful.key({ 'Mod1' }, 'p', function()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ 'Mod1' }, 'n', function()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),

    awful.key({ 'Mod1', 'Shift' }, 'h', function() awful.client.swap.bydirection('left') end),
    awful.key({ 'Mod1', 'Shift' }, 'j', function() awful.client.swap.bydirection('down') end),
    awful.key({ 'Mod1', 'Shift' }, 'k', function() awful.client.swap.bydirection('up') end),
    awful.key({ 'Mod1', 'Shift' }, 'l', function() awful.client.swap.bydirection('right') end),

    awful.key({ 'Mod1', 'Shift' }, 'p', function() awful.client.swap.byidx(-1) end),
    awful.key({ 'Mod1', 'Shift' }, 'n', function() awful.client.swap.byidx(1) end),

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
                     maximized_vertical   = false,
                     maximized_horizontal = false,
                     size_hints_honor = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { name = 'MPlayer' },
      properties = { floating = true } },

    { rule = { class = 'pinentry' },
      properties = { floating = true } },

    { rule = { class = 'gimp' },
      properties = { floating = true } },

    { rule = { class = 'Krusader' },
      properties = { floating = true } },

    { rule = { name = 'Options' },
      properties = { floating = true } },

    { rule = { name = 'Settings' },
      properties = { floating = true } },

    { rule = { name = 'Preferences' },
      properties = { floating = true } },

    { rule = { class = 'Pidgin'},
      properties = { tag = tags[1][5], floating = true } },

    { rule = { class = 'Skype'},
      properties = { tag = tags[1][5], floating = true } },

    { rule = { class = 'Krusader'},
      properties = { tag = tags[1][6] } },

    { rule = { class = 'Stardict'},
      properties = { tag = tags[1][7] } },

    { rule = { class = 'Gnome-terminal'},
      properties = { tag = tags[1][4] } },

    { rule = { class = 'jd-Main', instance = 'sun-awt-X11-XFramePeer' },
      properties = { tag = tags[1][8] } },

    { rule = { class = 'jd-Main', instance = 'sun-awt-X11-XDialogPeer' },
      callback = function(c)
          awful.client.movetotag(awful.tag.selected(), c)
          local x = (screen[c.screen].geometry.width - c:geometry().width) / 2
          local y = (screen[c.screen].geometry.height - c:geometry().height) / 2
          c:geometry({ x = x, y = y })
      end },

    { rule = { class = 'Transmission-gtk' },
      properties = { tag = tags[1][8] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal('manage', function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    -- c:add_signal('mouse::enter', function(c)
        -- if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            -- and awful.client.focus.filter(c) then
            -- client.focus = c
        -- end
    -- end)

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

client.add_signal('focus', function(c)
    c.border_color = beautiful.border_focus
    c.opacity = 0.9
end)
client.add_signal('unfocus', function(c)
    c.border_color = beautiful.border_normal
    c.opacity = 0.5
end)
-- }}}


-- awful.util.spawn('gnome-settings-daemon')
awful.util.spawn('xcompmgr -c -F')
awful.util.spawn('ibus-daemon --xim')
awful.util.spawn('dropboxd')
-- awful.util.spawn('nm-applet')
-- awful.util.spawn('pidgin')
delayed_startup = timer { timeout = 1 }
delayed_startup:add_signal('timeout', function()
    aweror.run_or_raise('/home/rainux/bin/terminal', { class = 'Gnome-terminal' }, false)
    delayed_startup:stop()
end)
delayed_startup:start()
