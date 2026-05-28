local wibox = require("wibox")
local watch = require("awful.widget.watch")
local gears = require("gears")

local battery_widget = {}
local icon_dir = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/"

-- İkon ve metin objelerimiz
local bat_icon = wibox.widget {
    resize = true,
    forced_width = 40,
    forced_height = 30,
    widget = wibox.widget.imagebox
}
local bat_text = wibox.widget.textbox()

-- Dışarı aktaracağımız ana bileşen
battery_widget.widget = wibox.widget {
    bat_icon,
    -- Yazıyı alttan 3px iterek ikona hizalıyoruz:
    wibox.container.margin(bat_text, 0, 0, 0, 6), 
    layout = wibox.layout.fixed.horizontal
}

-- Yüzdeye göre ikonu güncelleyen fonksiyon
local function update_bat(widget, stdout)
    local bat = tonumber(stdout:match("%d+")) -- Çıktıdan sadece sayıyı al
    
    if not bat then -- Eğer pil bulunamazsa
        bat_icon.image = gears.color.recolor_image(icon_dir .. "Battery0.png", "#ff0000")
        bat_text:set_markup("<span color='#ff0000'> ? </span>")
        return
    end

    -- Yüzdeye göre ikon seçimi
    local icon_name = "Battery5.png"
    if bat <= 15 then icon_name = "Battery0.png"
    elseif bat <= 35 then icon_name = "Battery1.png"
    elseif bat <= 55 then icon_name = "Battery2.png"
    elseif bat <= 75 then icon_name = "Battery3.png"
    elseif bat <= 95 then icon_name = "Battery4.png"
    end

    -- %15 ve altındaysa renk kırmızı olsun, değilse gri
    local color = "#bbbbbb"
    if bat <= 15 then color = "#ff0000" end

    -- Seçilen ikonu renklendir ve uygula
    bat_icon.image = gears.color.recolor_image(icon_dir .. icon_name, color)
    bat_text:set_markup("<span color='" .. color .. "'> %" .. bat .. " </span>")
end

-- Her 10 saniyede bir pili kontrol et
watch("cat /sys/class/power_supply/BAT0/capacity", 10, update_bat, bat_text)

return battery_widget
