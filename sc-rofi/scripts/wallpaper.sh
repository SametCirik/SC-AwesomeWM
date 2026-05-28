#!/bin/bash

# --- Ayarlar ---
WALL_DIR="$HOME/.config/awesome/Awesome-Wallpapers"
THEME="$HOME/.config/awesome/sc-rofi/themes/main.rasi"

# Klasör yoksa oluştur
mkdir -p "$WALL_DIR"

# Resimleri bul ve Rofi'nin önizleme yapabilmesi için özel ikon formatına çevir
PICS=""
for img in "$WALL_DIR"/*.{jpg,jpeg,png}; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        PICS+="${filename}\0icon\x1f${img}\n"
    fi
done

# Eğer klasör boşsa uyarı ver ve çık
if [ -z "$PICS" ]; then
    notify-send -u critical "SC-ROFI" "🖼 Duvar kağıdı bulunamadı!\nLütfen $WALL_DIR içine resim ekleyin."
    exit 1
fi

# 1. AŞAMA: Duvar Kağıdını Seç (Görsel Önizlemeli)
SELECTION=$(echo -e "$PICS" | rofi -dmenu -i -p "/> DUVAR KAGIDI" -theme "$THEME")

# Eğer bir seçim yapıldıysa işlemlere başla
if [ -n "$SELECTION" ]; then
    SELECTED_PATH="$WALL_DIR/$SELECTION"
    
    # 2. AŞAMA: Nereye uygulanacağını sor
    TARGET_OPTIONS="1. Ana Ekran\n2. Kilit Ekranı (Dimblur)\n3. Her İkisi de"
    TARGET=$(echo -e "$TARGET_OPTIONS" | rofi -dmenu -i -p "/> HEDEF" -theme "$THEME")

    case "$TARGET" in
        *"Ana Ekran"*)
            cp "$SELECTED_PATH" "$WALL_DIR/current_wallpaper"
            awesome-client "
            local gears = require('gears')
            for s in screen do
                gears.wallpaper.maximized('$SELECTED_PATH', s, true)
            end"
            notify-send -u normal "SC-ROFI" "🖼 Ana Ekran Güncellendi:\n$SELECTION"
            ;;
        *"Kilit Ekranı"*)
            notify-send -u normal "SC-ROFI" "🔒 Kilit Ekranı Hazırlanıyor...\nBu işlem birkaç saniye sürebilir."
            # Betterlockscreen'in önbelleğini yeni resimle günceller
            betterlockscreen -u "$SELECTED_PATH"
            notify-send -u normal "SC-ROFI" "🔒 Kilit Ekranı Güncellendi!"
            ;;
        *"Her İkisi de"*)
            cp "$SELECTED_PATH" "$WALL_DIR/current_wallpaper"
            awesome-client "
            local gears = require('gears')
            for s in screen do
                gears.wallpaper.maximized('$SELECTED_PATH', s, true)
            end"
            notify-send -u normal "SC-ROFI" "🖼/🔒 Her İkisi Güncelleniyor...\nKilit ekranı önbelleğe alınıyor, lütfen bekleyin."
            betterlockscreen -u "$SELECTED_PATH"
            notify-send -u normal "SC-ROFI" "✅ Tüm Ekranlar Güncellendi!"
            ;;
    esac
fi
