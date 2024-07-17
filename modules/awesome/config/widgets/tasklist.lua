local awful = require('awful')
local wibox = require('wibox')
local dpi = require('beautiful').xresources.apply_dpi
local gears = require('gears')

local clickable_container = require('widgets.clickable-container')
local tasklist_mode = 'icon' -- anything else = text
-- local tasklist_close = false

local capi = { }

--- Common method to create buttons.
-- @tab buttons
-- @param object
-- @treturn table
local function create_buttons(buttons, object)
    if buttons then
        local btns = {}
        for _, b in ipairs(buttons) do
            -- Create a proxy button object: it will receive the real
            -- press and release events, and will propagate them to the
            -- button object the user provided, but with the object as
            -- argument.
            local btn = capi.button { modifiers = b.modifiers, button = b.button }
            btn:connect_signal('press',
                function()
                    b:emit_signal('press', object)
                end)
            btn:connect_signal('release',
                function()
                    b:emit_signal('release', object)
                end)
            btns[#btns + 1] = btn
        end

        return btns
    end
end

local function list_update(w, buttons, label, data, objects)
    -- update the widgets, creating them if needed
    w:reset()
    for i, o in ipairs(objects) do
        local cache = data[o]
        cache = false
        local ib, tb, bgb, tbm, ibm, tt, l, ll, bg_clickable
        if cache then
            ib = cache.ib
            tb = cache.tb
            bgb = cache.bgb
            tbm = cache.tbm
            ibm = cache.ibm
            tt = cache.tt
        else
            ib = wibox.widget.imagebox()
            tb = wibox.widget.textbox()

            bg_clickable = clickable_container()
            bgb = wibox.container.background()
            tbm = wibox.container.margin(tb, dpi(4), dpi(4))
            ibm = wibox.container.margin(ib, dpi(6), dpi(6), dpi(6), dpi(6))
            l = wibox.layout.fixed.horizontal()
            ll = wibox.layout.fixed.horizontal()

            -- All of this is added in a fixed widget
            l:fill_space(true)
            l:add(ibm)
            l:add(tbm)
            ll:add(l)
            -- if tasklist_close then ll:add(cbm) end

            bg_clickable:set_widget(ll)
            -- And all of this gets a background
            bgb:set_widget(bg_clickable)


            l:buttons(create_buttons(buttons, o))

            -- Tooltip to display whole title, if it was truncated
            tt = awful.tooltip({
                objects = { tb },
                mode = 'outside',
                align = 'top',
                delay_show = 1
            })

            data[o] = {
                ib = ib,
                tb = tb,
                bgb = bgb,
                tbm = tbm,
                ibm = ibm,
                tt = tt
            }
        end

        local text, bg, bg_image, icon, args = label(o, tb)
        args = args or {}

        -- The text might be invalid, so use pcall.
        if tasklist_mode == 'icon' then text = nil end
        if text == nil or text == '' then
            tbm:set_margins(0)
        else
            -- truncate when title is too long
            local textOnly = text:match('>(.-)<')
            if (textOnly:len() > 24) then
                text = text:gsub('>(.-)<', '>' .. textOnly:sub(1, 21) .. '...<')
                tt:set_text(textOnly)
                tt:add_to_object(tb)
            else
                tt:remove_from_object(tb)
            end
            if not tb:set_markup_silently(text) then
                tb:set_markup('<i>&lt;Invalid text&gt;</i>')
            end
        end
        -- bgb:set_bg(bg)
        if type(bg_image) == 'function' then
            -- TODO: Why does this pass nil as an argument?
            bg_image = bg_image(tb, o, nil, objects, i)
        end
        bgb:set_bgimage(bg_image)
        if icon then
            ib.image = icon
            ib.resize = true
        else
            ibm:set_margins(0)
        end

        bgb.shape = args.shape
        bgb.shape_border_width = args.shape_border_width
        bgb.shape_border_color = args.shape_border_color

        bgl = wibox.container.background()
        bgl:set_bg(bg)
        bgl.shape = gears.shape.transform(gears.shape.rectangle):scale(1, 0.08):translate(0, 365)

        bl = wibox.widget {
            bgb,
            bgl,
            layout = wibox.layout.stack
        }

        w:add(bl)
        -- w:add(bgb)
    end
end

local tasklist_buttons = require("buttons").tasklist.custom

local taskList = function(s)
    return awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags,
        tasklist_buttons, {}, list_update,
        wibox.layout.fixed.horizontal())
end

return taskList
