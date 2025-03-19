# Sanallaştırma Sunucusu VM Listesi Projesi

**Yazar:** A. Kerem Gök

## Proje Hakkında

Bu proje, ESXi ve Proxmox sanallaştırma sunucularındaki sanal makinelerin (VM) bilgilerini toplayıp web arayüzünde görüntülemeyi sağlar. Sunucudaki VM'lerin durumları, özellikleri ve IP adresleri gibi önemli bilgileri JSON formatında alıp, kullanıcı dostu bir tablo halinde gösterir.

## Dosyalar

### 1. esxi-to-php.sh
ESXi sunucusundan VM bilgilerini toplayan bash script'i.
- VM ID ve isim bilgileri
- Güç durumu (açık/kapalı)
- İşletim sistemi tipi
- Donanım versiyonu
- CPU ve RAM bilgileri
- Toplam disk boyutu (GB)
- IP adresleri

### 2. proxmox-to-php.sh
Proxmox sunucusundan VM bilgilerini toplayan bash script'i.
- VM ID ve isim bilgileri
- Güç durumu (running/stopped)
- İşletim sistemi tipi
- CPU ve RAM bilgileri
- Toplam disk boyutu (GB)
- IP adresleri (QEMU agent üzerinden)

### 3. show_vms.php
VM bilgilerini web arayüzünde gösteren PHP script'i.
- Responsive tasarım
- Renkli durum göstergeleri
- Kolay okunabilir tablo formatı
- Otomatik güncelleme zamanı

## Gereksinimler

### ESXi Sunucusu İçin
- SSH erişimi
- Root yetkisi
- `vim-cmd` komut erişimi
- `curl` paketi

### Proxmox Sunucusu İçin
- SSH erişimi
- Root yetkisi
- Aşağıdaki paketler:
  ```bash
  apt-get install jq curl bc
  ```
- QEMU guest agent (IP bilgileri için)

### Web Sunucusu İçin
- PHP 7.0 veya üzeri
- Apache2/Nginx
- POST isteklerine izin verilmesi

## Kurulum

1. Web sunucunuza `show_vms.php` dosyasını yükleyin.

2. Bash script'lerini sunucularınıza yükleyin:
   ```bash
   # ESXi için
   chmod +x esxi-to-php.sh
   
   # Proxmox için
   chmod +x proxmox-to-php.sh
   ```

3. Script'lerdeki `PHP_URL` değişkenini kendi web sunucunuzun adresiyle güncelleyin:
   ```bash
   PHP_URL="http://your-web-server/show_vms.php"
   ```

## Kullanım

### ESXi Sunucusunda
```bash
./esxi-to-php.sh
```

### Proxmox Sunucusunda
```bash
./proxmox-to-php.sh
```

## Özellikler

- Otomatik veri toplama
- JSON formatında veri aktarımı
- Responsive web arayüzü
- Renkli durum göstergeleri
- Kolay okunabilir tablo formatı
- Çoklu IP adresi desteği
- Otomatik boyut dönüşümleri (MB/GB/TB)

## Güvenlik Notları

1. Script'leri root yetkisiyle çalıştırın
2. Web sunucunuzda güvenlik önlemlerini alın
3. Hassas bilgileri gizleyin
4. Güvenli SSL bağlantısı kullanın

## Hata Giderme

1. IP adresleri görünmüyorsa:
   - VM'nin açık olduğundan emin olun
   - VMware Tools/QEMU agent'ın yüklü olduğunu kontrol edin
   - Ağ bağlantısını kontrol edin

2. Script çalışmıyorsa:
   - Yetkileri kontrol edin
   - Gerekli paketlerin yüklü olduğunu doğrulayın
   - Log dosyalarını kontrol edin

## Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun
3. Değişikliklerinizi commit edin
4. Branch'inizi push edin
5. Pull request oluşturun

## Lisans

Bu proje MIT lisansı altında lisanslanmıştır. 