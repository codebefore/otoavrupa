# Proje Analizi ve Değerlendirme
## Araç Servis Mobil Uygulama Sistemi

**Analiz Tarihi:** 2026-01-08
**Son Güncelleme:** 2026-01-08 (Müşteri görüşmesi sonrası)

**Analiz Edilen Dokümanlar:**
- `arac_servis_mobil_uygulamasi_musteri_ozeti.md`
- `mobil_uygulama_ekranlari_ui_ux_prompt_mvp.md`
- `teknik_analiz_on_prem_bridge_cloud_mobile.md`

**Müşteri Bilgileri:**
- **Firma:** otoavrupa (Bursa'da araç servisi)
- **Mevcut Sistem:** Delta Pro (Masaüstü uygulaması, local server'da çalışıyor)
- **Infrastructure:** Arkadaşının sağlayacağı VPS (Delta DB kopyası burada olacak)

---

## 1. Projenin Özeti

Bu proje, otoavrupa için **müşteri odaklı bir araç servis takip uygulaması** geliştirmeyi hedefliyor. Sistem, mevcut Delta Pro yazılımını bozmadan, müşterilere mobil uygulama üzerinden araçlarının servis durumunu göstermeyi amaçlıyor.

### İş Problemi
- Müşteriler servise telefon edip bilgi almak zorunda kalıyor
- Servis süreci şeffaf değil
- Müşteri memnuniyetsizliği ve operasyonel yük

### Çözüm Yaklaşımı
- **Non-invasive:** Mevcut Delta Pro sistemine dokunulmuyor
- **Read-only:** Mobil uygulama sadece veri okuyor
- **Hybrid mimari:** On-prem Bridge + Cloud Backend + Mobile App

---

## 2. Mimari Analiz

### 2.1. Dört Katmanlı Yapı

```
┌─────────────────────────────────────────────────────────────┐
│  Delta Pro (On-Prem)                                        │
│  - Tek yazan sistem (source of truth)                       │
│  - İş emri, bakım, parça, fatura kayıtları                  │
└────────────────────────┬────────────────────────────────────┘
                         │ Read-only erişim
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Bridge (On-Prem)                                           │
│  - Windows Service / daemon                                 │
│  - 10-30 sn'de bir Delta DB'yi tarar                        │
│  - Değişen kayıtları Cloud Backend'e gönderir               │
│  - Outbound HTTPS (443) sadece                              │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS + Token
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Cloud Backend                                              │
│  - REST API                                                 │
│  - Veritabanı (Postgres vb.)                                │
│  - Dosya storage (S3)                                       │
│  - Push notification servisi                                │
│  - (Faz 2) AI servisi                                       │
└────────────────────────┬────────────────────────────────────┘
                         │ REST API
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  Mobile App (iOS / Android)                                 │
│  - Telefon + OTP ile giriş                                  │
│  - Araç listesi, servis durumu, geçmiş, PDF                │
│  - Sadece okuma işlemi                                      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2. Veri Akışı

1. **Servis personeli** Delta Pro'da iş emri oluşturur/durum değiştirir
2. **Bridge**, Delta DB'yi tarar → değişiklikleri tespit eder
3. **Bridge**, değişiklikleri Cloud Backend'e gönderir
4. **Cloud Backend**, veriyi kaydeder → Push notification tetikler
5. **Mobil Uygulama**, kullanıcıya bilgi gösterir

### 2.3. Güvenlik Modeli

| Bileşen | Güvenlik Katmanı |
|---------|-----------------|
| Delta → Bridge | Read-only DB user |
| Bridge → Cloud | Token-based auth + TLS |
| Mobile → Cloud | OTP + Access token |
| On-prem Sunucu | **Port açılmaz** (sadece outbound) |

**Güçlü Yönler:**
- Müşteri sunucusuna dış erişim açılmıyor
- Delta veritabanına yazma yapılmıyor
- Bridge inbound connection kabul etmiyor

**Potansiyel Riskler:**
- Bridge'in düştüğü durumda veri senkronizasyonu durur
- Cloud backend'in failover mekanizması belirtilmemiş
- PDF'lerin büyüklüğü ve storage maliyeti hesaplanmamış

### 2.4. Güncellenmiş Mimari (Gerçek Senaryo - 2026-01-08)

**Müşteri görüşmesinde öğrenilenlere göre güncellenmiş mimari:**

```
┌─────────────────────────────────────────────────────────┐
│  Müşteri Ofisi (Bursa)                                  │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Local Server (Windows)                             │ │
│  │ ├── Delta Pro (Masaüstü Uygulaması)               │ │
│  │ └── Delta Database (Production DB)                 │ │
│  │     - İş emri, bakım, parça, fatura kayıtları     │ │
│  │     - PDF dosyaları                                │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                        ↓
                  (Replication/Sync Mekanizması)
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Arkadaşının VPS'i (Sanal Sunucu)                       │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Delta Database Kopyası (Replica)                   │ │
│  │ - Production DB'nin read-only kopyası              │ │
│  │ - Senkronize (real-time veya periodic)            │ │
│  │                                                     │ │
│  │ Bridge Service                                      │ │
│  │ - Replica DB'yi okur                              │ │
│  │ - Değişiklikleri tespit eder                       │ │
│  │ - Cloud Backend'e gönderir                        │ │
│  │ - Outbound HTTPS (443)                            │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
                        ↓
                   HTTPS + Token
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Cloud Backend (AWS/Azure/GCP)                          │
│  - REST API                                             │
│  - Veritabanı (Postgres vb.)                            │
│  - Storage (S3 - PDF'ler için)                         │
│  - Push notification servisi                            │
│  - (Faz 2) AI servisi                                   │
└─────────────────────────────────────────────────────────┘
                        ↓
                   REST API
                        ↓
┌─────────────────────────────────────────────────────────┐
│  Mobile App (iOS / Android)                             │
│  - Telefon + OTP ile giriş                              │
│  - Araç listesi, servis durumu, geçmiş, PDF            │
│  - Sadece okuma işlemi                                  │
└─────────────────────────────────────────────────────────┘
```

### 2.5. Güncellenmiş Veri Akışı

1. **Servis personeli**, Delta Pro masaüstü uygulamasında iş emri oluşturur/durum değiştirir
2. **Production DB**, değişiklikleri kaydeder
3. **Replication mekanizması**, değişiklikleri VPS'teki replica DB'ye kopyalar
4. **Bridge**, VPS'teki replica DB'yi tarar → değişiklikleri tespit eder
5. **Bridge**, değişiklikleri Cloud Backend'e gönderir (PDF metadata'sı ile)
6. **Cloud Backend**, veriyi kaydeder → Push notification tetikler
7. **Mobil Uygulama**, kullanıcıya bilgi gösterir

### 2.6. Bu Yaklaşımın Avantajları

✅ **Production DB korunur** - Müşteri local server'ı yorulmaz
✅ **Güvenli** - Production DB'ye remote erişim açılmaz
✅ **Isolation** - Bridge problemi müşteri işlerini etkilemez
✅ **Scalable** - VPS'te Bridge rahatça ölçeklenebilir
✅ **Flexible deployment** - VPS'te Docker/native service easily deploy edilebilir
✅ **Cost effective** - Müşteri altyapısına yatırım gerekmez

### 2.7. Bu Yaklaşımın Riskleri

⚠️ **Replication complexity** - DB replication kurulumu ve monitoring
⚠️ **Sync delay** - Replica DB'nin ne kadar gecikmeli olacağı belirsiz
⚠️ **VPS dependency** - Bridge için ek bir infrastructure var
⚠️ **PDF transfer** - PDF'ler production'dan replica'ya nasıl gelecek?
⚠️ **Single point of failure** - VPS çökerse ne olur?

---

## 3. MVP Kapsamı Analizi

### 3.1. MVP'de Olan Özellikler

✅ **Kullanıcı Girişi**
- Telefon numarası + SMS doğrulama (OTP)
- Şifre yok, kayıt formu yok

✅ **Araç Bilgileri**
- Plaka, marka/model, **Şase (VIN) numarası**
- Güncel servis durumu

✅ **Servis Takibi**
- Durumlar: Serviste / İşlemde / Hazır / Teslim
- Son güncelleme zamanı

✅ **Bakım Geçmişi**
- Tarih, KM, yapılan işlemler, değişen parçalar, tutar

✅ **Belgeler**
- Servis fişi PDF
- Fatura PDF

✅ **Bildirimler**
- Araç servise alındı
- Araç hazır
- Araç teslim edildi

### 3.2. MVP'de Olmayan Özellikler

❌ Online randevu
❌ Online ödeme
❌ AI müşteri desteği (Faz 2)
❌ Teklif onayı

### 3.3. MVP Kapsamı Değerlendirmesi

**Artı Yönler:**
- Kapsam net ve sınırlı
- Core value proposition'a odaklanmış
- Technical complexity kontrol altında

**Eksik Yönler:**
- Kullanıcı profili yönetimi yok (profil düzenleme, araç ekleme isteği vb.)
- Bildirim tercihleri belirtilmemiş
- Multi-language support düşünülmüş (Türkçe varsayılan)

---

## 4. UI/UX Analizi

### 4.1. Ekranlar

1. **Login Screen** - OTP ile giriş
2. **Vehicles List** - Araç kartları (plaka, model, VIN, durum)
3. **Vehicle Detail** - Seçili araç detayı
4. **Service History** - Geçmiş servis kayıtları listesi
5. **Service Detail** - Tek servis kaydı detayı
6. **Documents** - PDF listesi ve viewer
7. **Notifications Flow** - Push notification UX

### 4.2. UX Prensipleri

- **No editing:** Kullanıcı veri giremez
- **Status visibility:** Durum net görünmeli
- **"Last updated" timestamp:** Beklenti yönetimi
- **Max 3 taps:** Her bilgiye max 3 tıklamada ulaşılmalı

### 4.3. UX Eksiklikleri

⚠️ **Eksik:**
- Loading state tasarımı yok
- Error state tasarımı yok
- Offline senaryo düşünülmüş mü?
- Pull-to-refresh mekanizması belirtilmemiş
- PDF download progress görünmeli

⚠️ **UX Risk:**
- 10-30 sn gecikme kullanıcıya nasıl anlatılacak?
- "Son güncelleme" zamanı kullanıcıyı şaşırtabilir (neden böyle gecikmeli?)

---

## 5. Zaman Planı Analizi

### 5.1. 6 Haftalık Plan

| Hafta | Aktivite | Risk Seviyesi |
|-------|----------|--------------|
| 1 | Delta Pro DB analizi | ⚠️ Yüksek - yapı belirsiz |
| 2 | Cloud Backend + mimari | Orta |
| 3 | Delta entegrasyonu + senkron | ⚠️ Yüksek - PDF aktarımı |
| 4 | Mobil uygulama geliştirme | Orta |
| 5 | Test + stabilizasyon | Orta |
| 6 | Yayın + store onayı | ⚠️ Yüksek - değişken |

### 5.2. Zaman Planı Değerlendirmesi

**Gerçekçi Yönler:**
- App Store / Play Store onayı için 1 hafta ayrılmış
- Delta DB analizi için zaman tanınmış
- Test fazı dahil edilmiş

**Tehlikeli Yönler:**
- Bridge geliştirme + deploy süresi küçümsenmiş olabilir
- PDF formatı ve parsing süresi hesaplanmamış
- Cloud backend scalability testleri için zaman yok

**Öneri:**
- Hafta 3 ve 4 arasına **"Delta ile gerçek senkron test"** eklmeli
- Hafta 5'e **"performance test"** eklenmeli
- **Buffer zone** olarak 1 hafta eklenmeli

---

## 6. Teknik Riskler ve Belirsizlikler

### 6.1. Yüksek Riskli Alanlar

🔴 **Delta Pro Veritabanı Yapısı**
- DB tipi bilinmiyor (MSSQL/Oracle/MySQL?)
- Tablo isimleri, ilişkiler belirsiz
- İş emri durum flow'u bilinmiyor
- PDF storage konumu belirsiz
- **Yeni:** DB'nin hangi edition olduğu (Express/Standard/Enterprise?)

🔴 **Database Replication Mekanizması**
- **Production → Replica nasıl senkronize olacak?**
  - SQL Server Transactional Replication mı?
  - Periodic backup/restore mu?
  - Custom sync script mi?
- **Eğer SQL Server Express ise:** Native replication yok, custom solution gerekir
- **Replication delay:** Real-time (saniye) mı, periodic (dakika/saat) mi?
- **Conflict resolution:** Production ve replica çakışması nasıl handled?
- **Monitoring:** Replication status nasıl monitor edilecek?

🔴 **VPS ve Bridge Deployment**
- **VPS specifications belirsiz:**
  - OS (Windows/Linux)?
  - CPU/RAM/SSD kapasitesi?
  - Network bandwidth?
  - Static IP?
- **Bridge deployment:**
  - Docker container mı, native service mi?
  - Crash recovery nasıl olacak?
  - Update mekanizması nasıl?
  - Log monitoring?

🔴 **PDF Transfer ve Storage**
- **Production'dan replica'ya PDF nasıl gelecek?**
  - DB replication ile birlikte mi?
  - Ayrı bir file sync mekanizması mı?
  - VPS'te disk storage yeterli mi?
- **PDF boyutları:** Toplam ne kadar storage?
- **PDF lifecycle:** Eski PDF'ler ne zaman silinecek?
- **S3 storage cost:** Tahmini aylık maliyet?

### 6.2. Orta Riskli Alanlar

⚠️ **Senkronizasyon Gecikmesi**
- 10-30 saniye kabul edilebilir mi?
- Real-time notification beklentisi var mı?
- Bridge'in çalışmadığı dönemde veri kaybı?

⚠️ **Push Notification**
- Hangi provider? (Firebase/Apple)
- Notification rate limitleri?
- Kullanıcı notification preference'leri?

⚠️ **Mobil Framework Seçimi**
- React Native? Flutter? Native?
- Cross-platform trade-off'leri?
- PDF rendering library kalitesi?

### 6.3. Düşük Riskli Alanlar

✅ **Authentication (OTP)**
- Standard pattern, mature libraries
✅ **REST API**
- Well-understood pattern
✅ **Cloud Database**
- Mature solutions (Postgres, etc.)

---

## 7. Eksik Teknik Kararlar

### 7.1. Acilen Karar Verilmesi Gerekenler (Öncelik Sırasıyla)

❓ **1. Delta Pro Database Detayları (En Kritik)**
- **Database tipi:** SQL Server / MySQL / PostgreSQL / SQLite?
- **Edition:** Express / Standard / Enterprise? (Replication için kritik)
- **Version:** 2019 / 2022 / başka?
- **Tablo yapısı:** Hangi tablolar var? İş emri hangi tabloda?
- **PDF storage:** DB içinde mi, disk dosyası mı?
- **Approximate size:** DB boyutu kaç GB?

❓ **2. VPS Specifications**
- **OS:** Windows Server mi (SQL Server için) yoksa Linux mu?
- **Resources:** CPU cores, RAM, SSD kapasitesi?
- **Location:** VPS fiziksel olarak nerede? (Latency için önemli)
- **Network:** Static IP var mı? Bandwidth limiti?
- **Access:** RDP/SSH erişimi? Docker support?

❓ **3. Database Replication Strategy**
- **Eğer SQL Server Standard+:** Transactional replication kullanılacak mı?
- **Eğer SQL Server Express:** Custom sync script mi, backup/restore mu?
- **Sync frequency:** Real-time (saniye), 5 dk, 15 dk, 1 saat?
- **Bidirectional mi yoksa unidirectional mi?** (Sadece Prod → Replica)
- **Conflict handling:** Conflict olursa ne olacak?

✅ **4. Bridge Tech Stack (Karar Verildi)**
- **Framework:** .NET 8 (Worker Service)
- **Language:** C#
- **Architecture:** Background service (HostBuilder)
- **Deployment:** Docker container veya systemd service
- **Configuration:** appsettings.json + environment variables
- **OS:** Cross-platform (Windows/Linux)

✅ **5. PDF Storage (Karar Verildi)**
- **Bunny.net Storage** ✅
  - $1/TB per month
  - S3 compatible (AWSSDK.S3 kullanılır)
  - Built-in CDN (İstanbul edge - Türkiye'den hızlı)
  - Zero maintenance
  - Auto backup ve scaling

✅ **6. API Backend (Karar Verildi)**
- **Framework:** ASP.NET Core 8.0 ✅
- **Language:** C# 12 ✅
- **Architecture:** RESTful API + JWT Auth
- **Database:** PostgreSQL 15 ✅
- **Deployment:** Docker (VPS'te)
- **Location:** Arkadaşının VPS'i (Ubuntu)

✅ **7. Database (Karar Verildi)**
- **PostgreSQL 15** ✅
- Cross-platform, free, mature
- EF Core native support
- VPS'te Docker container ile çalışacak

✅ **8. SMS Provider (Karar Verildi)**
- **Ileti Merkezi** ✅
- Türk firma, uygun fiyat
- OTP için SMS gönderimi
- ~₺0.05-0.10 per SMS

✅ **9. VPS OS (Karar Verildi)**
- **Ubuntu 22.04 LTS** ✅
- Ücretsiz, .NET cross-platform
- Docker & Docker Compose support
- systemd service management

---

## 7.1. .NET Teknoloji Yığını (Özet)

### API Backend (ASP.NET Core 8.0)

**Framework Seçimi:**
- ✅ **ASP.NET Core 8.0** - Latest LTS, cross-platform
- ✅ **C# 12** - Modern language features
- ✅ **Entity Framework Core 8.0** - ORM
- ✅ **JWT Authentication** - Token-based auth
- ✅ **Swagger/OpenAPI** - Auto API documentation

**Project Structure:**
```
OtoAvrupa.Api/
├── Controllers/          # API endpoints
├── Services/             # Business logic
├── Models/
│   ├── DTOs/            # Request/Response models
│   └── Entities/        # Database entities
├── Data/
│   ├── AppDbContext.cs  # EF Core context
│   └── Repositories/
└── Program.cs
```

**Key Dependencies:**
- `Npgsql.EntityFrameworkCore.PostgreSQL` - PostgreSQL provider
- `Microsoft.AspNetCore.Authentication.JwtBearer` - JWT auth
- `AWSSDK.S3` - Bunny.net S3-compatible storage
- `FirebaseAdmin` - Push notifications (FCM)
- `Serilog.AspNetCore` - Logging
- `FluentValidation` - Request validation
- `AutoMapper` - Object mapping

### Bridge Service (.NET 8 Worker Service)

**Framework Seçimi:**
- ✅ **.NET 8 Worker Service** - Background service
- ✅ **C# 12**
- ✅ **HostBuilder** - Generic host pattern

**Architecture:**
- Background polling (30 saniye)
- Delta Replica DB okuma
- API Backend'e POST
- Idempotent sync

**Deployment:**
- Docker container veya
- systemd service (Linux) veya
- Windows Service

### Database

**Options:**
1. **PostgreSQL 15** ⭐ (Öneri)
   - Cross-platform
   - Free (open source)
   - VPS'te kolay kurulum
   - EF Core native support

2. **SQL Server**
   - Eğer VPS Windows ise
   - Lisans maliyeti var
   - Native .NET integration

**Schema (Ön Tasarım):**
```sql
-- Customers
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    fcm_token VARCHAR(500),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Vehicles
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    license_plate VARCHAR(20) NOT NULL,
    vin VARCHAR(50) NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    current_status VARCHAR(50),
    last_sync TIMESTAMP
);

-- Service Records
CREATE TABLE service_records (
    id SERIAL PRIMARY KEY,
    vehicle_id INT REFERENCES vehicles(id),
    service_date DATE NOT NULL,
    mileage INT,
    operations TEXT,
    parts TEXT,
    total_amount DECIMAL(10,2),
    pdf_url VARCHAR(500),
    invoice_pdf_url VARCHAR(500),
    synced_at TIMESTAMP DEFAULT NOW()
);
```

### PDF Storage

**Karar:** Bunny.net Storage ✅

**Özellikler:**
- $1/TB per month (storage)
- $0.005/10,000 requests (bandwidth)
- S3 compatible (AWSSDK.S3 ile kullanılır)
- Built-in CDN (İstanbul edge location)
- Türkiye'den ~10-20ms latency
- Zero maintenance
- Auto backup ve scaling

**Implementation:**
```csharp
// Bunny.net S3 client
var s3Config = new AmazonS3Config
{
    ServiceURL = "https://storage.bunnycdn.com",
    ForcePathStyle = true
};

var s3Client = new AmazonS3Client(accessKey, secretKey, s3Config);
await s3Client.PutObjectAsync(new PutObjectRequest {
    BucketName = "otoavrupa-pdfs",
    Key = "vehicle_123_service_456.pdf",
    InputStream = pdfStream
});
```

### Flutter Mobile App

**Framework:** Flutter (Cross-platform)

**State Management:** Provider veya Riverpod

**Dependencies:**
- `http` - API calls
- `flutter_pdfview` - PDF viewing
- `firebase_messaging` - Push notifications
- `shared_preferences` - Local storage (JWT token)
- `connectivity_plus` - Network check

---

### Deployment Architecture

```
VPS (Ubuntu 22.04 LTS)
│
├── Docker Compose
│   ├── ASP.NET Core API (Container)
│   │   ├── Port 8080
│   │   └── HTTPS (Let's Encrypt)
│   │
│   ├── Bridge Worker Service (Container)
│   │   └── Background polling
│   │
│   └── PostgreSQL (Container)
│       ├── Port 5432
│       └── Persisted volume
│
└── Nginx Reverse Proxy
    ├── SSL/TLS termination
    └── Static file serving
```

### VPS Requirements

**Minimum:**
- CPU: 4 vCPU
- RAM: 8 GB
- SSD: 160 GB
- OS: Ubuntu 22.04 LTS
- Bandwidth: Unlimited

**Estimated Cost:**
- $40-80/ay (arkadaşın sağlayacak)

---

## 7.2. Sonra Karar Verilecek Olanlar

⏳ **AI Provider (Faz 2)**
- OpenAI / Anthropic / Local?
- Cost model?

⏳ **Analytics**
- Firebase Analytics / Mixpanel / Custom?
- Privacy considerations?

⏳ **Monitoring**
- Datadog / New Relic / Custom?
- Alerting thresholds?

---

## 8. İş Değeri Analizi

### 8.1. Beklenen Faydalar

✅ **Müşteri Memnuniyeti**
- Servis süreci şeffaf
- Telefon trafiği azalır
- Profesyonel imaj

✅ **Operasyonel Verimlilik**
- Bilgi talepleri azalır
- Servis personeli daha az telefonla uğraşır
- Yazılı tracking oluyor

✅ ** Rekabet Avantajı**
- Digital transformation
- Modern customer experience
- Data-driven decision making

### 8.2. Maliyetler

💰 **Development Cost**
- 6 hafta x development team
- Tasarım maliyeti
- Test maliyeti

💰 **Infrastructure Cost**
- Cloud hosting (aylık/yıllık)
- Storage (PDF)
- Push notification
- SMS (OTP)
- Monitoring & logging

💰 **Operational Cost**
- Bridge maintenance
- Support team training
- Ongoing updates

### 8.3. ROI Hesabı

**Soru:** Bu investment'ı haklı çıkarmak için:
- Kaç müşteri kullanmalı?
- Kaç telefon trafiği azalmalı?
- Müşteri retention artışı ne olmalı?

**Öneri:** Mevcut verilerle ROI modeli oluşturulmalı.

---

## 9. Faz 2 (AI Özellikleri) Analizi

### 9.1. Tanım

Mobil uygulama içinde, aracın geçmiş verilerine dayanarak soruları yanıtlayan bir AI chatbot.

### 9.2. İş Modeli

```
Kullanıcı: "Aracıma ne işlem yapıldı?"
     ↓
AI Engine: (Aracın servis geçmişini context olarak alır)
     ↓
AI: "Son servisinde fren balatası ve yağ değişimi yapıldı."
```

### 9.3. Teknik Yaklaşım

- **Data Source:** Sadece araca ait servis geçmişi, PDF içerikleri
- **Model:** OpenAI GPT / Anthropic Claude / Custom fine-tune?
- **Security:** AI Delta'ya yazamaz, sadece bilgi verir
- **Fallback:** Belirsiz durumlarda "Servisimiz iletişime geçecek"

### 9.4. Riskler

⚠️ **AI Cost**
- Token consumption hesaplanmalı
- Rate limiting gerekli

⚠️ **Accuracy**
- Yanlış bilgi verme riski
- Legal liability?

⚠️ **Data Privacy**
- Müşteri verisi AI'ye gönderilir mi?
- On-site deployment opsiyonu?

### 9.5. Zamanlama

MVP'den **1-2 ay sonra** planlanmış. Bu mantıklı:
- Önce core system stabil olsun
- Real user data toplansın
- AI için gerçek use case'ler görülsün

---

## 10. Genel Değerlendirme ve Öneriler

### 10.1. Güçlü Yönler

✅ **Non-invasive yaklaşım:** Mevcut sistemi bozmuyor
✅ **Security-first:** Port açılmıyor, read-only erişim
✅ **MVP odaklı:** Kapsam sınırlı ve net
✅ **Scalable:** İleride özellik eklenebilir
✅ **Customer value:** Net iş problemi çözüyor

### 10.2. Zayıf Yönler

❌ **Teknik stack belirsiz:** Çok karar bekleniyor
❌ **Delta DB riski:** Hafta 1'de sürpriz olabilir
❌ **Bridge operasyonu:** Deployment ve monitoring planı yok
❌ **Cost estimation:** Infrastructure maliyeti hesaplanmamış
❌ **Performance test:** Zaman planında yer almıyor

### 10.3. Kritik Öneriler

#### 🚀 Hemen Yapılması Gerekenler

1. **Teknik kararları alın**
   - Cloud provider seçin
   - Mobil framework seçin
   - Bridge tech stack belirleyin

2. **Delta DB analizini erkenden başlatın**
   - Hafta 1'i beklemeden mock data üretin
   - Gerçek DB yapısını inceleyin
   - PDF formatını doğrulayın

3. **Mock data ile geliştirmeyi başlatın**
   - Cloud backend → mock Delta
   - Mobil uygulama → mock Cloud API
   - Bridge'i parallel geliştirin

#### 📋 Planlama İçin Öneriler

4. **Zaman planını revize edin**
   - 1 hafta buffer ekleyin
   - Performance test fazı ekleyin
   - Bridge deployment testi ekleyin

5. **Risk register oluşturun**
   - Her risk için mitigation planı
   - Weekly risk review

6. **Cost modeli oluşturun**
   - Cloud infrastructure cost
   - SMS cost
   - Storage cost
   - AI cost (Faz 2)

#### 🔐 Güvenlik İçin Öneriler

7. **Security assessment yapın**
   - Penetration testing planlayın
   - Data encryption policy
   - GDPR/KVKK compliance

8. **Monitoring ve alerting**
   - Bridge health check
   - Senkronizasyon delay monitoring
   - API rate limiting

#### 📊 Success Metrics

9. **KPI belirleyin**
   - Deployment success rate
   - Senkronizasyon delay (p50, p95, p99)
   - API response time
   - Mobil app crash rate
   - User engagement (DAU/MAU)

#### 🧪 Test Stratejisi

10. **Test planı detaylandırın**
    - Unit tests (Bridge, Cloud API)
    - Integration tests (End-to-end)
    - Load tests (1000 concurrent users?)
    - Real device tests (iOS/Android)

---

## 10.1. Flutter ve FCM Teknik Detayları

### Flutter Framework Kararı

**Seçilen Framework:** Flutter

**Neden Flutter?**

1. **Cross-Platform Efficiency**
   - Tek kod tabanı, iOS + Android
   - Native performance (compiled to ARM)
   - Hot reload (hızlı development)

2. **UI/UX Capabilities**
   - Rich widget library
   - Custom animations kolay
   - Material Design & Cupertino (iOS style) widgets

3. **Ecosystem**
   - Strong community
   - Google backed
   - Mature libraries
   - Good documentation

4. **For This Project:**
   - ✅ PDF rendering: `flutter_pdfview`, `syncfusion_flutter_pdfviewer`
   - ✅ OTP handling: Easy SMS integration
   - ✅ Offline support: `shared_preferences`, `sqflite`
   - ✅ Push notifications: `firebase_messaging` (official)

### Flutter Project Structure (Öneri)

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│       └── api_service.dart
├── presentation/
│   ├── screens/
│   │   ├── login/
│   │   ├── vehicles/
│   │   ├── vehicle_detail/
│   │   ├── service_history/
│   │   ├── service_detail/
│   │   └── documents/
│   ├── widgets/
│   └── providers/  # State management
└── services/
    ├── fcm_service.dart
    ├── notification_service.dart
    └── auth_service.dart
```

### State Management Seçimi

**Options:**
1. **Provider** - Basit,官方推荐
2. **Riverpod** - Provider'ın gelişmiş versiyonu
3. **BLoC** - Daha complex, large-scale için

**Öneri:** Provider (MVP için yeterli)

### PDF Rendering Libraries

| Library | Avantaj | Dezavantaj |
|---------|---------|------------|
| `flutter_pdfview` | Ücretsiz, basit | Limited features |
| `syncfusion_flutter_pdfviewer` | Rich features, free | Commercial license for advanced features |
| `advance_pdf_viewer` | Customizable | Less popular |

**Öneri:** `flutter_pdfview` (MVP için yeterli)

---

### Firebase Cloud Messaging (FCM) Kararı

**Seçilen Servis:** Firebase Cloud Messaging (FCM)

**Neden FCM?**

1. **Flutter Integration**
   - Official `firebase_messaging` plugin
   - Zero setup complexity
   - Well documented

2. **Cost**
   - ✅ **Ücretsiz** (no hidden costs)
   - Sadece Firebase project gerekli

3. **Features**
   - Notification messages (UI shows)
   - Data messages (silent, app handles)
   - Topic messaging (broadcast to groups)
   - Advanced targeting (user segments)

4. **Scalability**
   - Handles millions of messages
   - Google infrastructure
   - Auto-scaling

### FCM Architecture

```
Cloud Backend                    Firebase                    Mobile
     │                              │                          │
     │  1. Vehicle status changed   │                          │
     │                              │                          │
     │  2. Send FCM request ────────→│                          │
     │      (HTTP v1 API)            │                          │
     │                              │                          │
     │                          3. Route to device             │
     │                              │                          │
     │                              │  4. Push notification ───→│
     │                              │                          │
     │                              │                          │  5. User taps
     │                              │                          │
     │                              ← 6. Open app screen ──────│
```

### FCM Implementation Details

**Backend (Cloud Backend):**

```python
# Python example with Firebase Admin SDK
import firebase_admin
from firebase_admin import messaging, credentials

# Initialize
cred = credentials.Certificate("path/to/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Send notification
def send_vehicle_notification(vehicle_id, status, user_fcm_token):
    # Message payload
    message = messaging.Message(
        notification=messaging.Notification(
            title=f"Araç Durumu: {status}",
            body=f"Aracınızın servisi güncellendi.",
        ),
        data={
            'vehicle_id': str(vehicle_id),
            'status': status,
            'type': 'vehicle_status_update',
            'screen': 'vehicle_detail',  # Route to this screen
        },
        token=user_fcm_token,
    )

    # Send
    response = messaging.send(message)
    print(f"Successfully sent message: {response}")
```

**Flutter (Mobile App):**

```dart
// lib/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Get FCM token
  Future<String?> getFCMToken() async {
    final token = await _fcm.getToken();
    // Send this token to your backend
    return token;
  }

  // Initialize notifications
  Future<void> initializeNotifications() async {
    // Request permission (iOS)
    NotificationSettings settings = await _fcm.requestPermission();

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle notification when app is in foreground
      print('Got message: ${message.notification?.body}');
    });

    // Background/terminated messages (user taps)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to specific screen based on message.data
      _handleNotificationTap(message.data);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    // Navigate based on data['screen']
    // Example: Navigate to vehicle detail screen
  }
}
```

### FCM Message Types

**1. Notification Message (System handled)**
```json
{
  "message": {
    "token": "device_fcm_token",
    "notification": {
      "title": "Araç Servise Alındı",
      "body": "34 ABC 123 plakalı aracınız servise alındı."
    }
  }
}
```

**2. Data Message (App handled)**
```json
{
  "message": {
    "token": "device_fcm_token",
    "data": {
      "vehicle_id": "123",
      "status": "in_service",
      "type": "status_update"
    }
  }
}
```

**3. Combined (Best practice)**
```json
{
  "message": {
    "token": "device_fcm_token",
    "notification": {
      "title": "Araç Hazır",
      "body": "Aracınız teslim almaya hazır."
    },
    "data": {
      "vehicle_id": "123",
      "screen": "vehicle_detail"
    }
  }
}
```

### Notification Scenarios

| Event | Notification Title | Body | Action |
|-------|-------------------|------|--------|
| Araç servise alındı | "Araç Servise Alındı" | "34 ABC 123 aracınız servise alındı" | Open vehicle detail |
| İşlem başladı | "İşlem Başladı" | "Aracınızda bakım işlemi başladı" | Open vehicle detail |
| Araç hazır | "Araç Hazır" | "Aracınız teslim almaya hazır! 🎉" | Open vehicle detail |
| Araç teslim edildi | "Araç Teslim Edildi" | "Aracınız teslim edildi. İyi yolculuklar!" | Open vehicle detail |

### FCM Cost Estimation

| Component | Cost | Notes |
|-----------|------|-------|
| FCM Service | ✅ **Ücretsiz** | No per-message cost |
| Firebase Project | ✅ **Ücretsiz** | Spark plan yeterli |
| Apple Developer Account | ❌ **$99/yıl** | APNs key için gerekli |
| SMS (OTP) | ~₺0.05-0.10 per SMS | Ayrı servisten |

### FCM Alternatifleri (Neden Seçilmedi?)

| Servis | Cost | Flutter Integration | Why Not Chosen |
|--------|------|---------------------|----------------|
| **OneSignal** | Free tier (limited) | Good plugin | 3rd party dependency, less control |
| **Amazon SNS** | Pay per million | Manual integration | Complex setup, AWS dependency |
| **Azure Notification Hubs** | Expensive | Manual integration | Overkill for MVP |

### Setup Checklist

- [ ] Firebase project oluştur
- [ ] Android app ekledir (package name ile)
- [ ] iOS app ekle (bundle ID ile)
- [ ] `google-services.json` (Android)
- [ ] `GoogleService-Info.plist` (iOS)
- [ ] Apple Developer account ($99/yıl)
- [ ] APNs key (.p8 file)
- [ ] FCM service account key (backend için)
- [ ] Flutter dependencies: `firebase_core`, `firebase_messaging`
- [ ] Backend: Firebase Admin SDK

---

## 11. Sonraki Adımlar (Öncelik Sırasına Göre)

### Priority 1 - Acil (Bu Hafta - Önce Delta DB Analizi)

#### 🚨 En Kritik Adım: Delta Pro Database Analizi
- [ ] **Delta Pro vendor/iletişim** ile görüşme
  - Database tipi ve edition öğrenme (Express/Standard/Enterprise)
  - Tablo yapısı ve ilişki diagramı isteme
  - İş emri flow'u detayları
  - PDF storage mekanizması
- [ ] **Delta DB'ye erişim** sağlama
  - Read-only SQL user oluşturma
  - Connection string alma
  - Sample data export
- [ ] **Database inspection**
  - Hangi tabloların kritik olduğunu belirleme
  - Incremental sync için timestamp column'ları bulma
  - PDF file path'lerini tespit etme
  - DB size estimate

#### 🔧 VPS Spesifikasyonları
- [ ] Arkadaşınla VPS detaylarını netleştirme
  - OS (Windows/Linux)
  - CPU/RAM/SSD kapasitesi
  - Static IP
  - Docker support
- [ ] Eğer SQL Server olacaksa:
  - SQL Server Edition (Express/Standard)
  - License durumu
  - Storage capacity

#### 📋 Diğer Kararlar
- [ ] VPS OS final confirmation (Ubuntu mu, Windows mu?)
- [ ] Database final choice (PostgreSQL mı, SQL Server mı?)
- [ ] PDF storage final (Bunny.net mi, MinIO mu?)
- [ ] SMS provider (Ileti Merkezi / netgsm / Veribim?)
- [ ] GitHub repo structure kurulumu (.NET solution)
- [ ] Mock data üretimi (Delta DB analizine dayanarak)

#### 🔧 .NET Development Environment Setup
- [ ] .NET 8 SDK installation (geliştirme makinesi)
- [ ] Visual Studio 2022 veya VS Code + C# Dev Kit
- [ ] Docker Desktop (local testing için)
- [ ] PostgreSQL local instance veya Docker container
- [ ] Git repository setup

#### 📱 Flutter + FCM Initial Setup
- [ ] Firebase project oluşturma
- [ ] Flutter projesi kurulumu (`flutter create`)
- [ ] `firebase_messaging` plugin entegrasyonu
- [ ] Apple Developer account ve APNs key ($99/yıl)
- [ ] FCM service account oluştur (backend için)

### Priority 2 - Kritik (Gelecek 2 Hafta)

#### 🏗️ Mimari ve Design
- [ ] Cloud backend mimari tasarımı
- [ ] Database schema tasarımı (Postgres/MongoDB)
- [ ] API specification (OpenAPI/Swagger)
- [ ] Mobil uygulama wireframe'ları

#### 🔗 Database Replication Kurulumu
- [ ] **Replication strategy kararı**
  - Eğer SQL Server Standard+: Transactional replication kurulumu
  - Eğer SQL Server Express: Custom sync script development
  - Sync frequency belirleme (5 dk, 15 dk, vs.)
- [ ] **VPS'te replica DB kurulumu**
  - SQL Server installation (veya uygun DB engine)
  - Replica database oluşturma
  - Read-only user setup
  - Connection test
- [ ] **Replication monitoring**
  - Health check script
  - Delay monitoring (Prod → Replica)
  - Alert mechanism (replication fail olursa)

#### 🔨 Bridge ve API Prototip (.NET)
- [ ] **ASP.NET Core API project kurulumu**
  - `dotnet new webapi -n OtoAvrupa.Api`
  - EF Core setup (PostgreSQL provider)
  - JWT Authentication middleware
  - Swagger/OpenAPI configuration
  - Bunny.net S3 client (AWSSDK.S3)
  - Firebase Admin SDK integration
- [ ] **Bridge Worker Service project kurulumu**
  - `dotnet new worker -n OtoAvrupa.Bridge`
  - Background service pattern (HostBuilder)
  - Delta Replica DB connection (ADO.NET veya EF)
  - HTTP client to API
  - Polling mechanism (30 seconds)
  - Idempotent sync logic
- [ ] **Mock Delta DB ile test**
  - Local SQL Server / PostgreSQL container
  - Sample data generation
  - Incremental sync logic
  - Error handling and retry

### Priority 3 - Önemli (Hafta 3-4)

#### 🚀 Production Deployment Hazırlığı
- [ ] **Docker Compose setup**
  - Dockerfile.api (ASP.NET Core)
  - Dockerfile.bridge (Worker Service)
  - docker-compose.yml (API + Bridge + Postgres)
  - Environment variables (.env file)
- [ ] **VPS hazırlığı**
  - Docker & Docker Compose installation
  - Nginx reverse proxy configuration
  - Let's Encrypt SSL certificate (HTTPS)
  - Firewall configuration (port 80, 443 only)
- [ ] **Production replication kurulumu**
  - Real Delta DB → Replica sync
  - End-to-end test
  - Performance monitoring
  - Failover test (replication crash olursa)
- [ ] **PDF transfer mekanizması**
  - Production → Replica PDF sync
  - Bunny.net storage zone setup
  - S3 upload automation (Bridge → API → Bunny.net)

#### 📱 Mobil ve Backend Development
- [ ] **ASP.NET Core API core endpoints**
  - `POST /api/auth/otp` - SMS gönder
  - `POST /api/auth/verify` - OTP doğrula, JWT üret
  - `GET /api/vehicles` - Araç listesi
  - `GET /api/vehicles/{id}` - Araç detay
  - `GET /api/vehicles/{id}/history` - Servis geçmişi
  - `GET /api/documents/{id}/pdf` - PDF indir (Bunny.net URL)
- [ ] **Flutter mobil uygulama development**
  - 7 ekran implementation (Login → Vehicle List → Details → History → PDF)
  - State management (Provider)
  - PDF viewer entegrasyonu (`flutter_pdfview`)
  - OTP handling
- [ ] **FCM implementation (.NET + Flutter)**
  - Backend: Firebase Admin SDK (notification gönderme)
  - Flutter: Token retrieval, foreground/background handling
  - Notification tap routing
- [ ] Monitoring ve logging kurulumu
  - Serilog + Seq / Elasticsearch
  - Health checks (`/health` endpoint)
  - Application Insights (opsiyonel)

#### 🧪 Integration Testing
- [ ] Delta ile gerçek senkronizasyon testi
- [ ] Bridge → Cloud → Mobile end-to-end test
- [ ] Push notification test
- [ ] PDF viewing test

### Priority 4 - Sonraki Fazlar

- [ ] Performance testing
- [ ] Security audit
- [ ] Production deployment planı
- [ ] User training
- [ ] Faz 2 (AI) araştırması

---

## 12. Sonuç

Bu proje **teknik olarak uygulanabilir** ve **iş değerini net** şekilde ortaya koyuyor. Güncellenmiş mimari (VPS + replica DB) güvenlik-first yaklaşımı benimsiyor ve müşteri altyapısını yormuyor.

**Ancak, şu an en büyük risk belirsizlikler:**

### Kritik Bilinmeyenler (Öncelik Sırasıyla):

1. 🔴 **Delta Pro Database Edition ve Yapısı**
   - Express ise: Native replication yok, custom sync gerekir (yaklaşık +1-2 hafta development)
   - Standard+ ise: Native replication kullanılabilir (daha hızlı)
   - Tablo yapısı ve index'ler belirsiz
   - PDF storage mekanizması net değil

2. 🔴 **Database Replication Strategy**
   - Production → Replica nasıl senkronize olacak?
   - Real-time mi (saniye) yoksa periodic mi (dakika/saat)?
   - PDF'ler nasıl transfer edilecek?
   - Replication monitoring nasıl yapılacak?

3. 🔴 **VPS Specifications**
   - OS belirsiz (Windows mu, Linux mu?)
   - Kaynaklar belirsiz (CPU/RAM/SSD)
   - Database engine için yeterli güçte mi?
   - Docker support?

4. ⚠️ **Bridge Tech Stack**
   - Hangi language/framework?
   - Docker mı, native service mi?
   - Crash recovery nasıl?

### Yeni Riskler (Müşteri Görüşmesinden Sonra):

- **Replication complexity ekledi:** Artık sadece Bridge değil, replication layer da var
- **VPS dependency:** Tek bir VPS'e bağımlılık (single point of failure)
- **PDF transfer complexity:** Production'dan replica'ya PDF nasıl gelecek?
- **Cost increase:** VPS maliyeti eklendi (küçük ama var)

### 6 Haftalık Zaman Planı Değerlendirmesi:

**Eğer SQL Server Standard+ ve native replication kullanılırsa:**
- ✅ 6 hafta **yeterli olabilir**

**Eğer SQL Server Express ve custom sync gerekirse:**
- ⚠️ 6 hafta **risk altında** → **7-8 hafta** daha gerçekçi

**Öneri:** SQL Server edition öğrenilince zaman planı revize edilmeli.

---

## 13. Güncellenmiş Öneriler

### İlk Hafta Yapılması Gerekenler (Kritik):

1. **🚨 Delta Pro Database Analizi (En Öncelikli)**
   - Vendor/iletişim ile görüş, DB edition öğren
   - Tablo yapısını al, sample data export et
   - PDF storage mekanizmasını öğren

2. **🔧 VPS Detaylarını Netleştir**
   - Arkadaşınla konuş, OS ve kaynakları öğren
   - Eğer SQL Server olacaksa, edition ve license sor

3. **📋 Replication Strategy Kararı**
   - Eğer Standard+: Transactional replication planla
   - Eğer Express: Custom sync prototipi yap

4. **🏗️ Teknik Stack Seçimleri**
   - Cloud provider
   - Mobil framework
   - Bridge tech stack

### Mock Data İle Development'a Hemen Başla:

Delta DB analizi tamamlanmadan bekleme:
- Mock schema tasarla
- Cloud backend'i mock data ile geliştirmeye başla
- Mobil uygulamayı mock API ile başlat
- Bridge'i local mock DB ile test et

Real Delta entegrasyonunu **parallel** ilerlet.

---

## 14. Sonuç Değerlendirmesi

**Analiz Sonucu:** 🟡 **Projeye başlanabilir, ama önce kritik riskler mitigate edilmeli**

### Başlama Koşulları:
- ✅ Mimari sağlam (VPS + replica DB approach)
- ✅ Güvenlik modeli uygun (production DB korunuyor)
- ✅ MVP kapsamı net ve gerçekçi
- ✅ İş değeri açık

### Önce Yapılması Gerekenler:
- ❌ Delta Pro database edition ve yapısı **kesinleşmeli**
- ❌ VPS specifications **netleşmeli**
- ❌ Replication strategy **belirlenmeli**
- ❌ Teknik stack **seçilmeli**

### Bu Riskler Address Edilirse:
- ✅ 6 hafta gerçekçi olabilir (Standard edition)
- ⚠️ 7-8 hafta daha muhtemel (Express edition, custom sync)

**Öneri:** Bu hafta Delta DB analizi ve VPS detaylarını netleştir, sonra development'a başla.

---

**Son Güncelleme:** 2026-01-08 (Müşteri görüşmesi sonrası güncellenmiş mimari)
