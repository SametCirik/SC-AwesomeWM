local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local details_panel = {}

-- Detay Panelinin Kendisi (Genişlik 250'ye eşitlendi)
local panel = wibox({
    width = 250,
    height = 140, -- Başlangıç yüksekliği
    ontop = true,
    visible = false,
    bg = beautiful.wibar_bg or "#111111",
    border_width = beautiful.wibar_border_width or 2,
    border_color = beautiful.wibar_border_color or "#FF8800",
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
})

-- Widget'lar (Araçlar)
local title_text = wibox.widget.textbox()
local basic_text = wibox.widget.textbox()
local advanced_text = wibox.widget.textbox()
advanced_text.visible = false

-- İleride eklenecek Grafik için Hazırlık (Placeholder)
local graph_placeholder = wibox.widget {
    {
        wibox.widget.textbox("<span color='#444444'><i>[ Sinyal Grafiği Alanı ]</i></span>"),
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    },
    forced_height = 60,
    bg = "#1a1a1a",
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 5) end,
    visible = false,
    widget = wibox.container.background
}

-- Şık Buton Üretici Fonksiyon
local function create_btn(text, action)
    local btn_txt = wibox.widget.textbox("<span color='#bbbbbb'>[" .. text .. "]</span>")
    local btn = wibox.widget {
        { btn_txt, margins = 4, widget = wibox.container.margin },
        bg = "#111111", widget = wibox.container.background
    }
    btn:connect_signal("mouse::enter", function() btn_txt:set_markup("<span color='#FF8800'><b>[" .. text .. "]</b></span>") end)
    btn:connect_signal("mouse::leave", function() btn_txt:set_markup("<span color='#bbbbbb'>[" .. text .. "]</span>") end)
    btn:buttons(gears.table.join(awful.button({}, 1, action)))
    return btn
end

-- Panelin dizilimi
local button_layout = wibox.layout.flex.horizontal()
panel:setup {
    layout = wibox.layout.fixed.vertical,
    wibox.container.margin(title_text, 15, 15, 10, 5),
    wibox.container.margin(basic_text, 15, 15, 5, 5),
    wibox.container.margin(advanced_text, 15, 15, 5, 5),
    wibox.container.margin(graph_placeholder, 15, 15, 5, 5), -- Grafik alanı eklendi
    wibox.container.margin(button_layout, 10, 10, 10, 10)
}

-- ANA FONKSİYON
function details_panel.show(ssid, signal, security, is_active)
    local wifi_menu = require("wifi_menu")
    local wifi_password_panel = require("wifi_password_panel")

    title_text:set_markup("<span color='#FF8800' font='Courier Prime 12'><b>" .. ssid .. "</b></span>")
    basic_text:set_markup("<span color='#bbbbbb'>Sinyal Gücü: %" .. signal .. "</span>")
    
    advanced_text.visible = false
    graph_placeholder.visible = false
    panel.height = 140

    button_layout:reset()
    
    -- 1. BAĞLAN BUTONU (Sadece Ana Menüye Döndürür)
    button_layout:add(create_btn("Bağlan", function()
        panel.visible = false
        wifi_menu.force_open() 
    end))

    -- 2. BAĞLANTIYI KES BUTONU (Sadece aktif ağda görünür)
    if is_active then
        button_layout:add(create_btn("Kes", function()
            panel.visible = false
            wifi_menu.force_open()
            wifi_menu.disconnect_network(ssid) 
        end))
    end

    -- 3. DETAY BUTONU
    button_layout:add(create_btn("Detay", function()
        if advanced_text.visible then
            advanced_text.visible = false
            graph_placeholder.visible = false
            panel.height = 140
        else
            advanced_text:set_markup("<span color='#777777'><i>Bilgiler çekiliyor...</i></span>")
            advanced_text.visible = true
            graph_placeholder.visible = true
            panel.height = 310 -- Yazılar + Grafik Alanı için yüksekliği artırdık
            
            local cmd = "sh -c \"LC_ALL=C nmcli -t -f BSSID,FREQ,RATE,SECURITY dev wifi list ssid '" .. ssid .. "' | head -n 1\""
            awful.spawn.easy_async(cmd, function(stdout)
                local bssid, freq, rate, sec = stdout:match("([^:]+):([^:]+):([^:]+):(.*)")
                if bssid then
                    advanced_text:set_markup(
                        "<span color='#bbbbbb'>" ..
                        "BSSID: " .. bssid .. "\n" ..
                        "Frekans: " .. freq .. "\n" ..
                        "Hız: " .. rate .. "\n" ..
                        "Güvenlik: " .. sec .. "</span>"
                    )
                else
                    advanced_text:set_markup("<span color='#ff0000'>Detaylar alınamadı.</span>")
                end
            end)
        end
    end))

    -- Paneli Hizala ve Göster (X ekseni diğer panellerle 265 olarak hizalandı)
    local s = awful.screen.focused()
    panel.x = s.geometry.x + s.geometry.width - 265
    panel.y = s.geometry.y + 46
    panel.visible = true
end

return details_panel
