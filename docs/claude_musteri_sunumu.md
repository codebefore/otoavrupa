# Araç Servis Mobil Uygulaması
## Müşteri Sunumu

**Tarih:** 2026-01-09
**Müşteri:** OtoAvrupa
**Proje:** Araç Servis Takip Mobil Uygulaması (MVP)
**Veritabanı:** Advantage Database Server (Onaylandı)

---

## 1. Problem ve Çözüm

### 🤔 Mevcut Sorun

- Müşteriler servise telefon edip bilgi almak zorunda kalıyor
- Servis süreci şeffaf değil
- Sürekli bilgi sorusu geliyor "Aracım ne durumda?"
- Müşteri memnuniyetsizliği ve operasyonel yük

### 💡 Çözüm: Mobil Uygulama

**Müşterileriniz telefon etmek yerine uygulama üzerinden:**
- ✅ Araçlarının güncel durumunu görür
- ✅ Bakım/servis geçmişini inceler
- ✅ Servis fişi ve fatura PDF'lerine ulaşır
- ✅ Anlık bildirim alır

**Sonuç:**
- 📱 Daha fazla müşteri memnuniyeti
- 📉 Daha az telefon trafiği
- 🏆 Daha profesyonel imaj

---

## 2. Uygulama Özellikleri (MVP)

### 📱 Müşteri Ne Görecek?

| Özellik | Açıklama |
|---------|----------|
| **Telefon ile Giriş** | SMS doğrulama (OTP), şifre yok |
| **Araç Listesi** | Tüm araçlarını görür (plaka, model, şase numarası) |
| **Güncel Durum** | Serviste / İşlemde / Hazır / Teslim |
| **Bakım Geçmişi** | Tüm servis kayıtları (tarih, km, işlemler) |
| **PDF Belgeler** | Servis fişi ve faturayı indirebilir |
| **Bildirimler** | Araç servise alındı, hazır, teslim edildi |

### 🚫 MVP'de Olmayacak (İleride)

- Online randevu
- Online ödeme
- Sohbet/destek

---

## 3. Nasıl Çalışıyor?

### 🏗️ Teknik Mimari (Advantage DB ile Güncellendi)

```
Mevcut Sisteminiz                        Otomatik Sync                     Yeni Sistem
─────────────────                        ────────────                     ─────────────

┌──────────────────┐                    ┌───────────────┐              ┌──────────────────┐
│  Delta Pro       │                    │   Bridge      │              │  Mobil Uygulama  │
│  (Masaüstü)      │ ──Advantage DB──> │   (.NET 8)    │──API──>      │  (iOS + Android)│
│  Servis ekibi    │    Windows Auth     │   30 sn sync  │              │  Müşteri         │
│  kullanır        │                    │   Timestamp   │              └──────────────────┘
└──────────────────┘                    └───────────────┘
                                                ↑
                                          ┌─────┴─────┐
                                          │   VPS     │
                                          │  (Cloud)  │
                                          └───────────┘
```

### 📊 Veri Akışı

1. **Siz:** Delta Pro'da işlem yaparsınız (eski usül)
2. **Advantage DB:** Veriyi kaydeder (timestamp güncellenir)
3. **Bridge Servisi:** 30 saniyede bir değişen kayıtları çeker
4. **Bulut API:** Veriyi mobil uygulamaya iletir
5. **Müşteri:** Uygulamadan anlık durum görür

**Hiçbir ek iş yükü yok!**

### 🔧 Teknik Detaylar

| Bileşen | Teknoloji | Açıklama |
|---------|-----------|----------|
| **Veritabanı** | Advantage Database Server | Mevcut Delta Pro DB'si |
| **Bağlantı** | Windows Authentication | Güvenli erişim |
| **Sync** | Timestamp-based | Sadece değişen kayıtlar |
| **Bridge** | .NET 8 Worker Service | 30 saniyede bir sync |
| **API** | ASP.NET Core 8.0 | REST API |
| **Mobile** | Flutter | iOS + Android |
| **Push** | Firebase FCM | Ücretsiz bildirimler |

---

## 4. Güvenlik

### 🔒 Veri Güvenliği

- ✅ Advantage DB'ye **Windows Authentication** ile güvenli erişim
- ✅ Delta Pro'ya dışarıdan erişilmez (port açılmaz)
- ✅ Sadece okuma işlemi yapılır (yazma yok)
- ✅ Verileriniz güvende (şifreli iletişim)
- ✅ Müşteri sadece bilgi görür (değiştiremez)

### 🛡️ Altyapı Güvenliği

- ✅ Güvenli sunucu (VPS)
- ✅ HTTPS şifreleme
- ✅ Güvenli SMS doğrulama
- ✅ Regular backup'lar

---

## 5. Zaman Planı

### 📅 7-8 Haftada Canlıya Alıyoruz

| Hafta | Yapılacaklar |
|-------|--------------|
| **1. Hafta** | Advantage DB yapısını analiz ediyoruz |
| **2. Hafta** | Teknik altyapıyı kuruyoruz (.NET 8, API) |
| **3. Hafta** | Timestamp-based sync mekanizması |
| **4. Hafta** | Delta Pro ile entegrasyon + PDF transfer |
| **5. Hafta** | Mobil uygulama geliştirme |
| **6. Hafta** | Test ve düzeltmeler |
| **7. Hafta** | App Store'a gönderme + canlıya alma |
| **8. Hafta** | Buffer (risk yönetimi) |

**Not:** Advantage Database özel sync entegrasyonu gerektirdiği için +1-2 hafta eklendi.

---

## 6. Maliyet

### 💰 Yıllık Maliyet

| Kalem | Yıllık | Aylık |
|-------|--------|-------|
| Sunucu (VPS) | ₺5.000 | ₺420 |
| Apple Developer | ₺3.000 | ₺250 |
| Google Play | ₺800 | - |
| PDF Depolama | ₺600-1.200 | ₺50-100 |
| SMS (Güvenlik) | ₺50-200 | ₺4-17 |
| **TOPLAM** | **~₺9.500** | **~₺790** |

### 📊 Müşteri Sayısına Göre Maliyet

| Müşteri Sayısı | Yıllık | Aylık |
|---------------|--------|-------|
| 100 | ₺8.650 | ₺720 |
| **500** ⭐ | **₺9.500** | **₺790** |
| 1.000 | ₺10.900 | ₺910 |

---

## 7. Teknoloji

### 🛠️ Kullanılan Teknolojiler

| Bileşen | Teknoloji | Açıklama |
|---------|-----------|----------|
| **Mobil Uygulama** | Flutter | iOS + Android tek uygulama |
| **Bildirimler** | Firebase | Ücretsiz, güvenilir |
| **API** | .NET 8 | Modern, hızlı |
| **Database** | PostgreSQL | Güvenilir, ücretsiz |
| **PDF Depolama** | Bunny.net | Hızlı, CDN dahil |
| **SMS** | Ileti Merkezi | Türk firma, uygun fiyat |

### ✅ Ücretsiz Araçlar

- Development tools (.NET, Flutter)
- Database (PostgreSQL)
- Push notifications (Firebase)
- SSL sertifikası
- GitHub (kod deposu)

**Ücretsiz araçlar değeri:** ₺45.000+/yıl tasarruf

---

## 8. Örnek Ekranlar

### 📱 Uygulama Görünümü

#### 1. Giriş Ekranı
- Telefon numarası girilir
- SMS kodu gelir
- Otomatik giriş

#### 2. Araçlarım
- Araç listesi
- Her araç için durum bilgisi
- Şase numarası görünür

#### 3. Araç Detayı
- Araç bilgileri
- Güncel durum
- "Son güncelleme" zamanı

#### 4. Servis Geçmişi
- Tüm servis kayıtları
- Tarih, KM, işlemler
- PDF indirme

#### 5. PDF Görüntüleme
- Servis fişi
- Fatura
- İndirme/paylaşma

---

## 9. Bildirimler

### 🔔 Müşteri Ne Zaman Bildirim Alır?

| Durum | Bildirim Mesajı |
|-------|----------------|
| Araç servise alındı | "Aracınız servise alındı" |
| İşlem başladı | "Aracınızda bakım başladı" |
| Araç hazır | "Aracınız teslim almaya hazır! 🎉" |
| Araç teslim edildi | "Aracınız teslim edildi" |

Bildirimlere tıklayınca uygulama açılır ve araç detayı gösterilir.

---

## 10. İleri Özellikler (Faz 2)

### 🤖 Yapay Zeka Destekli Sohbot (İleride)

Müşteriler sorularını yazarak sorabilecek:
- "Aracıma ne işlem yapıldı?"
- "Bir sonraki bakım ne zaman?"
- "Fren balatası değişmiş mi?"

Yapay zeka **sadece araç verilerine** dayanarak cevap verecek.

**MVP'den 1-2 ay sonra** planlanıyor.

---

## 11. Sonraki Adımlar

### ✅ Başlamak İçin Ne Gerekir?

1. **Onay** - Projenizi onaylayın
2. **Delta Pro Analizi** - Sisteminizi incelememiz için erişim
3. **Başlangıç** - Development'a başlayalım

### 📞 İletişim

Her aşamada sizi bilgilendireceğiz:
- Haftalık ilerleme raporları
- Test aşamasında demo gösterimi
- Canlıya alma öncesi onay

---

## 12. Özet ve Sonuç

### 🎯 Neden Bu Proje?

| Avantaj | Açıklama |
|---------|----------|
| **Müşteri Memnuniyeti** | Şeffaf süreç, anlık bilgi |
| **Operasyonel Verimlilik** | Daha az telefon trafiği |
| **Profesyonel İmaj** | Modern teknoloji kullanımı |
| **Maliyet-Etkin** | ₺790/ay gibi makul bir maliyet |
| **Ölçeklenebilir** | 100'den 10.000 müşteriye kadar |

### 💰 Yatırım Değeri

**Yıllık Maliyet:** ₺9.500
**Aylık Maliyet:** ₺790

**Değeri:** Paha biçilemez
- Müşteri memnuniyeti
- Marka değeri
- Operasyonel verimlilik
- Rakiplerden ayrışma

### 🚀 Hazır Mısınız?

**6 haftada uygulamayı kullanıma sunuyoruz!**

- İlk hafta: Analiz
- 2-5 haftalar: Geliştirme
- 6. hafta: Yayın

**Sürecin her aşamasında sizinle birlikte çalışacağız.**

---

## Teşekkürler

**OtoAvrupa'nın dijital dönüşümüne katkıda bulunmak için heyecanlıyız!**

Sorularınız için:
- 📧 E-posta
- 📱 Telefon

---
