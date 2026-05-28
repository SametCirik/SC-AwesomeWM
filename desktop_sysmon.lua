local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")

local desktop_sysmon = {}

function desktop_sysmon.create(s)
    local sys_box = wibox({
        screen = s,
        width = 720,
        height = 350, -- Metinlerin kesilmesini engellemek için yüksekliği koruduk
        x = s.geometry.x + 50,
        y = s.geometry.y + 690,
        bg = "#111111",
        border_width = 2,
        border_color = "#FF8800",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end,
        ontop = false,
        below = true,
        visible = false
    })

    local title = wibox.widget.textbox("<span color='#FF8800' font='Courier Prime Bold 16'>[ DONANIM MONİTÖRÜ ]</span>")

    local function create_radial_widget(label_text, icon_path)
        local label = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime Bold 12'><b>" .. label_text .. "</b></span>")
        local value_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime Bold 13'>0%</span>")
        
        local icon = wibox.widget {
            image = gears.color.recolor_image(icon_path, "#555555"),
            resize = true,
            forced_width = 45,
            forced_height = 45,
            widget = wibox.widget.imagebox
        }

        -- DOĞRU WIDGET: wibox.container.arcchart
        local radial = wibox.widget {
            {
                icon,
                valign = "center",
                halign = "center",
                widget = wibox.container.place
            },
            max_value = 100,
            value = 0,
            thickness = 12, -- Grafik çizgi kalınlığı
            start_angle = 1.5 * math.pi, -- Saat 12 yönünden başlar
            rounded_edge = true, -- Çember uçlarını yumuşatır
            bg = "#222222", -- Dolmamış arka plan rengi
            colors = {"#FF8800"}, -- Dolu kısım rengi
            widget = wibox.container.arcchart
        }

        -- Çemberin boyutlarını net olarak sabitleyen kısıtlayıcı (Constraint)
        local radial_constrained = wibox.widget {
            radial,
            strategy = "exact",
            width = 130,
            height = 130,
            widget = wibox.container.constraint
        }

        local layout = wibox.widget {
            {
                label,
                valign = "center",
                halign = "center",
                widget = wibox.container.place
            },
            {
                radial_constrained,
                top = 10,
                bottom = 10,
                widget = wibox.container.margin
            },
            {
                value_txt,
                valign = "center",
                halign = "center",
                widget = wibox.container.place
            },
            layout = wibox.layout.fixed.vertical
        }

        return layout, radial, value_txt, icon
    end

    local icons_path = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/"
    local cpu_icon = icons_path .. "Cpu.png"
    local ram_icon = icons_path .. "Ram.png"
    local disk_icon = icons_path .. "Disk.png"
    local temp_icon = icons_path .. "Temp.png"

    local cpu_layout, cpu_radial, cpu_val, cpu_ico = create_radial_widget("CPU", cpu_icon)
    local ram_layout, ram_radial, ram_val, ram_ico = create_radial_widget("RAM", ram_icon)
    local disk_layout, disk_radial, disk_val, disk_ico = create_radial_widget("DISK", disk_icon)
    local temp_layout, temp_radial, temp_val, temp_ico = create_radial_widget("TEMP", temp_icon)

    local monitors_centered = wibox.widget {
        {
            cpu_layout,
            ram_layout,
            disk_layout,
            temp_layout,
            spacing = 45, 
            layout = wibox.layout.fixed.horizontal
        },
        halign = "center",
        widget = wibox.container.place
    }

    sys_box:setup {
        {
            {
                title,
                halign = "center",
                widget = wibox.container.place
            },
            monitors_centered,
            layout = wibox.layout.fixed.vertical,
            spacing = 20
        },
        margins = 25,
        widget = wibox.container.margin
    }
    
    watch([[bash -c "vmstat 1 2 | tail -1 | awk '{print 100 - $15}'"]], 2, function(widget, stdout)
        local cpu = tonumber(stdout) or 0
        cpu_radial.value = cpu
        cpu_val:set_markup("<span color='#bbbbbb' font='Courier Prime Bold 13'>" .. cpu .. "%</span>")
    end)

    watch([[bash -c "free | grep Mem | awk '{print int($3/$2 * 100)}'"]], 5, function(widget, stdout)
        local ram = tonumber(stdout) or 0
        ram_radial.value = ram
        ram_val:set_markup("<span color='#bbbbbb' font='Courier Prime Bold 13'>" .. ram .. "%</span>")
    end)

    watch([[bash -c "df / | tail -1 | awk '{print $5}' | sed 's/%//'"]], 60, function(widget, stdout)
        local disk = tonumber(stdout) or 0
        disk_radial.value = disk
        disk_val:set_markup("<span color='#bbbbbb' font='Courier Prime Bold 13'>" .. disk .. "%</span>")
    end)

    -- TEMP: Sistem termal sensöründen okur (Her 5 saniyede bir)
    watch([[bash -c "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"]], 5, function(widget, stdout)
        local temp = tonumber(stdout) or 0
        temp = math.floor(temp / 1000) 
        
        -- 100 DERECE ÜSTÜ "ÇEKİRDEK ERİMESİ" (MELTDOWN) SENARYOSU
        if temp > 100 then
            temp_radial.max_value = 200
            temp_radial.bg = "#FF8800" -- Arka plan turuncu olur
            temp_radial.colors = {"#ff0000"} -- İlerleyen grafik kırmızı olur
            temp_val:set_markup("<span color='#ff0000' font='Courier Prime Bold 13'>" .. temp .. "°C</span>")
            temp_ico.image = gears.color.recolor_image(temp_icon, "#ff0000")
            
        -- 80-100 DERECE ARASI TEHLİKE UYARISI
        elseif temp >= 80 then
            temp_radial.max_value = 100
            temp_radial.bg = "#222222" -- Arka plan normale (gri/siyah) döner
            temp_radial.colors = {"#ff0000"}
            temp_val:set_markup("<span color='#ff0000' font='Courier Prime Bold 13'>" .. temp .. "°C</span>")
            temp_ico.image = gears.color.recolor_image(temp_icon, "#ff0000")
            
        -- 80 DERECE ALTI NORMAL KULLANIM
        else
            temp_radial.max_value = 100
            temp_radial.bg = "#222222"
            temp_radial.colors = {"#FF8800"}
            temp_val:set_markup("<span color='#bbbbbb' font='Courier Prime Bold 13'>" .. temp .. "°C</span>")
            temp_ico.image = gears.color.recolor_image(temp_icon, "#555555")
        end
        
        temp_radial.value = temp
    end)

    return sys_box
end

return desktop_sysmon
