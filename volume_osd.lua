local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local volume_osd = {}

-- Ses Panelinin Kendisi
local osd_wibox = wibox({
    width = 220,
    height = 40,
    ontop = true,
    visible = false,
    bg = beautiful.wibar_bg or "#111111",
    border_width = beautiful.wibar_border_width or 2,
    border_color = beautiful.wibar_border_color or "#FF8800",
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
})

-- Panel İçi Araçlar: İkon, İlerleme Çubuğu ve Yüzde Metni
local icon_txt = wibox.widget.textbox("<span color='#FF8800' font='Courier Prime 11'><b>VOL</b></span>")
local vol_txt = wibox.widget.textbox("<span color='#bbbbbb'>0%</span>")

local osd_bar = wibox.widget {
    max_value     = 100,
    value         = 0,
    forced_height = 6,
    color         = "#FF8800",
    background_color = "#222222",
    shape         = gears.shape.rounded_bar,
    bar_shape     = gears.shape.rounded_bar,
    widget        = wibox.widget.progressbar,
}

-- Panelin Dizilimi
osd_wibox:setup {
    layout = wibox.layout.align.horizontal,
    {
        wibox.container.margin(icon_txt, 15, 10, 0, 0),
        valign = "center",
        widget = wibox.container.place
    },
    {
        osd_bar,
        valign = "center",
        widget = wibox.container.place
    },
    {
        wibox.container.margin(vol_txt, 10, 15, 0, 0),
        valign = "center",
        widget = wibox.container.place
    }
}

-- Paneli 2 Saniye Sonra Gizleyecek Zamanlayıcı (Timer)
local hide_timer = gears.timer {
    timeout = 2,
    single_shot = true,
    callback = function()
        osd_wibox.visible = false
    end
}

-- ANA FONKSİYON: Sesi değiştirir ve paneli ekrana getirir
function volume_osd.change(step)
    -- Amixer'i "-q" (sessiz) olmadan çalıştırıyoruz ki bize yeni ses durumunu söylesin
    local cmd = "amixer sset Master " .. step
    
    awful.spawn.easy_async(cmd, function(stdout)
        -- Çıktının içinden yüzdeyi ve [on]/[off] (mute) durumunu ayıkla
        local volume = string.match(stdout, "(%d?%d?%d)%%")
        local status = string.match(stdout, "%[([onf]+)%]")

        if volume then
            osd_bar.value = tonumber(volume)
            vol_txt:set_markup("<span color='#bbbbbb'>" .. volume .. "%</span>")

            -- Ses kapalıysa (Mute) sadece çubuk ve yazı kırmızı olsun
            if status == "off" then
                osd_bar.color = "#ff0000"
                icon_txt:set_markup("<span color='#ff0000' font='Courier Prime 11'><b>MUT</b></span>")
                -- border_color satırını buradan sildik
            else
                osd_bar.color = "#FF8800"
                icon_txt:set_markup("<span color='#FF8800' font='Courier Prime 11'><b>VOL</b></span>")
                -- border_color satırını buradan sildik
            end
        end

        -- Paneli taskbarın altına ve tam ortaya hizala
        local s = awful.screen.focused()
        osd_wibox.x = s.geometry.x + (s.geometry.width - osd_wibox.width) / 2
        
        -- Y EKSENİ AYARI BURADA: 46 değerini artırarak barı aşağı indirebilirsin.
        -- Kendi zevkine göre birkaç denemeyle tam yeri bulursun (Örn: 52 yap)
        osd_wibox.y = s.geometry.y + 52
        
        osd_wibox.visible = true

        awesome.emit_signal("update_voice_icon")
        
        -- Eğer panel zaten açıksa timer'ı sıfırla ki süre uzasın
        if hide_timer.started then
            hide_timer:again()
        else
            hide_timer:start()
        end
    end)
end

return volume_osd
