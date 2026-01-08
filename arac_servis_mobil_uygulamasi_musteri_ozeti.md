# Araç Servis Mobil Uygulaması – Müşteri Özeti

## 1. Ne Yapıyoruz?
Müşterilerinizin araçlarıyla ilgili servis sürecini **mobil uygulama üzerinden takip edebileceği** bir sistem geliştiriyoruz.

Bu uygulama sayesinde araç sahipleri:
- Araçlarının **servisteki güncel durumunu** görebilecek
- **Bakım / servis geçmişini** inceleyebilecek
- **Servis fişi ve fatura PDF’lerine** ulaşabilecek
- Servis sürecindeki önemli aşamalarda **anlık bildirim** alacak

Amaç: Müşteri memnuniyetini artırmak, telefonla bilgi sorma ihtiyacını azaltmak ve daha profesyonel bir servis deneyimi sunmak.

---

## 2. Nasıl Çalışacak?

### Mevcut Sisteminiz
- Servis operasyonları **Delta Pro** üzerinden aynen devam eder
- Delta Pro **tek ana sistem** olmaya devam eder

### Yeni Eklenecek Yapı

#### Müşteri Sunucusu (On-Prem)
- Sunucunuza küçük bir **Bridge (bağlantı servisi)** kurulur
- Bu servis:
  - Delta veritabanını **sadece okur** (read-only)
  - Sunucunuza **dışarıdan erişim açmaz**
  - Sadece güvenli şekilde **bulut sistemine veri gönderir**

#### Bulut Sistem (Yeni)
- Tüm mobil uygulama trafiği burada yönetilir
- Araçlar, servis kayıtları ve PDF belgeler burada tutulur
- Push bildirimler buradan gönderilir

#### Mobil Uygulama (iOS / Android)
- Müşteriler sadece mobil uygulamayı kullanır
- Mobil uygulama **sizin sunucunuza doğrudan bağlanmaz**

> Özetle: Delta’da yapılan işlemler otomatik olarak mobil uygulamaya yansır.

---

## 3. Mobil Uygulamada Neler Olacak? (MVP)

### Kullanıcı Girişi
- Telefon numarası + SMS doğrulama

### Araç Bilgileri
- Plaka
- Marka / model
- **Şase (VIN) numarası**
- Güncel servis durumu

### Servis Takibi
- Serviste / İşlemde / Hazır / Teslim
- Son güncelleme zamanı

### Bakım Geçmişi
- Tarih
- KM
- Yapılan işlemler
- Değişen parçalar
- Toplam tutar

### Belgeler
- Servis fişi PDF
- Fatura PDF

### Bildirimler
- Araç servise alındı
- Araç hazır
- Araç teslim edildi

---

## 4. MVP’de Olmayan (Sonraki Aşamalar)
- Online randevu
- Online ödeme
- Ai Musteri Destegi
- Teklif onayı

> Bu özellikler, uygulama kullanımı ve ihtiyaçlara göre sonraki fazlarda eklenebilir.

---

## 5. Güvenlik ve Sistem Sınırları
- Sunucunuza **port açılmaz**
- Delta veritabanına **yazma yapılmaz**
- Mobil uygulama sadece bilgi gösterir
- Servis içi operasyonlar aynen devam eder

---

## 6. Zaman Planı (MVP)

**Toplam Süre: 6 Hafta**

Bu plan, App Store / Play Store yayın süreçleri ve Delta veritabanı analizinde yaşanabilecek belirsizlikler dikkate alınarak hazırlanmıştır.

- **1. Hafta:** Analiz & Planlama  
  - Delta Pro veritabanı yapısının incelenmesi  
  - Gerekli tabloların ve alanların netleştirilmesi  
  - Beklenmeyen veri yapıları için adaptasyon

- **2. Hafta:** Teknik Altyapı & Mimari Kurulum  
  - Bulut backend kurulumu  
  - Veritabanı şeması  
  - Bridge temel yapısı

- **3. Hafta:** Delta Entegrasyonu & Senkronizasyon  
  - Incremental veri senkronu  
  - İş emri durum akışları  
  - PDF belge aktarımı

- **4. Hafta:** Mobil Uygulama Geliştirme  
  - iOS / Android temel ekranlar  
  - Giriş, araçlar, geçmiş, PDF

- **5. Hafta:** Test & Stabilizasyon  
  - Uçtan uca testler  
  - Gerçek veri ile denemeler  
  - Hata ve performans iyileştirmeleri

- **6. Hafta:** Yayın & Canlıya Alma  
  - App Store / Play Store hazırlıkları  
  - Yayın onay süreçleri  
  - Canlı ortam kontrolleri

> Not: Mağaza onay süreçlerine bağlı olarak yayın süresi değişkenlik gösterebilir.

---

## 7. Faz 2 – AI Destekli Müşteri Soruları

### Amaç
Mobil uygulamayı kullanan müşterilerin, araçlarıyla ilgili sık sordukları sorulara **yapay zekâ destekli, anında cevap** alabilmesini sağlamak.

Bu sayede:
- Servise gelen telefon ve mesaj trafiği azalır
- Müşteri kendi aracına dair daha bilinçli olur
- Servis daha profesyonel bir deneyim sunar

---

### Müşteri Tarafında Nasıl Görünür?
Mobil uygulamada basit bir alan:

> **“Aracınızla ilgili sorunuzu yazın”**

Örnek sorular:
- “Aracıma ne işlem yapıldı?”
- “Fren balatası değişmiş mi?”
- “Bu faturadaki parça neden eklendi?”
- “Bir sonraki bakım ne zaman?”

---

### Yapay Zekâ Neye Göre Cevap Verir?
Yapay zekâ **sadece aşağıdaki verilere dayanarak** cevap üretir:
- Aracın bakım / servis geçmişi
- Yapılan işlemler ve değişen parçalar
- Servis fişi ve fatura PDF içerikleri

> Yapay zekâ genel internetten değil, yalnızca sizin sisteminizdeki verilerden konuşur.

---

### Güvenlik ve Kontrol
- Yapay zekâ **Delta Pro’ya yazma yapmaz**
- Fiyat belirlemez, karar vermez
- Riskli veya belirsiz durumlarda:
  > “Bu konuda servisimiz sizinle iletişime geçecektir.”

---

### Ne Zaman Devreye Alınır?
- MVP canlıya alındıktan sonra
- Gerçek kullanım verileri görüldükten sonra

➡️ **MVP’den yaklaşık 1–2 ay sonra** devreye alınması planlanır.

---

## 8. Sonuç
Bu proje:
- Mevcut sisteminizi bozmadan çalışır
- Müşteri memnuniyetini artırır
- Operasyonel yükü azaltır
- İleride yapay zekâ destekli gelişmiş özellikler için sağlam bir altyapı oluşturur

**Kısaca:** Serviste yapılan işlemler otomatik olarak müşterinin cebine yansır ve sorularına akıllı şekilde cevap verilir.

