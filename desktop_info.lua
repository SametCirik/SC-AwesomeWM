local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local watch = require("awful.widget.watch")

local desktop_info = {}

function desktop_info.create(s)
    local info_box = wibox({
        screen = s,
        width = 350,
        height = 230,
        x = s.geometry.x + 50,
        y = s.geometry.y + 100,
        bg = "#111111",
        border_width = 2,
        border_color = "#FF8800",
        shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end,
        ontop = false,
        below = true,
        visible = false
    })

    -- =========================================
    -- KURBAN DAMGASI (ŞEFFAF PNG GÖRSELİ)
    -- =========================================
    local damga_widget = wibox.widget {
        image = os.getenv("HOME") .. "/.config/awesome/Awesome-Icons/BerserkMark.png",
        resize = true,
        forced_width = 90,
        forced_height = 130,
        valign = "center",
        halign = "center",
        widget = wibox.widget.imagebox
    }

    -- =========================================
    -- SİSTEM BİLGİSİ METİNLERİ
    -- =========================================
    local user_txt = wibox.widget.textbox("<span color='#FF8800' font='Courier Prime Bold 12'>Samet@ArchLinux</span>")
    local sep_txt = wibox.widget.textbox("<span color='#555555' font='Courier Prime 10'>-----------------</span>")
    local os_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime 10'><b>OS :</b> Arch Linux</span>")
    local wm_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime 10'><b>WM :</b> AwesomeWM</span>")
    local kernel_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime 10'><b>KR :</b> Yükleniyor...</span>")
    local pkg_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime 10'><b>PKG:</b> Yükleniyor...</span>")
    local up_txt = wibox.widget.textbox("<span color='#bbbbbb' font='Courier Prime 10'><b>UP :</b> Yükleniyor...</span>")

    -- =========================================
    -- VERİLERİ ÇEKME
    -- =========================================
    awful.spawn.easy_async("bash -c 'uname -r'", function(stdout)
        local kr = stdout:gsub("\n", "")
        kernel_txt:set_markup("<span color='#bbbbbb' font='Courier Prime 10'><b>KR :</b> " .. kr .. "</span>")
    end)

    awful.spawn.easy_async("bash -c 'pacman -Qq | wc -l'", function(stdout)
        local pkg = stdout:gsub("\n", "")
        pkg_txt:set_markup("<span color='#bbbbbb' font='Courier Prime 10'><b>PKG:</b> " .. pkg .. "</span>")
    end)

    watch("bash -c 'uptime -p'", 60, function(widget, stdout)
        local up = stdout:gsub("\n", "")
        up = up:gsub("up ", "")
        up_txt:set_markup("<span color='#bbbbbb' font='Courier Prime 10'><b>UP :</b> " .. up .. "</span>")
    end)

    -- =========================================
    -- KUSURSUZ HİYERARŞİK DİZİLİM
    -- =========================================
    local texts_layout = wibox.widget {
        user_txt,
        sep_txt,
        os_txt,
        wm_txt,
        kernel_txt,
        pkg_txt,
        up_txt,
        layout = wibox.layout.fixed.vertical,
        spacing = 6
    }

    info_box:setup {
        {
            {
                damga_widget,
                valign = "center",
                widget = wibox.container.place
            },
            {
                {
                    texts_layout,
                    valign = "center",
                    widget = wibox.container.place
                },
                left = 25,
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.horizontal
        },
        margins = 25,
        widget = wibox.container.margin
    }

    return info_box
end

return desktop_info
