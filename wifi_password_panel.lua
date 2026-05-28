local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")

local pwd_panel = {}

-- Şifre giriş panelinin kendisi
local panel = wibox({
    width = 250,
    height = 95,
    ontop = true,
    visible = false,
    bg = beautiful.wibar_bg or "#111111",
    border_width = beautiful.wibar_border_width or 2,
    border_color = beautiful.wibar_border_color or "#FF8800",
    shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
})

-- Panel içindeki araçlar
local title_text = wibox.widget.textbox()
local prompt_text = wibox.widget.textbox()

local prompt_bg = wibox.widget {
    {
        prompt_text,
        margins = 5,
        widget = wibox.container.margin
    },
    bg = "#222222",
    shape = gears.shape.rounded_rect,
    widget = wibox.container.background
}

local cancel_btn = wibox.widget.textbox("<span color='#bbbbbb'>[ İptal ]</span>")
cancel_btn:connect_signal("mouse::enter", function() cancel_btn:set_markup("<span color='#ff0000'><b>[ İptal ]</b></span>") end)
cancel_btn:connect_signal("mouse::leave", function() cancel_btn:set_markup("<span color='#bbbbbb'>[ İptal ]</span>") end)

local function close_panel()
    panel.visible = false
    awful.keygrabber.stop()
end

cancel_btn:buttons(gears.table.join(awful.button({ }, 1, close_panel)))

panel:setup {
    layout = wibox.layout.align.vertical,
    wibox.container.margin(title_text, 10, 10, 10, 5),
    wibox.container.margin(prompt_bg, 10, 10, 0, 5),
    {
        layout = wibox.layout.align.horizontal,
        nil, nil,
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.container.margin(cancel_btn, 0, 15, 5, 10)
        }
    }
}

-- Şifre sorma panelini ekrana getiren ve bağlantıyı yapan alt fonksiyon
local function show_prompt(ssid)
    title_text:set_markup("<span color='#FF8800'><b> Şifre: </b>" .. ssid .. "</span>")
    
    local s = awful.screen.focused()
    panel.x = s.geometry.x + s.geometry.width - 265
    panel.y = s.geometry.y + 46
    panel.visible = true

    awful.prompt.run {
        prompt = "<b>> </b>",
        textbox = prompt_text,
        bg_cursor = "#FF8800",
        exe_callback = function(password)
            close_panel()
            naughty.notify({ title = "Wi-Fi", text = ssid .. " ağına şifre ile bağlanılıyor..." })
            
            -- Yeni şifreyi dener, hata verirse bozuk profili anında siler!
            awful.spawn.easy_async("LC_ALL=C nmcli dev wifi connect '" .. ssid .. "' password '" .. password .. "'", function(out, err, r, code)
                if code == 0 then
                    naughty.notify({ title = "Wi-Fi", text = "Bağlantı başarılı: " .. ssid, preset = naughty.config.presets.low })
                else
                    awful.spawn("nmcli connection delete '" .. ssid .. "'")
                    naughty.notify({ title = "Wi-Fi", text = "Bağlantı başarısız! Şifre yanlış.", preset = naughty.config.presets.critical })
                end
            end)
        end,
        done_callback = close_panel
    }
end

-- ANA MANTIK
function pwd_panel.connect(ssid)
    -- 1. Bu ağ profili sistemde kayıtlı mı?
    local check_known_cmd = "sh -c \"LC_ALL=C nmcli -g NAME connection | grep -Fx '" .. ssid .. "'\""
    
    awful.spawn.easy_async(check_known_cmd, function(stdout, stderr, reason, exit_code)
        if exit_code == 0 then
            naughty.notify({ title = "Wi-Fi", text = ssid .. " (Kayıtlı Ağ)\nBağlanılıyor..." })
            
            -- 2. Kayıtlıysa bağlanmayı dene.
            awful.spawn.easy_async("LC_ALL=C nmcli connection up '" .. ssid .. "'", function(out, err, r, code)
                if code == 0 then
                    naughty.notify({ title = "Wi-Fi", text = "Bağlantı başarılı: " .. ssid, preset = naughty.config.presets.low })
                else
                    -- 3. HATA: Kayıtlı ama bağlanamadı! Yanlış şifre olabilir.
                    -- Bozuk profili sil ve yeni şifre panelini zorla aç!
                    awful.spawn("nmcli connection delete '" .. ssid .. "'")
                    naughty.notify({ title = "Wi-Fi", text = "Kayıtlı şifre hatalı!\nLütfen şifreyi tekrar girin.", preset = naughty.config.presets.critical })
                    show_prompt(ssid)
                end
            end)
        else
            -- Ağ kayıtlı değil, güvenlik protokolüne bak:
            local check_sec_cmd = "sh -c \"LC_ALL=C nmcli -t -f SSID,SECURITY dev wifi | grep -F '" .. ssid .. ":'\""
            awful.spawn.easy_async(check_sec_cmd, function(out)
                if out:match("WPA") or out:match("WEP") or out:match("802") then
                    -- Yeni şifreli ağ, paneli aç
                    show_prompt(ssid)
                else
                    -- Şifresiz açık ağ
                    naughty.notify({ title = "Wi-Fi", text = ssid .. " (Açık Ağ)\nBağlanılıyor..." })
                    awful.spawn.easy_async("LC_ALL=C nmcli dev wifi connect '" .. ssid .. "'", function(o, e, r, code)
                        if code == 0 then
                            naughty.notify({ title = "Wi-Fi", text = "Bağlantı başarılı: " .. ssid, preset = naughty.config.presets.low })
                        else
                            naughty.notify({ title = "Wi-Fi", text = "Bağlantı başarısız oldu.", preset = naughty.config.presets.critical })
                        end
                    end)
                end
            end)
        end
    end)
end

return pwd_panel
