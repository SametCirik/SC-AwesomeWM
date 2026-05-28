# SC-AwesomeWM Rice

<p align="center">
  <img src="https://img.shields.io/badge/OS-Arch%20Linux-1793D1?logo=arch-linux&logoColor=white" alt="Arch Linux">
</p>

Bu depo, sıfırdan inşa edilmiş ve yüksek performanslı bir AwesomeWM yapılandırmasını içerir. Karanlık arayüz, neon turuncu vurgular ve Courier Prime fontu etrafında şekillenen bu  rice; estetikten ödün vermeden sistem kaynaklarını (RAM/CPU) en verimli şekilde kullanmak üzere tasarlanmıştır.

## 1. AwesomeWM nedir?

AwesomeWM, X Pencere Sistemi (X11) için geliştirilmiş, yüksek oranda yapılandırılabilir bir dinamik pencere yöneticisidir (Tilling Window Manager). 

- Diğer masaüstü ortamlarının aksine devasa arka plan servisleri barındırmaz. 

- Yapılandırması ve genişletilmesi tamamen Lua programlama dili ile yapılır. Bu sayede sistemi bir LEGO gibi parçalarına ayırıp, sadece ihtiyaç olan bileşenlerle sıfırdan kendi işletim sisteminizin arayüzünü yazmanıza olanak tanır.

## 2. Özellikler

Standart bir AwesomeWM kurulumunun çok ötesine geçerek sisteme özel widget'lar ve performans modülleri entegre ettim:

- **Dikey Dashboard Kulesi: Ekranın sol tarafına yerleştirilmiş: medya paneli, sistem bilgi paneli ve donanım monitörü.

- **Donanım Hızlandırmalı Sistem Monitörü:** CPU, RAM, Disk ve Sıcaklık değerlerini dairesel grafiklerle (arcchart) gösteren, 100°C üstü için "Meltdown" görsel uyarılı özel widget.

- **SC-Rofi Kontrol Merkezi:** AwesomeWM'in standart menüsü yerine tasarlanmış; Kafein Modu (Ekran kilitlenmesini/uykuyu engeller), Ağ, Ses ve Güç yönetimini barındıran yarı şeffaf ekran ortası arayüzü.

- **Siberpunk Rofi Başlatıcı:** Beyaz/mavi varsayılan Rofi teması yerine, sistem temasıyla %100 uyumlu, kurşun geçirmez şeffaf arama menüsü.

- **Gömülü Terminal İllüzyonu (Cava):** Masaüstüne "sabitlenmiş", pencere kenarlıkları olmayan ve müzikle senkronize dalgalanan ses spektrumu.

- **İkili Dosya Yönetimi:** Hız ve hacker estetiği arayanlar için Alacritty içine gömülü Yazi (TUI) ve standart pencereli kullanım için Thunar (GUI) entegrasyonu.

- **Performans & Zombi Koruması:** Bellek sızıntılarını ve kilitlenmeleri önlemek için sistem düzeyinde Zram (RAM sıkıştırma) ve EarlyOOM optimizasyonları yapılmıştır.

## 3. Nasıl Kurarım?

Bu rice, Arch Linux tabanlı sistemler düşünülerek hazırlanmıştır.

### Bağımlılıkları Kurun:

```bash
sudo pacman -S awesome rofi alacritty yazi thunar cava picom xautolock zram-generator earlyoom
```

### Temayı Sisteme Aktarın:

Mevcut config dosyanızın yedeğini alın ve bu repoyu klonlayın:

```bash
mv ~/.config/awesome ~/.config/awesome.bak
git clone https://github.com/SametCirik/SC-AwesomeWM.git ~/.config/awesome
```

*(AwesomeWM'i yeniden başlattığınızda tema aktif olacaktır.)*

## 4. Opsiyonel Bağımlılık Yapılandırmaları (İnce Ayarlar)

Rice'ın tam potansiyeline ulaşması ve görsel bütünlüğün bozulmaması için ek bileşenlerin ayarlarını aşağıdaki gibi senkronize edebilirsiniz:

### A. ALacritty Yapılandırılması (`~/.config/alacritty/alacritty.toml`)

Açılış font boyutunu sabitlemek ve neon turuncu imleç estetiğini yakalamak için şu TOLŞ ayarlarını kullanın:

```toml
[window]
padding = { x = 12, y = 12 }
opacity = 0.85
blur = true

[font]
normal = { family = "Courier Prime", style = "Regular" }
size = 10.0

[colors.cursor]
text = "#111111"
cursor = "#FF8800"
```

### B. Picom (Şeffaflık ve Blur) Yapılandırılması (`~/.config/picom/picom.conf`)

Pencerelerin arkasındaki bulanıklığı (blur) tam siberpunk kıvamına getirmek için Dual-Kawase algoritmasını aktif edin:

```
backend = "glx";
glx-no-stencil = true;
glx-copy-from-front = false;

# Yuvarlak Köşeler
corner-radius = 10;

# Blur Ayarları
blur-method = "dual-kawase";
blur-strength = 5;
blur-background = true;
```

### C. Cava (Ses Spekturumu) Yapılandırması (`~/.config/cava/config`)

masaüstündeki müzik dalgalarının turuncu renkle senkronize çalışması için renk kodlarını kilitleyin:

```TOML
[color]
gradient = 1
gradient_color_1 = '#FF8800'
gradient_color_2 = '#aa5500'
```

## 5. Kısayollar

Sistem tamamen klavye odaklı çalışır. Ana yönlendirici tuşunuz `Super (Windows)` tuşudur.

Kısayol             | İşlev
 ---                | ---
`Super + Return`    | Terminali açar
`Super + D`         | Uygulama Başlatıcıyı (Rofi) açar
`Super + Shift + D` | SC-Rofi kontrol Merkezini açar (Kafein, Ağ, Güç)
`Super + E`         | Tunar Dosya Yöneticisini (GUI) açar
`Super + Shift + E` | Yazi Dosya Yöneticisini (TUI) açar
`PrtScr`            | Ekran görüntüsü alır
`Super + Shift + Q` | AwesomeWM'den çıkış yapar.
`Super + CTRL + R`  | AwesomeWM'i (Temayı) yeniler.
`F1`                | Tüm kısayol listesini (Yardım Menüsü) gösterir.
`F2`                | Ekran parlaklığını azaltır.
`F3`                | Ekran parlaklığını artırır.
`F6`                | Sesi kapatır.
`F7`                | Sesi azaltır.
`F8`                | Sesi artırır.

## 6. Nasıl Silerin?

Eğer bu rice'ı silmek isterseniz;

```bash
rm -rf ~/.config/awesome
```

(Opsiyonel) Eğer yedek aldıysanız geri yükleyin:

```bash
mv ~/.config/awesome.bak ~/.config/awesome
```

Daha sonra sistem oturumunu kapatığ geri açın.

## 7. Lisans

Bu proje **MIT Lisansı** ile lisanslanmıştır. Detaylar için `LICENCE` dosyasına göz atabilirsiniz. Özgürce kullanın, bozun, parçalayın ve yeniden yapın!

## 8. Fork & Katkı

Fork serbest mi? **Kesinlikle evet!**

- Bu yapılanmayı (rice) kendi zevkinize göre çatallayabilir (fork), 

- renklerini değiştirebilir, 

- SC-Rofi için yepyeni modüller yazabilir 

- veya kendi widget'larınızı ekleyebilirsiniz. 

## 9. Aksiyon Halinde Görün!

Sistemin çalışırken nasıl göründüğünü, animasyonları, Cava senkronizasyonunu ve SC-Rofi modüllerini görmek için aşağıdaki Reddit gönderimi inceleyebilirsiniz:


