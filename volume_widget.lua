local wibox = require("wibox")
local awful = require("awful")
local watch = require("awful.widget.watch")
local gears = require("gears")

-- OSD panelimizi çağırıyoruz ki fare tekerleğiyle sesi değiştirince ekranda görünsün
local volume_osd = require("volume_osd")

local volume_widget = {}
local icon_dir = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/"

-- İkon Aracı
local vol_icon = wibox.widget {
    resize = true,
    forced_width = 22,
    forced_height = 22,
    widget = wibox.widget.imagebox
}

-- Ana Widget Konteyneri
volume_widget.widget = wibox.widget {
    vol_icon,
    layout = wibox.layout.fixed.horizontal
}

-- Arka planda sesi kontrol edip ikonu güncelleyen fonksiyon
local function update_vol(widget, stdout)
    local volume = string.match(stdout, "(%d?%d?%d)%%")
    local status = string.match(stdout, "%[([onf]+)%]")
    
    local icon_name = "Sound_Mute.png"
    local color = "#bbbbbb"

    if volume and status then
        local vol_num = tonumber(volume)
        
        -- Mute durumunda kırmızı Mute ikonu
        if status == "off" then
            icon_name = "Sound_Mute.png"
            color = "#ff0000"
        -- Ses 0 ise (ama mute değilse) Sound0 ikonu
        elseif vol_num == 0 then
            icon_name = "Sound0.png"
        -- Kademeli Ses İkonları
        elseif vol_num <= 33 then
            icon_name = "Sound1.png"
        elseif vol_num <= 66 then
            icon_name = "Sound2.png"
        else
            icon_name = "Sound3.png"
        end
    end

    -- İkonu seç ve dinamik olarak renklendir
    vol_icon.image = gears.color.recolor_image(icon_dir .. icon_name, color)
end

-- İkonun üzerindeki Fare Etkileşimleri
volume_widget.widget:buttons(gears.table.join(
    -- Sol Tık: Sesi Kapat/Aç (Mute Toggle)
    awful.button({ }, 1, function () volume_osd.change("toggle") end),
    -- Scroll Yukarı: Sesi %2 Artır
    awful.button({ }, 4, function () volume_osd.change("2%+") end),
    -- Scroll Aşağı: Sesi %2 Azalt
    awful.button({ }, 5, function () volume_osd.change("2%-") end)
))

-- Her 1 saniyede bir ses seviyesini kontrol et
watch("amixer sget Master", 1, update_vol, vol_icon)

-- OSD'den sinyal geldiği anda beklemeden ikonu güncelle
awesome.connect_signal("update_volume_icon", function()
    awful.spawn.easy_async("amixer sget Master", function(stdout)
        update_vol(vol_icon, stdout)
    end)
end)

return volume_widget
