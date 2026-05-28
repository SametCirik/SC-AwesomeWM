local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")

local desktop_music = {}

function desktop_music.create(s)
    local music_box = wibox({
        screen = s,
        width = 350,
        height = 320, 
        x = s.geometry.x + 50,
        y = s.geometry.y + 350,
        bg = "#111111",
        border_width = 2,
        border_color = "#FF8800",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end,
        ontop = false,
        below = true,
        visible = false
    })

    local title_txt = wibox.widget.textbox("<span color='#FF8800' font='Courier Prime Bold 13'>Oynatıcı Bekleniyor...</span>")
    local artist_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime 11'>...</span>")
    local status_txt = wibox.widget.textbox("<span color='#777777' font='Courier Prime 9'>[ OFFLINE ]</span>")

    local function create_btn(text, action)
        local btn_txt = wibox.widget.textbox("<span color='#bbbbbb'><b>" .. text .. "</b></span>")
        local btn = wibox.widget {
            { btn_txt, margins = 8, widget = wibox.container.margin },
            bg = "#222222",
            shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 5) end,
            widget = wibox.container.background
        }
        btn:connect_signal("mouse::enter", function(c) c:set_bg("#FF8800"); btn_txt:set_markup("<span color='#111111'><b>" .. text .. "</b></span>") end)
        btn:connect_signal("mouse::leave", function(c) c:set_bg("#222222"); btn_txt:set_markup("<span color='#bbbbbb'><b>" .. text .. "</b></span>") end)
        btn:buttons(gears.table.join(awful.button({}, 1, function() awful.spawn(action, false) end)))
        return btn
    end

    local controls_centered = wibox.widget {
        {
            create_btn("[ PREV ]", "playerctl previous"),
            create_btn("[ PLAY/PAUSE ]", "playerctl play-pause"),
            create_btn("[ NEXT ]", "playerctl next"),
            spacing = 15,
            layout = wibox.layout.fixed.horizontal
        },
        halign = "center",
        widget = wibox.container.place
    }

    -- DİZİLİM: Sadece üst grubu paketleyip yukarı sabitledik
    music_box:setup {
        layout = wibox.layout.align.vertical,
        {
            layout = wibox.layout.fixed.vertical,
            {
                status_txt,
                title_txt,
                artist_txt,
                layout = wibox.layout.fixed.vertical,
                spacing = 5
            },
            {
                controls_centered,
                margins = {top = 15},
                widget = wibox.container.margin
            }
        },
        nil,
        nil
    }

    -- MARJİNLERİ UYGULAYALIM
    music_box.widget.first.margins = {top = 20, left = 20, right = 20}
    music_box.widget.first = wibox.container.margin(music_box.widget.first, 20, 20, 20, 0)

    -- HATA YUTAN GÜVENLİ WATCH FONKSİYONU
    watch([[bash -c "playerctl metadata --format '{{title}};;{{artist}};;{{status}}' 2>/dev/null || echo 'Yok;;Yok;;Yok'"]], 1, function(widget, stdout)
        if not stdout or stdout == "" then return end
        
        local title, artist, status = stdout:match("(.*);;(.*);;(.*)")
        
        if title and title ~= "Yok" and title ~= "" then
            if string.len(title) > 30 then title = string.sub(title, 1, 27) .. "..." end
            if string.len(artist) > 30 then artist = string.sub(artist, 1, 27) .. "..." end
            
            title_txt:set_markup("<span color='#FF8800' font='Courier Prime Bold 13'>" .. title .. "</span>")
            artist_txt:set_markup("<span color='#bbbbbb' font='Courier Prime 11'>" .. artist .. "</span>")
            
            local is_playing = (status:match("Playing")) ~= nil
            local stat_color = is_playing and "#FF8800" or "#777777"
            status_txt:set_markup("<span color='" .. stat_color .. "' font='Courier Prime 9'>[ " .. string.upper(status:gsub("\n", "")) .. " ]</span>")
        else
            title_txt:set_markup("<span color='#FF8800' font='Courier Prime Bold 13'>Müzik Çalar Kapalı</span>")
            artist_txt:set_markup("<span color='#bbbbbb' font='Courier Prime 11'>...</span>")
            status_txt:set_markup("<span color='#777777' font='Courier Prime 9'>[ OFFLINE ]</span>")
        end
    end)

    return music_box
end

return desktop_music
