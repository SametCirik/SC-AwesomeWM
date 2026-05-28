local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local mousegrabber = mousegrabber

local wifi_details_panel = require("wifi_details_panel")

local wifi_menu = {}
local icon_dir = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/"

wifi_menu.network_widgets = {}
wifi_menu.networks_cache = {} -- Ağları hafızada tutmak için
wifi_menu.current_page = 1
local MAX_VISIBLE = 6 -- Bir sayfada görünecek maksimum ağ sayısı

local menu_wibox = wibox({
    width = 250,
    height = 100, 
    ontop = true,
    visible = false,
    bg = beautiful.wibar_bg or "#111111",
    border_width = beautiful.wibar_border_width or 2,
    border_color = beautiful.wibar_border_color or "#FF8800",
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
})

local main_layout = wibox.layout.fixed.vertical()
menu_wibox:setup {
    wibox.container.margin(main_layout, 10, 10, 10, 10),
    layout = wibox.layout.align.vertical
}

local function get_wifi_icon(signal)
    local sig = tonumber(signal) or 0
    if sig <= 30 then return "WIFI1.png"
    elseif sig <= 65 then return "WIFI2.png"
    else return "WIFI3.png" end
end

local function create_net_btn(ssid, signal, security, is_active)
    local text = ssid
    if is_active then text = "Bağlı: " .. ssid end

    local base_color = is_active and "#FF8800" or "#bbbbbb"
    local txt = wibox.widget.textbox("<span color='" .. base_color .. "'> " .. text .. " </span>")
    txt.font = beautiful.font
    wifi_menu.network_widgets[ssid] = txt
    
    local icon_path = icon_dir .. get_wifi_icon(signal)
    local icon_widget = wibox.widget {
        image = gears.color.recolor_image(icon_path, base_color),
        resize = true,
        forced_width = 16,
        forced_height = 16,
        widget = wibox.widget.imagebox
    }

    local content_layout = wibox.layout.fixed.horizontal()
    content_layout:add(wibox.container.margin(icon_widget, 0, 10, 0, 0))
    content_layout:add(txt)

    local btn = wibox.widget {
        { content_layout, margins = 8, widget = wibox.container.margin },
        bg = "#111111", widget = wibox.container.background
    }

    btn:connect_signal("mouse::enter", function(c) 
        c:set_bg("#FF8800") 
        txt:set_markup("<span color='#111111'><b> " .. text .. " </b></span>") 
        icon_widget.image = gears.color.recolor_image(icon_path, "#111111")
    end)
    btn:connect_signal("mouse::leave", function(c) 
        c:set_bg("#111111") 
        txt:set_markup("<span color='" .. base_color .. "'> " .. text .. " </span>") 
        icon_widget.image = gears.color.recolor_image(icon_path, base_color)
    end)

    btn:buttons(gears.table.join(
        awful.button({ }, 1, function()
            if not is_active then
                if security ~= "--" and security ~= "" then
                    menu_wibox.visible = false
                    if mousegrabber.isrunning() then mousegrabber.stop() end
                    local wifi_password_panel = require("wifi_password_panel")
                    wifi_password_panel.connect(ssid)
                else
                    wifi_menu.set_status(ssid, "Bağlanıyor...", "#FF8800")
                    awful.spawn.easy_async("LC_ALL=C nmcli dev wifi connect '" .. ssid .. "'", function(out, err, r, code)
                        if code == 0 then wifi_menu.set_status(ssid, "Bağlı: " .. ssid, "#00FF00")
                        else wifi_menu.set_status(ssid, "Bağlanılamadı!", "#ff0000") end
                        gears.timer.start_new(2, function() wifi_menu.refresh(); return false end)
                    end)
                end
            end
        end),
        awful.button({ }, 3, function()
            menu_wibox.visible = false
            if mousegrabber.isrunning() then mousegrabber.stop() end
            wifi_details_panel.show(ssid, signal, security, is_active)
        end)
    ))
    return btn
end

-- Sayfalama ve Ekran Çizim Motoru
local function render_networks()
    main_layout:reset()
    wifi_menu.network_widgets = {}

    local title = wibox.widget.textbox("<span color='#FF8800'><b>Wi-Fi Ağları</b></span>")
    main_layout:add(wibox.container.margin(title, 5, 5, 0, 10))

    local total = #wifi_menu.networks_cache
    if total == 0 then return end

    local start_idx = ((wifi_menu.current_page - 1) * MAX_VISIBLE) + 1
    local end_idx = math.min(start_idx + MAX_VISIBLE - 1, total)

    -- Sadece o sayfaya ait ağları ekrana bas
    for i = start_idx, end_idx do
        local net = wifi_menu.networks_cache[i]
        main_layout:add(create_net_btn(net.ssid, net.signal, net.security, net.is_active))
    end

    -- Alt Sayfalama (Pagination) Butonları
    local total_pages = math.ceil(total / MAX_VISIBLE)
    if total_pages > 1 then
        local prev_color = wifi_menu.current_page > 1 and "#FF8800" or "#444444"
        local next_color = wifi_menu.current_page < total_pages and "#FF8800" or "#444444"
        
        local page_text = wibox.widget.textbox("<span color='#bbbbbb'>Sayfa " .. wifi_menu.current_page .. "/" .. total_pages .. "</span>")
        local prev_btn = wibox.widget.textbox("<span color='" .. prev_color .. "'><b>[ ▲ ]</b></span>")
        local next_btn = wibox.widget.textbox("<span color='" .. next_color .. "'><b>[ ▼ ]</b></span>")

        if wifi_menu.current_page > 1 then
            prev_btn:buttons(gears.table.join(awful.button({}, 1, function()
                wifi_menu.current_page = wifi_menu.current_page - 1
                render_networks()
            end)))
        end
        if wifi_menu.current_page < total_pages then
            next_btn:buttons(gears.table.join(awful.button({}, 1, function()
                wifi_menu.current_page = wifi_menu.current_page + 1
                render_networks()
            end)))
        end

        local page_layout = wibox.layout.align.horizontal()
        page_layout:set_left(prev_btn)
        page_layout:set_middle(wibox.container.place(page_text))
        page_layout:set_right(next_btn)
        
        main_layout:add(wibox.container.margin(page_layout, 15, 15, 10, 5))
    end

    local visible_count = (end_idx - start_idx) + 1
    local nav_height = (total_pages > 1) and 35 or 0
    menu_wibox.height = 40 + (visible_count * 35) + nav_height
end

function wifi_menu.set_status(ssid, msg, color)
    if wifi_menu.network_widgets[ssid] then
        wifi_menu.network_widgets[ssid]:set_markup("<span color='" .. (color or "#FF8800") .. "'><b> " .. msg .. " </b></span>")
    end
end

-- YENİ VE KUSURSUZ: UUID Tabanlı Bağlantı Kesme Fonksiyonu
function wifi_menu.disconnect_network(ssid)
    wifi_menu.set_status(ssid, "Bağlantı kesiliyor...", "#FF8800")
    
    -- 1. Aşama: Aktif Wi-Fi bağlantısının benzersiz UUID'sini buluyoruz
    local get_uuid_cmd = "sh -c \"LC_ALL=C nmcli -t -f UUID,TYPE connection show --active | grep -E '802-11-wireless|wifi' | head -n 1 | cut -d: -f1\""
    
    awful.spawn.easy_async(get_uuid_cmd, function(uuid)
        uuid = uuid:gsub("^%s*(.-)%s*$", "%1") -- Terminalin bıraktığı boşlukları/satır atlamaları temizle
        
        if uuid ~= "" then
            -- 2. Aşama: İsimle değil, doğrudan UUID ile bağlantıyı zarifçe kes
            awful.spawn.easy_async("LC_ALL=C nmcli connection down uuid '" .. uuid .. "'", function(out, err, r, code)
                if code == 0 then 
                    wifi_menu.set_status(ssid, "Bağlantı kesildi.", "#bbbbbb")
                else 
                    wifi_menu.set_status(ssid, "Hata oluştu!", "#ff0000") 
                end
                
                gears.timer.start_new(1.5, function() wifi_menu.refresh(); return false end)
            end)
        else
            wifi_menu.set_status(ssid, "Bağlantı bulunamadı!", "#ff0000")
            gears.timer.start_new(1.5, function() wifi_menu.refresh(); return false end)
        end
    end)
end

function wifi_menu.force_open()
    local s = awful.screen.focused()
    menu_wibox.x = s.geometry.x + s.geometry.width - 265
    menu_wibox.y = s.geometry.y + 52 
    menu_wibox.visible = true
end

function wifi_menu.refresh()
    main_layout:reset()
    local title = wibox.widget.textbox("<span color='#FF8800'><b>Taranıyor...</b></span>")
    main_layout:add(wibox.container.margin(title, 5, 5, 0, 10))
    menu_wibox.height = 70

    local scan_cmd = "sh -c \"LC_ALL=C nmcli -t -f active,ssid,signal,security dev wifi | awk -F':' '$2!=\\\"\\\" && !seen[$2]++'\""
    awful.spawn.easy_async(scan_cmd, function(stdout)
        local networks = {}
        local active_net = nil
        for line in stdout:gmatch("[^\r\n]+") do
            local active, ssid, signal, sec = string.match(line, "^([^:]+):([^:]+):([^:]+):(.*)")
            if ssid then
                local net_obj = {ssid = ssid, signal = signal, security = sec, is_active = (active == "yes")}
                if active == "yes" then active_net = net_obj else table.insert(networks, net_obj) end
            end
        end

        wifi_menu.networks_cache = {}
        if active_net then table.insert(wifi_menu.networks_cache, active_net) end
        for _, net in ipairs(networks) do table.insert(wifi_menu.networks_cache, net) end
        
        wifi_menu.current_page = 1
        render_networks()
    end)
end

function wifi_menu.toggle()
    if menu_wibox.visible then
        menu_wibox.visible = false
        if mousegrabber.isrunning() then mousegrabber.stop() end
    else
        wifi_menu.refresh()
        wifi_menu.force_open()
        gears.timer.delayed_call(function()
            mousegrabber.start(function(mouse)
                if mouse.buttons[1] or mouse.buttons[3] then
                    local x, y = mouse.x, mouse.y
                    if x < menu_wibox.x or x > (menu_wibox.x + menu_wibox.width) or
                       y < menu_wibox.y or y > (menu_wibox.y + menu_wibox.height) then
                        menu_wibox.visible = false
                        mousegrabber.stop()
                        return false
                    end
                end
                return menu_wibox.visible
            end, "arrow")
        end)
    end
end

return wifi_menu
