local wibox = require("wibox")
local awful = require("awful")
local watch = require("awful.widget.watch")
local gears = require("gears")

local wifi_menu = require("wifi_menu")

local wifi_widget = {}
local icon_dir = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/"

local wifi_icon = wibox.widget {
    resize = true,
    forced_width = 22,
    forced_height = 22,
    widget = wibox.widget.imagebox
}
local wifi_text = wibox.widget.textbox()

wifi_widget.widget = wibox.widget {
    wifi_icon,
--  Ağ adını ekrandan kaldırmak için bu satırı yorum satırına alıyoruz:
--  wibox.container.margin(wifi_text, 2, 0, 0, 3),  
    layout = wibox.layout.fixed.horizontal
}

-- Menüyle birebir uyumlu dinamik ikon kontrol fonksiyonu
local function update_wifi(widget, stdout)
    local icon_name = "WIFI0.png"
    local color = "#ff0000"
    local text_display = " Yok"
    
    -- Gelen tüm satırları tarayıp aktif olan ağı buluyoruz
    for line in stdout:gmatch("[^\r\n]+") do
        local active, ssid, signal = string.match(line, "^([^:]+):([^:]+):(%d+)")
        if active == "yes" and ssid and ssid ~= "" then
            signal = tonumber(signal) or 0
            text_display = " " .. ssid
            color = "#bbbbbb"
            
            if signal <= 30 then icon_name = "WIFI1.png"
            elseif signal <= 65 then icon_name = "WIFI2.png"
            else icon_name = "WIFI3.png" end
            break
        end
    end

    wifi_icon.image = gears.color.recolor_image(icon_dir .. icon_name, color)
--  Yazıyı gizlediğimiz için bu satırın da çalışmasına gerek kalmadı:
--  wifi_text:set_markup("<span color='" .. color .. "'>" .. text_display .. " </span>")
end

wifi_widget.widget:buttons(gears.table.join(
    awful.button({ }, 1, function ()  
        wifi_menu.toggle()  
    end)
))

-- Her 5 saniyede bir Wi-Fi sinyalini kontrol et (İngilizce çıktıya zorlayarak)
watch("sh -c \"LC_ALL=C nmcli -t -f active,ssid,signal dev wifi\"", 5, update_wifi, wifi_text)

return wifi_widget
