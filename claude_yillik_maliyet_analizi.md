# Yıllık Maliyet Analizi
## OtoAvrupa Mobil Uygulama Projesi

**Hesaplama Tarihi:** 2026-01-08
**Proje:** Araç Servis Takip Mobil Uygulaması (MVP)

---

## 1. Development Maliyetleri (Tek Seferlik)

### 1.1. Apple Developer Program
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Apple Developer Account | $99 | Yıllık | iOS app store için ZORUNLU |
| **Toplam** | **$99** | **Yıllık** | **Her yıl yenilemek zorunda** |

### 1.2. Google Play Console
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Google Play Developer Fee | $25 | Tek seferlik | Android için bir kerelik |
| **Toplam** | **$25** | **Tek seferlik** | **Sonrasında ödeme yok** |

---

## 2. Altyapı Maliyetleri (Yıllık)

### 2.1. VPS (Sanal Sunucu)
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| VPS (4 vCPU, 8 GB RAM, 160 GB SSD) | **₺0** | Aylık | Arkadaşın sağlayacak 🎁 |
| Ubuntu 22.04 LTS | ₺0 | - | Ücretsiz OS |
| **Toplam Yıllık** | **₺0** | **Yıllık** | **Arkadaşlık avantajı!** |

**Eğer arkadaşın sağlamasaydı:**
| VPS Equivalent | $40-80/ay | $480-960/yıl | DigitalOcean, Linode, vs. |

### 2.2. Database
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| PostgreSQL 15 | ₺0 | - | Self-hosted, VPS'te çalışır |
| Backup Storage (opsiyonel) | ₺0-50 | Aylık | VPS diskte veya S3'te |
| **Toplam Yıllık** | **₺0** | **Yıllık** | **Self-hosted, ücretsiz** |

### 2.3. PDF Storage (Bunny.net)
| Kalemin | Maliyet | Periyot | Hesaplama |
|---------|---------|---------|-----------|
| Storage (1 TB) | $1/TB | Aylık | İlk yıl 1 TB varsayım |
| Bandwidth (10 TB) | $0.005/10K requests | Aylık | ~50K request/gün = 1.5M/ay = $0.75 |
| **Aylık Tahmini** | **$1-5** | **Aylık** | Kullanım arttıkça artar |
| **Yıllık Tahmini** | **$12-60** | **Yıllık** | **~$20-30/ay orta vade** |

**Bunny.net Maliyet Hesaplama:**
```
Varsayımlar:
- 500 müşteri
- Her araç yılda 2 servis = 1000 servis/yıl
- Her servis 2 PDF (fiş + fatura) = 2000 PDF/yıl
- Her PDF ortalama 500 KB
- Toplam PDF size = 2000 × 500 KB = 1 GB/yıl

Storage: 1 GB = $0.001/ay (neredeyse ücretsiz)
Requests: 2000 × 12 (view/month) = 24K request/ay = $0.01

İlk yıl maliyet: ~$1-2/ay
```

### 2.4. Push Notifications (Firebase FCM)
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Firebase Cloud Messaging | ₺0 | - | Ücretsiz (sınırsız) |
| Firebase Analytics | ₺0 | - | Ücretsiz |
| Firebase Crashlytics | ₺0 | - | Ücretsiz |
| **Toplam Yıllık** | **₺0** | **Yıllık** | **Tamamen ücretsiz** |

### 2.5. SMS (Ileti Merkezi - OTP)
| Kalemin | Maliyet | Periyot | Hesaplama |
|---------|---------|---------|-----------|
| SMS (Tek bir OTP) | ₺0.05-0.10 | Adet başına | Türkiye içi |
| **Senaryo 1: 100 müşteri** |  |  | |
| - Her müşteri yılda 1 kez login | 100 SMS/yıl | ₺5-10/yıl | |
| **Senaryo 2: 500 müşteri** |  |  | |
| - Her müşteri yılda 2 kez login | 1000 SMS/yıl | ₺50-100/yıl | |
| **Senaryo 3: 1000 müşteri** |  |  | |
| - Her müşteri yılda 2 kez login | 2000 SMS/yıl | ₺100-200/yıl | |

**Ileti Merkezi Fiyatlandırma (Tahmini):**
- Paketler: 1000 SMS = ₺50-100
- Kurumsal: Daha ucuz anlaşma yapılabilir
- Uluslararası: +₺0.10-0.20/SMS

**Yıllık Tahmini (500 müşteri):** **₺50-100**

### 2.6. Domain ve DNS (Opsiyonel)
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Domain (otoavrupa.com.tr) | ₺100-300 | Yıllık | .com.tr pahalı, .com ucuz |
| DNS Management | ₺0 | - | Cloudflare ücretsiz |
| **Toplam Yıllık** | **₺100-300** | **Yıllık** | **Opsiyonel, IP de kullanılabilir** |

### 2.7. SSL Certificate
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Let's Encrypt SSL | ₺0 | 90 günlük | Ücretsiz, otomatik yenileme |
| Paid SSL (Genel) | $50-200 | Yıllık | Gerek yok |
| **Toplam Yıllık** | **₺0** | **Yıllık** | **Let's Encrypt yeterli** |

### 2.8. Monitoring ve Logging (Opsiyonel)
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Serilog + File (Basic) | ₺0 | - | Local logging |
| Seq (Self-hosted) | ₺0 | - | Local instance |
| Application Insights (Azure) | ₺0-200 | Aylık | Free tier yeterli |
| Datadog | $15-25/host | Aylık | Gerek yok (pahalı) |
| **Öneri:** Self-hosted Seq → **₺0** |

---

## 3. Geliştirme Maliyetleri (Human Resources)

### 3.1. İç Geliştirme (Sizin Yapacaksanız)
| Rol | Saat | Ücret | Maliyet | Notlar |
|-----|------|-------|---------|--------|
| Backend Developer (.NET) | 200-300 saat | ₺200-500/saat | ₺40.000-150.000 | Siz yaparsanız 0 |
| Mobile Developer (Flutter) | 150-250 saat | ₺200-500/saat | ₺30.000-125.000 | Siz yaparsanız 0 |
| DevOps/Infrastructure | 50-100 saat | ₺200-400/saat | ₺10.000-40.000 | Siz yaparsanız 0 |
| UI/UX Designer | 40-80 saat | ₺150-400/saat | ₺6.000-32.000 | Siz yaparsanız 0 |
| Testing & QA | 50-100 saat | ₺150-300/saat | ₺7.500-30.000 | Siz yaparsanız 0 |
| **Toplam (Freelance)** | **~500-800 saat** | - | **₺93.500-377.000** | **Pahalı** |
| **Toplam (Kendiniz yaparsanız)** | **~500-800 saat** | - | **₺0** | **Sadece zaman** |

**Not:** 6 haftalık proje = 240 saat (tam zamanlı 1 kişi)
- Backend: 120 saat
- Mobile: 80 saat
- DevOps: 20 saat
- Testing: 20 saat

### 3.2. Freelance/Ajans Kiralama
| Model | Maliyet | Periyot | Notlar |
|-------|---------|---------|--------|
| Full-stack Developer (Freelance) | ₺50.000-150.000 | Proje başı | 1-2 ay |
| Software Agency (Türkiye) | ₺150.000-500.000 | Proje başı | End-to-end |
| Offshore (Ukrayna/India) | $20-50/saat | Saatlik | Daha ucuz |
| **Öneri:** Eğer vaktiniz yoksa freelance tercih edin |

---

## 4. Bakım ve Operasyon Maliyetleri (Yıllık)

### 4.1. Regular Maintenance
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Bug fixes | ₺0-5.000 | Yıllık | Siz yaparsanız 0 |
| Updates (.NET, Flutter) | ₺0-2.000 | Yıllık | Siz yaparsanız 0 |
| Monitoring & Alerts | ₺0 | - | Ücretsiz tools |
| Database backups | ₺0-50 | Aylık | VPS diskte |
| **Toplam Yıllık** | **₺0-7.000** | **Yıllık** | **Kendiniz yaparsanız ₺0** |

### 4.2. Support (Opsiyonel)
| Kalemin | Maliyet | Periyot | Notlar |
|---------|---------|---------|--------|
| Self-support | ₺0 | - | Sizin yapmanız |
| Freelance support | ₺5.000-20.000 | Yıllık | Part-time |
| Agency support | ₺20.000-50.000 | Yıllık | Full-time |
| **Öneri:** İlk başta self-support |

---

## 5. Özet Maliyet Tablosu (Yıllık)

### 5.1. Tek Seferlik Maliyetler (İlk Yıl)

| Kalem | Maliyet (USD) | Maliyet (TL) | Notlar |
|-------|---------------|--------------|--------|
| Apple Developer Account | $99 | ₺3.000-3.500 | Her yıl yenilemek zorunda |
| Google Play Console | $25 | ₺800-1.000 | Tek seferlik |
| **Toplam** | **$124** | **~₺4.000** | **İlk yıl** |

### 5.2. Operasyonel Maliyetler (Yıllık)

| Kalem | Maliyet (USD) | Maliyet (TL) | Aylık |
|-------|---------------|--------------|-------|
| **VPS** | $0 | ₺0 | ₺0 |
| **Database** | $0 | ₺0 | ₺0 |
| **PDF Storage (Bunny.net)** | $12-60 | ₺400-2.000 | ₺30-170 |
| **Push Notifications (FCM)** | $0 | ₺0 | ₺0 |
| **SMS (Ileti Merkezi)** | $2-4 | ₺50-100 | ₺4-8 |
| **Domain (Opsiyonel)** | $5-10 | ₺100-300 | ₺8-25 |
| **SSL Certificate** | $0 | ₺0 | ₺0 |
| **Monitoring** | $0 | ₺0 | ₺0 |
| **Apple Developer (2. yıl)** | $99 | ₺3.000-3.500 | ₺250 |
| **Toplam (Yıllık)** | **~$120-180** | **~₺3.600-6.000** | **~₺300-500/ay** |

### 5.3. Geliştirme Maliyetleri (Opsiyonel)

| Senaryo | Maliyet (TL) | Notlar |
|---------|--------------|--------|
| **Kendiniz yaparsanız** | ₺0 | Sadece zaman maliyeti (500-800 saat) |
| **Freelance developer** | ₺50.000-150.000 | Proje bazlı |
| **Software agency** | ₺150.000-500.000 | End-to-end hizmet |

---

## 6. Senaryo Bazlı Maliyetler (Yıllık)

### Senaryo 1: Minimum (Kendiniz Geliştirme - 100 Müşteri)

| Kalem | İlk Yıl (TL) | Sonraki Yıllar (TL) |
|-------|--------------|---------------------|
| Apple Developer | ₺3.000 | ₺3.000 |
| Google Play | ₺800 | ₺0 |
| PDF Storage (Bunny) | ₺400 | ₺600 |
| SMS (100 müşteri) | ₺50 | ₺50 |
| **Toplam** | **₺4.250** | **₺3.650** |
| **Aylık** | **₺350** | **₺300** |

### Senaryo 2: Orta (Kendiniz Geliştirme - 500 Müşteri)

| Kalem | İlk Yıl (TL) | Sonraki Yıllar (TL) |
|-------|--------------|---------------------|
| Apple Developer | ₺3.000 | ₺3.000 |
| Google Play | ₺800 | ₺0 |
| PDF Storage (Bunny) | ₺800 | ₺1.200 |
| SMS (500 müşteri) | ₺100 | ₺100 |
| Domain (opsiyonel) | ₺200 | ₺200 |
| **Toplam** | **₺4.900** | **₺4.500** |
| **Aylık** | **₺400** | **₺375** |

### Senaryo 3: Yüksek (Kendiniz Geliştirme - 1000 Müşteri)

| Kalem | İlk Yıl (TL) | Sonraki Yıllar (TL) |
|-------|--------------|---------------------|
| Apple Developer | ₺3.000 | ₺3.000 |
| Google Play | ₺800 | ₺0 |
| PDF Storage (Bunny) | ₺1.200 | ₺2.000 |
| SMS (1000 müşteri) | ₺200 | ₺200 |
| Domain | ₺200 | ₺200 |
| Monitoring (opsiyonel) | ₺500 | ₺500 |
| **Toplam** | **₺5.900** | **₺5.900** |
| **Aylık** | **₺490** | **₺490** |

### Senaryo 4: Freelance Developer ile (500 Müşteri)

| Kalem | Maliyet (TL) | Notlar |
|-------|--------------|--------|
| **Development (Tek seferlik)** | ₺50.000-150.000 | Freelance ücreti |
| **Operasyonel (yıllık)** | ₺4.500 | Senaryo 2'den |
| **İlk Yıl Toplam** | **₺54.500-154.500** | Development + operasyonel |
| **Sonraki Yıllar** | **₺4.500** | Sadece operasyonel |

---

## 7. Maliyet Optimizasyon Önerileri

### 7.1. Tasarruf Edilebilir Kalemler
| Kalem | Şu Anda | Tasarruf | Nasıl? |
|-------|---------|----------|-------|
| VPS | ₺0 | ₺0 | Zaten ücretsiz (arkadaşlık) |
| Domain | ₺200 | ₺200 | IP kullanın, domain gerek yok |
| Monitoring | ₺500 | ₺500 | Self-hosted Seq kullanın |
| **Potansiyel Tasarruf** | - | **₺700** | **Domain + monitoring** |

### 7.2. Scale-up Maliyetleri
| Müşteri Sayısı | Yıllık Maliyet (TL) | Aylık (TL) |
|---------------|-------------------|------------|
| 100 | ₺3.650 | ₺300 |
| 500 | ₺4.500 | ₺375 |
| 1.000 | ₺5.900 | ₺490 |
| 5.000 | ₺15.000 | ₺1.250 |
| 10.000 | ₺30.000 | ₺2.500 |

**Not:** Müşteri sayısı arttıkça:
- PDF storage artar (doğrusal oranda)
- SMS maliyeti artar (doğrusal oranda)
- VPS upgrade gerekebilir (5000+ müşteri)

---

## 8. Break-Even Analizi

### 8.1. Ne Zaman Kendini Amortisi Eder?

**Varsayımlar:**
- Freelance developer maliyeti: ₺100.000 (tek seferlik)
- Yıllık operasyonel maliyet: ₺4.500
- Her müşteriden yıllık kar: ₺50 (tasaruf)

**Hesaplama:**
```
Yıllık kar = Müşteri sayısı × ₺50
Net kar = Yıllık kar - Operasyonel maliyet

100 müşteri: ₺5.000 - ₺4.500 = ₺500 kar/yıl
500 müşteri: ₺25.000 - ₺4.500 = ₺20.500 kar/yıl
1000 müşteri: ₺50.000 - ₺4.500 = ₺45.500 kar/yıl
```

**Break-even:**
- Development maliyeti: ₺100.000
- Yıllık kar (500 müşteri): ₺20.500
- **Break-even süresi:** ~5 yıl

**Not:** Bu sadece maliyet amortismanı, gerçek ROI müşteri memnuniyeti ve operasyonel verimlilik ile çok daha hızlı olur.

### 8.2. Gizli Maliyetler (Dikkat!)

| Kalem | Potansiyel Maliyet | Önlem |
|-------|-------------------|-------|
| VPS çökerse | ₺5.000-20.000 | Backup + monitoring |
| Güvenlik açığı | ₺10.000-50.000 | Security audit |
| Data loss | ₺5.000-20.000 | Regular backups |
| App store reject | ₺2.000-5.000 | Guideline'lere uyum |
| **Toplam Risk** | **₺22.000-95.000** | **Insurance factor** |

---

## 9. Final Özet

### 9.1. İlk Yıl Maliyeti (Kendiniz Geliştirme - 500 Müşteri)

| Kategori | Maliyet (TL) | Yüzde |
|----------|--------------|-------|
| **Development** | ₺0 | 0% (Kendiniz yaparsanız) |
| **Tek Seferlik** | ₺4.000 | 45% |
| **Operasyonel** | ₺900 | 10% |
| **Buffer (Risk)** | ₺4.000 | 45% |
| **Toplam** | **₺8.900** | **100%** |
| **Aylık** | **₺740** | - |

### 9.2. Sonraki Yıllar (500 Müşteri)

| Kategori | Maliyet (TL) | Aylık |
|----------|--------------|-------|
| Apple Developer | ₺3.000 | ₺250 |
| PDF Storage | ₺1.200 | ₺100 |
| SMS | ₺100 | ₺8 |
| Domain (opsiyonel) | ₺200 | ₺17 |
| **Toplam Yıllık** | **₺4.500** | **₺375/ay** |

### 9.3. En İyi ve En Kötü Senaryo

| Senaryo | Yıllık Maliyet | Aylık | Notlar |
|---------|---------------|-------|--------|
| **En iyi** | ₺3.650 | ₺300 | 100 müşteri, domainsiz |
| **En kötü** | ₺154.500 | ₺12.875 | Freelance + 1000 müşteri + domain |
| **Orta (öneri)** | ₺4.500 | ₺375 | 500 müşteri, kendiniz geliştirme |

---

## 10. Sonuç ve Tavsiyeler

### En İyi Cost-Benefit Senaryo:
- ✅ **Kendiniz geliştirin** (500-800 saat zaman)
- ✅ **Domain almayın** (IP kullanın)
- ✅ **Self-hosted monitoring** (Seq veya Serilog)
- ✅ **500 müşteriye kadar** bu setup yeterli

### Tahmini Yıllık Maliyet:
- **İlk yıl:** ~₺4.000-5.000 (Apple + Google + 1 yıl operational)
- **Sonraki yıllar:** ~₺3.500-4.500 (Apple + operational)

### Aylük Maliyet:
- **Sadece operational:** ~₺300-400/ay
- **İlk yıl ortalaması:** ~₺350-450/ay (apple dev'ı dahil)

### Break-even Süresi:
- Eğer operasyonel verimlilik ve müşteri memnuniyeti değerlendirilirse: **6-12 ay**
- Sadece maliyet bazlı: ~5 yıl (freelance ile)

### Final Tavsiye:
Bu proje **maliyet-etik** ve **sürdürülebilir**. Arkadaşınızın VPS sağlaması büyük avantaj. İlk yıl **₺5.000** bütçeyle başlanabilir.

---

**Not:** Tüm fiyatlar 2026 tahmini olmakla birlikte, döviz kuru ve enflasyon etkisiyle değişebilir.
