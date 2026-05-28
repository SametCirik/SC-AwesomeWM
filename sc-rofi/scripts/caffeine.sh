#!/bin/bash

# Kilit dosyası (Durumu buradan takip edeceğiz)
LOCK_FILE="/tmp/sc-rofi-caffeine.pid"

if [ -f "$LOCK_FILE" ]; then
    # --- KAPATMA İŞLEMİ ---
    PID=$(cat "$LOCK_FILE")
    kill "$PID" 2>/dev/null
    rm "$LOCK_FILE"

    # 1. Xautolock otomatik kilidi tekrar aktif et
    xautolock -enable
    # 2. Ekran koruyucuyu ve DPMS (Ekran kararma) modunu aç
    xset s on
    xset +dpms

    # Bildirim gönder
    notify-send -u normal "SC-ROFI" "😴 Kafein Modu KAPATILDI.\nSistem normal uyku/kilit düzenine döndü." -i system-suspend
else
    # --- AÇMA İŞLEMİ ---
    
    # 1. Xautolock otomatik kilidini durdur (betterlockscreen tetiklenmez)
    xautolock -disable
    # 2. X11 ekran koruyucuyu ve ekran kararmasını (DPMS) tamamen kapat
    xset s off
    xset -dpms

    # 3. Systemd-inhibit ile donanımsal uyku modunu engelle
    systemd-inhibit --what=idle:sleep:handle-lid-switch \
                    --who="SC-ROFI" \
                    --why="Kullanıcı Kafein Modunu açtı" \
                    --mode=block \
                    sleep infinity &

    # Arka plana attığımız işlemin ID'sini dosyaya kaydet
    echo $! > "$LOCK_FILE"

    # Bildirim gönder
    notify-send -u critical "SC-ROFI" "☕ Kafein Modu AKTİF.\nEkran kapanmayacak ve sistem kilitlenmeyecek." -i caffeine-cup
fi
