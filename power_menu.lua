local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local power_menu = {}

-- İkonların bulunduğu yeni klasör yolumuz
local icon_dir = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/"

local menu_wibox = wibox({
    width = 250,
    height = 200, -- İkonlar gelince biraz daha alan açtık
    ontop = true,
    visible = false,
    bg = beautiful.wibar_bg or "#111111",
    border_width = beautiful.wibar_border_width or 2,
    border_color = beautiful.wibar_border_color or "#FF8800",
    shape = beautiful.wibar_shape or function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
})

-- Hover (Üzerine gelme) efektli ve DİNAMİK RENKLENEN ikonlu buton fonksiyonu
local function create_btn(icon_file, text, action_func)
    local txt = wibox.widget.textbox("<span color='#bbbbbb'> " .. text .. " </span>")
    txt.font = beautiful.font
    
    local icon_path = icon_dir .. icon_file
    
    -- İkonu oluştur ve varsayılan olarak griye (#bbbbbb) boya
    local icon_widget = wibox.widget {
        image = gears.color.recolor_image(icon_path, "#bbbbbb"),
        resize = true,
        forced_width = 16, -- İkon genişliği
        forced_height = 16, -- İkon yüksekliği
        widget = wibox.widget.imagebox
    }

    -- İkon ve yazıyı yan yana dizelim
    local content_layout = wibox.layout.fixed.horizontal()
    content_layout:add(wibox.container.margin(icon_widget, 0, 10, 0, 0)) -- İkonla yazı arasına 10px boşluk
    content_layout:add(txt)

    local btn = wibox.widget {
        {
            content_layout,
            margins = 10,
            widget = wibox.container.margin
        },
        bg = "#111111",
        widget = wibox.container.background
    }

    -- Fare ÜZERİNE GELİNCE: Arka plan turuncu, yazı siyah, İKON SİYAH olsun
    btn:connect_signal("mouse::enter", function(c) 
        c:set_bg("#FF8800") 
        txt:set_markup("<span color='#111111'><b> " .. text .. " </b></span>") 
        icon_widget.image = gears.color.recolor_image(icon_path, "#111111")
    end)
    
    -- Fare ÇEKİLİNCE: Arka plan siyah, yazı gri, İKON GRİ olsun
    btn:connect_signal("mouse::leave", function(c) 
        c:set_bg("#111111") 
        txt:set_markup("<span color='#bbbbbb'> " .. text .. " </span>") 
        icon_widget.image = gears.color.recolor_image(icon_path, "#bbbbbb")
    end)

    btn:buttons(gears.table.join(
        awful.button({ }, 1, function()
            menu_wibox.visible = false 
            action_func()              
        end)
    ))

    return btn
end

-- Butonları yeni PNG ikonlarımızla menüye dizelim
menu_wibox:setup {
    layout = wibox.layout.fixed.vertical,
    wibox.container.margin(wibox.widget.textbox(""), 0, 0, 5, 5),
    create_btn("Power.png", "Kapat", function() awful.spawn("poweroff") end),
    create_btn("Restart.png", "Yeniden Başlat", function() awful.spawn("reboot") end),
    create_btn("Sleep.png", "Uyku Modu", function() awful.spawn("systemctl suspend") end),
    -- Kilit Butonu (Sadece temiz, önbelleğe alınmış duvar kağıdını gösterir)
    create_btn("Lock.png", "Kilitle", function() awful.spawn("betterlockscreen -l dimblur") end),
    create_btn("Logout.png", "Oturumu Kapat", function() awesome.quit() end),
}

function power_menu.toggle()
    if menu_wibox.visible then
        menu_wibox.visible = false
    else
        local s = awful.screen.focused()
        menu_wibox.x = s.geometry.x + s.geometry.width - 265
        menu_wibox.y = s.geometry.y + 52 
        menu_wibox.visible = true
    end
end

return power_menu
