#!/bin/bash

# --- Ayarlar ---
# Evrensel yol: Başka bir kullanıcı indirdiğinde kendi ev dizinini otomatik bulur
THEME="$HOME/.config/awesome/sc-rofi/themes/main.rasi"

# --- Durum Kontrolü (Kafein) ---
if [ -f "/tmp/sc-rofi-caffeine.pid" ]; then
    OPT_CAFFEINE="Kafein: AÇIK\0icon\x1fcaffeine-cup"
else
    OPT_CAFFEINE="Kafein: KAPALI\0icon\x1fcoffee"
fi

# --- Yeni Ağ Seçeneğini Ekliyoruz ---
OPT_NETWORK="Ağ Yönetimi\0icon\x1fnetwork-wireless"

# Diğer Seçenekler
OPT_AUDIO="Ses Çıkışı\0icon\x1faudio-card"
OPT_WALLPAPER="Duvar Kağıdı\0icon\x1fpreferences-desktop-wallpaper"
OPT_THEME="Tema Değiştir\0icon\x1fpreferences-desktop-theme"
OPT_POWER="Güç Menüsü\0icon\x1fsystem-shutdown"

# Menüyü Tek Satırda Birleştir (NETWORK eklendi)
MENU="$OPT_CAFFEINE\n$OPT_NETWORK\n$OPT_AUDIO\n$OPT_WALLPAPER\n$OPT_THEME\n$OPT_POWER"

# --- Rofi'yi Başlat ---
SELECTION=$(echo -e "$MENU" | rofi -dmenu -i -p "SC-ROFI" -theme "$THEME")

# --- Seçim Mantığı ---
case "$SELECTION" in
    *"Kafein:"*)
        ~/.config/awesome/sc-rofi/scripts/caffeine.sh
        ;;
    *"Ağ Yönetimi"*)
        ~/.config/awesome/sc-rofi/scripts/network.sh
        ;;
    *"Ses Çıkışı"*)
        ~/.config/awesome/sc-rofi/scripts/audio.sh
        ;;
    *"Duvar Kağıdı"*)
        ~/.config/awesome/sc-rofi/scripts/wallpaper.sh
        ;;
    *"Tema Değiştir"*)
        notify-send "SC-ROFI" "🎨 Tema (Yapım Aşamasında)"
        ;;
    *"Güç Menüsü"*)
        notify-send "SC-ROFI" "⏻ Güç (Yapım Aşamasında)"
        ;;
    *)
        exit 0
        ;;
esac
