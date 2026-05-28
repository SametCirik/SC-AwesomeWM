#!/bin/bash

# --- Ayarlar ---
THEME="$HOME/.config/sc-rofi/themes/main.rasi"
INTERFACE="wlo1"

# Terminal emülatörü (KDE kullandığın için konsole yazıldı. Eğer i3/Sway kullanıyorsan alacritty veya kitty olarak değiştirebilirsin.)
TERM_EXEC="konsole -e" 

# --- Ağ Alt Menüsü Seçenekleri ---
OPT_1="📡 NetworkManager'ı Yeniden Başlat"
OPT_2="🔌 wpa_supplicant'ı Yeniden Başlat"
OPT_3="🔄 Wi-Fi Kartını Sıfırla (Down/Up)"
OPT_4="🔓 RFKill Kilitlerini Kaldır"
OPT_5="🏫 GSBWIFI Gizli Ağ Onarımı"
OPT_6="🎓 Eduroam'a Bağlan"
OPT_7="🔥 SC Hotspot Başlat"

MENU="$OPT_1\n$OPT_2\n$OPT_3\n$OPT_4\n$OPT_5\n$OPT_6\n$OPT_7"

# --- Rofi Alt Menüsünü Başlat ---
SELECTION=$(echo -e "$MENU" | rofi -dmenu -i -p "AĞ MENÜSÜ" -theme "$THEME")

# --- İşlemler ---
case "$SELECTION" in
    "$OPT_1")
        $TERM_EXEC bash -c "echo 'NetworkManager yeniden başlatılıyor...'; sudo systemctl restart NetworkManager; echo 'İşlem tamamlandı.'; sleep 2"
        ;;
    "$OPT_2")
        $TERM_EXEC bash -c "echo 'wpa_supplicant yeniden başlatılıyor...'; sudo systemctl restart wpa_supplicant; sudo systemctl restart NetworkManager; echo 'İşlem tamamlandı.'; sleep 2"
        ;;
    "$OPT_3")
        $TERM_EXEC bash -c "echo 'Wi-Fi kartı sıfırlanıyor...'; sudo ip link set $INTERFACE down; sleep 1; sudo ip link set $INTERFACE up; echo 'İşlem tamamlandı.'; sleep 2"
        ;;
    "$OPT_4")
        $TERM_EXEC bash -c "echo 'RFKill kilitleri kaldırılıyor...'; sudo rfkill unblock all; echo 'İşlem tamamlandı.'; sleep 2"
        ;;
    "$OPT_5")
        $TERM_EXEC bash -c "echo 'GSBWIFI Gizli Ağ onarımı uygulanıyor...'; nmcli connection modify GSBWIFI wifi.hidden yes; nmcli connection up GSBWIFI; echo 'İşlem tamamlandı.'; sleep 2"
        ;;
    "$OPT_6")
        $TERM_EXEC bash -c "sc-eduroam"
        ;;
    "$OPT_7")
        $TERM_EXEC bash -c "sc-hotspot"
        ;;
    *)
        # Menüden ESC ile çıkılırsa ana menüye dönebilir veya tamamen kapanabilir.
        exit 0
        ;;
esac
