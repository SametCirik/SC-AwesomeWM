#!/bin/bash

# 1. Ses kartlarını listele (ID ve Açıklama)
SINKS=$(pactl list sinks | grep -E 'Sink #|Description:' | sed 's/Sink #//' | sed 's/Description: //' | xargs -n2 -d'\n' | awk -F' ' '{print $1 " | " substr($0, index($0,$2))}')

if [ -z "$SINKS" ]; then
    notify-send "SC-ROFI" "⚠️ Hiçbir ses cihazı bulunamadı!"
    exit 1
fi

# 2. Rofi ile seçim yaptır
# DÜZELTME: Ayarları değişkene atmak yerine doğrudan buraya yazdık.
SELECTED=$(echo "$SINKS" | rofi -dmenu -i -p "🔊 Ses Çıkışı" \
    -theme-str 'window {fullscreen:false; width:600px;}' \
    -theme-str 'listview {columns:1; lines:4;}')

if [ -n "$SELECTED" ]; then
    # 3. Seçilen satırdan ID'yi ayıkla (İlk sütun ID'dir)
    SINK_ID=$(echo "$SELECTED" | awk '{print $1}')
    # Cihaz ismini al (Sadece bildirimde güzel görünsün diye)
    DEVICE_NAME=$(echo "$SELECTED" | cut -d'|' -f2-)

    # 4. Varsayılan ses çıkışını değiştir
    pactl set-default-sink "$SINK_ID"
    
    # 5. Çalan müzikleri de yeni cihaza taşı (Stream move)
    pactl list sink-inputs short | cut -f1 | while read stream; do
        pactl move-sink-input "$stream" "$SINK_ID"
    done

    notify-send "SC-ROFI" "🎧 Ses Değişti: $DEVICE_NAME" -i audio-volume-high
fi
