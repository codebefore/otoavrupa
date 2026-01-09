# Advantage Database Server Entegrasyon Rehberi

**Son Güncelleme:** 2026-01-09
**Proje:** OtoAvrupa Araç Servis Mobil Uygulaması

---

## 📋 İçindekiler

1. [Advantage Database Server Nedir?](#1-advantage-database-server-nedir)
2. [Bağlantı Yöntemleri](#2-bağlantı-yöntemleri)
3. [Timestamp-Based Sync Stratejisi](#3-timestamp-based-sync-stratejisi)
4. [.NET Implementasyon](#4-net-implementasyon)
5. [Local Server'da Kontrol Listesi](#5-local-serverda-kontrol-listesi)
6. [Sık Karşılaşılan Sorunlar](#6-sık-karşılaşılan-sorunlar)
7. [Performance İpuçları](#7-performance-ipuçları)

---

## 1. Advantage Database Server Nedir?

### Özellikler

- **Üretici:** Sybase (şu anda SAP)
- **Tipi:** Relational Database Management System (RDBMS)
- **Platform:** Cross-platform (Windows, Linux, macOS)
- **Dosya Formatı:** `.ADT` (Advantage Data Table)
- **Authentication:** Windows Authentication destekliyor

### Avantajları

✅ **Hızlı** - Index tabanlı sorgulama
✅ **Hafif** - Kurulumu ve yönetimi kolay
✅ **Uygun maliyetli** - SQL Server gibi pahalı lisans gerektirmez
✅ **.NET Desteği** - Native .NET Provider var

### Dezavantajları

❌ **Native replication yok** - Custom sync gerekli
❌ **Community desteği sınırlı** - Dokümantasyon zor bulunabilir
❌ **Backup/restore sınırlı** - Incremental backup yok

---

## 2. Bağlantı Yöntemleri

### 2.1. Connection String Formatları

#### Remote Connection (Windows Authentication)

```csharp
// Network path üzerinden
string connString = @"Data Source=\\192.168.1.100\Delta\Data\database.add;ServerType=REMOTE;TrimTrailingSpaces=True;";

// Veya server ismi ile
string connString = @"Data Source=\\DBSERVER\Delta\Data\database.add;ServerType=REMOTE;";
```

#### Local Connection

```csharp
// Local disk path
string connString = @"Data Source=C:\Delta\Data\database.add;ServerType=LOCAL;TrimTrailingSpaces=True;";
```

#### Windows Authentication ile

```csharp
// Integrated Security
string connString = @"Data Source=\\server\path\database.add;ServerType=REMOTE;Integrated Security=True;";
```

### 2.2. .NET Provider Kurulumu

#### NuGet Paketi

```bash
# .NET CLI
dotnet add package Advantage.Data.Provider

# Veya Visual Studio Package Manager
Install-Package Advantage.Data.Provider
```

#### Basit Bağlantı Örneği

```csharp
using Advantage.Data.Provider;

public class AdvantageDbContext : IDisposable
{
    private readonly AdsConnection _connection;

    public AdvantageDbContext(string connectionString)
    {
        _connection = new AdsConnection(connectionString);
        _connection.Open();
    }

    public async Task<List<T>> ExecuteQueryAsync<T>(string query, Func<AdsDataReader, T> map)
    {
        using var command = new AdsCommand(query, _connection);
        using var reader = await command.ExecuteReaderAsync();
        var results = new List<T>();

        while (await reader.ReadAsync())
        {
            results.Add(map(reader));
        }

        return results;
    }

    public void Dispose()
    {
        _connection?.Dispose();
    }
}
```

---

## 3. Timestamp-Based Sync Stratejisi

### 3.1. Neden Timestamp-Based?

| Yöntem | Avantaj | Dezavantaj | Tavsiye |
|--------|---------|------------|---------|
| **Timestamp-Based** | Hızlı, basit | Deleted records zor | ✅ **En iyi** |
| Full Diff | Basit | Çok yavaş | ❌ Kullanma |
| Trigger Log | Real-time | Riskli | ⚠️ Complex |

### 3.2. Sync Mantığı

```csharp
public class AdvantageSyncService
{
    private readonly string _connectionString;
    private DateTime _lastSyncTime;

    public AdvantageSyncService(string connectionString)
    {
        _connectionString = connectionString;
        _lastSyncTime = DateTime.Now.AddMinutes(-5); // İlk sync için 5 dk geri
    }

    public async Task SyncChangesAsync()
    {
        using var conn = new AdsConnection(_connectionString);
        await conn.OpenAsync();

        // 1. Araçları senkronize et
        var vehicles = await GetChangedVehiclesAsync(conn);
        await SendToCloudAsync("/api/sync/vehicles", vehicles);

        // 2. İş emirlerini senkronize et
        var orders = await GetChangedServiceOrdersAsync(conn);
        await SendToCloudAsync("/api/sync/service-orders", orders);

        // Sync zamanını güncelle
        _lastSyncTime = DateTime.Now;
    }

    private async Task<List<VehicleDto>> GetChangedVehiclesAsync(AdsConnection conn)
    {
        var cmd = new AdsCommand(@"
            SELECT
                vehicle_id,
                license_plate,
                vin,
                brand,
                model,
                customer_phone,
                current_status,
                last_updated
            FROM vehicles
            WHERE last_updated > @lastSync
            ORDER BY last_updated ASC
        ", conn);

        cmd.Parameters.AddWithValue("@lastSync", _lastSyncTime);

        using var reader = await cmd.ExecuteReaderAsync();
        var vehicles = new List<VehicleDto>();

        while (await reader.ReadAsync())
        {
            vehicles.Add(new VehicleDto
            {
                VehicleId = reader.GetInt32(reader.GetOrdinal("vehicle_id")),
                LicensePlate = reader.GetString(reader.GetOrdinal("license_plate")),
                Vin = reader.GetString(reader.GetOrdinal("vin")),
                Brand = reader.GetString(reader.GetOrdinal("brand")),
                Model = reader.GetString(reader.GetOrdinal("model")),
                CustomerPhone = reader.GetString(reader.GetOrdinal("customer_phone")),
                CurrentStatus = reader.GetString(reader.GetOrdinal("current_status")),
                LastUpdated = reader.GetDateTime(reader.GetOrdinal("last_updated"))
            });
        }

        return vehicles;
    }
}
```

### 3.3. Deleted Records Tespiti

Silinen kayıtları tespit etmek için 3 yöntem:

#### Yöntem 1: Soft Delete (Öneri)

```sql
-- Advantage DB'de deleted column ekleyin
ALTER TABLE vehicles ADD COLUMN deleted BIT DEFAULT 0;

-- Silme yerine update
UPDATE vehicles SET deleted = 1, last_updated = GETDATE() WHERE vehicle_id = 123;

-- Sync query
SELECT * FROM vehicles
WHERE last_updated > @lastSync
  AND deleted = 0;
```

#### Yöntem 2: Shadow Table

```sql
-- Silinen kayıtları ayrı tabloda tutun
CREATE TABLE deleted_vehicles (
    vehicle_id INT,
    deleted_at DATETIME,
    PRIMARY KEY (vehicle_id, deleted_at)
);

-- Sync query ile kontrol
-- Cloud'daki vehicle_id'ler ile karşılaştır
```

#### Yöntem 3: Full Diff (Son çare)

```csharp
// Cloud'daki tüm ID'leri çek
var cloudVehicleIds = await GetCloudVehicleIdsAsync();

// Advantage DB'deki tüm ID'leri çek
var localVehicleIds = await GetLocalVehicleIdsAsync();

// Farkı bul
var deletedIds = cloudVehicleIds.Except(localVehicleIds);
```

---

## 4. .NET Implementasyon

### 4.1. Bridge Service (.NET 8 Worker Service)

```csharp
// Program.cs
using IHost host = Host.CreateDefaultBuilder(args)
    .ConfigureServices((context, services) =>
    {
        // Configuration
        var connectionString = context.Configuration["Advantage:ConnectionString"];
        var apiUrl = context.Configuration["CloudApi:BaseUrl"];

        // Services
        services.AddSingleton<AdvantageSyncService>();
        services.AddHttpClient<CloudApiService>(client =>
        {
            client.BaseAddress = new Uri(apiUrl);
        });

        // Worker
        services.AddHostedService<BridgeWorker>();
    })
    .Build();

await host.RunAsync();
```

### 4.2. Background Worker

```csharp
public class BridgeWorker : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<BridgeWorker> _logger;

    public BridgeWorker(
        IServiceProvider serviceProvider,
        ILogger<BridgeWorker> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("🚀 Bridge Service started at: {time}", DateTimeOffset.Now);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var syncService = scope.ServiceProvider.GetRequiredService<AdvantageSyncService>();

                // Sync çalıştır
                await syncService.SyncChangesAsync();

                // 30 saniye bekle
                await Task.Delay(TimeSpan.FromSeconds(30), stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Sync failed at: {time}", DateTimeOffset.Now);

                // Hata durumunda 1 dakika bekle
                await Task.Delay(TimeSpan.FromMinutes(1), stoppingToken);
            }
        }
    }
}
```

### 4.3. Configuration (appsettings.json)

```json
{
  "Advantage": {
    "ConnectionString": "Data Source=\\\\192.168.1.100\\Delta\\Data\\database.add;ServerType=REMOTE;TrimTrailingSpaces=True;",
    "SyncIntervalSeconds": 30,
    "RetryCount": 3,
    "RetryDelaySeconds": 5
  },
  "CloudApi": {
    "BaseUrl": "https://api.otoavrupa.com",
    "ApiKey": "your-api-key-here",
    "SyncEndpoints": {
      "Vehicles": "/api/sync/vehicles",
      "ServiceOrders": "/api/sync/service-orders",
      "Invoices": "/api/sync/invoices"
    }
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning"
    }
  }
}
```

---

## 5. Local Server'da Kontrol Listesi

### 5.1. Bu Hafta Yapılacaklar

Müşteri ofisinde local server'a bağlandığınızda:

#### ✅ Adım 1: Tablo Yapısını Öğrenin

```sql
-- Tüm tabloları listele
SELECT table_name FROM system.tables WHERE table_type = 'TABLE';

-- Veya
SHOW TABLES;
```

**Beklenen tablolar:**
- `vehicles` veya `arac`
- `service_orders` veya `is_emirleri`
- `customers` veya `musteriler`
- `invoices` veya `faturalar`

#### ✅ Adım 2: Timestamp Column'ları Kontrol Edin

```sql
-- Her tablonun yapısını kontrol et
DESCRIBE vehicles;

-- Veya Advantage spesifik
SELECT column_name, data_type, column_size
FROM system.columns
WHERE table_name = 'VEHICLES'
ORDER BY column_order;
```

**Aranan column'lar:**
- `last_updated` ✅ (En olası)
- `updated_at`
- `modification_date`
- `timestamp`

#### ✅ Adım 3: Test Sorgusu Çalıştırın

```sql
-- Son 1 saatte değişen araçları getir
SELECT * FROM vehicles
WHERE last_updated > DATEADD(HOUR, -1, GETDATE())
ORDER BY last_updated DESC
LIMIT 10;
```

**Eğer çalışırsa:** ✅ Timestamp-based sync kullanabiliriz
**Eğer hata verirse:** Column ismini bulmalısınız

#### ✅ Adım 4: PDF Path'ini Öğrenin

```sql
-- Service orders tablosunda PDF column'ı
SELECT order_id, pdf_path, invoice_pdf_path
FROM service_orders
WHERE pdf_path IS NOT NULL
LIMIT 5;
```

**Örnek path:**
- `C:\Delta\PDFs\order_123.pdf`
- `\\server\pdfs\order_123.pdf`

#### ✅ Adım 5: Connection String'i Test Edin

```csharp
// Test kodu
var connString = @"Data Source=\\server\path\database.add;ServerType=REMOTE;";

using var conn = new AdsConnection(connString);
try
{
    conn.Open();
    Console.WriteLine("✅ Bağlantı başarılı!");

    // Test sorgusu
    var cmd = new AdsCommand("SELECT COUNT(*) FROM vehicles", conn);
    var count = cmd.ExecuteScalar();
    Console.WriteLine($"📊 Toplam araç sayısı: {count}");
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Bağlantı hatası: {ex.Message}");
}
```

### 5.2. Toplanacak Bilgiler

Local server'dan ayrılmadan önce şu bilgileri toplamalısınız:

| Bilgi | Örnek | Neden Gerekli? |
|-------|-------|----------------|
| **Server Path** | `\\192.168.1.100\Delta\` | Connection string |
| **DB File Name** | `delta.add` | Connection string |
| **Table Names** | `vehicles`, `service_orders` | Sync queries |
| **Timestamp Column** | `last_updated` | Sync logic |
| **PDF Path Column** | `pdf_path` | PDF upload |
| **PDF Disk Path** | `C:\Delta\PDFs\` | File access |
| **Approx Size** | ~2 GB | Performance planning |
| **Windows User** | `DOMAIN\service_account` | Authentication |

---

## 6. Sık Karşılaşılan Sorunlar

### 6.1. Bağlantı Sorunları

#### Sorun: "Cannot connect to Advantage Database"

**Çözümler:**
```csharp
// 1. Path doğru mu?
// Yanlış: "C:\Data\database.add" (ServerType=REMOTE için)
// Doğru: "\\server\Data\database.add"

// 2. Windows permissions kontrol et
// Kullanıcının DB dosyalarına okuma yetkisi var mı?

// 3. Firewall kontrol et
// Port 6262 (Advantage default) açık mı?
```

#### Sorun: "Authentication failed"

**Çözüm:**
```csharp
// Windows Authentication kullan
connString = "Data Source=\\server\path\db.add;ServerType=REMOTE;Integrated Security=True;";

// Veya specific user ile
connString = "Data Source=\\server\path\db.add;ServerType=REMOTE;User ID=admin;Password=pass;";
```

### 6.2. Performans Sorunları

#### Sorun: Sync çok yavaş

**Çözümler:**
```sql
-- 1. Index kontrol et
SHOW INDEX FROM vehicles;

-- 2. last_updated column'una index yoksa ekle
CREATE INDEX idx_last_updated ON vehicles(last_updated);

-- 3. LIMIT kullan (test için)
SELECT * FROM vehicles
WHERE last_updated > @lastSync
ORDER BY last_updated ASC
LIMIT 100;
```

#### Sorun: Memory leak

**Çözüm:**
```csharp
// Her sync'te connection kapat
using (var conn = new AdsConnection(_connectionString))
{
    await conn.OpenAsync();
    // Sync işlemleri
} // Otomatik dispose
```

### 6.3. Data Tutarlılık Sorunları

#### Sorun: Duplicate records

**Çözüm:**
```sql
-- Cloud backend'de upsert kullan
INSERT INTO vehicles (vehicle_id, license_plate, ...)
VALUES (@id, @plate, ...)
ON CONFLICT (vehicle_id) DO UPDATE
SET license_plate = EXCLUDED.license_plate,
    last_updated = EXCLUDED.last_updated;
```

#### Sorun: Missing records (Sync gap)

**Çözüm:**
```csharp
// Sync log tut
public class SyncLog
{
    public DateTime SyncTime { get; set; }
    public int RecordCount { get; set; }
    public string Error { get; set; }
}

// Her sync'te logla
await LogSyncAsync(new SyncLog
{
    SyncTime = DateTime.Now,
    RecordCount = vehicles.Count,
    Error = null
});
```

---

## 7. Performance İpuçları

### 7.1. Query Optimization

```sql
-- ❌ Yavaş (SELECT *)
SELECT * FROM vehicles WHERE last_updated > @lastSync;

-- ✅ Hızlı (Sadece gerekli column'lar)
SELECT vehicle_id, license_plate, vin, current_status, last_updated
FROM vehicles
WHERE last_updated > @lastSync;
```

### 7.2. Batch Processing

```csharp
// ❌ Yavaş (Tek tek gönder)
foreach (var vehicle in vehicles)
{
    await SendToCloudAsync(vehicle);
}

// ✅ Hızlı (Batch gönder)
await SendToCloudAsync(vehicles); // Tümünü bir seferde
```

### 7.3. Parallel Processing

```csharp
// Farklı tabloları parallel senkronize et
var tasks = new List<Task>
{
    SyncVehiclesAsync(),
    SyncServiceOrdersAsync(),
    SyncInvoicesAsync()
};

await Task.WhenAll(tasks);
```

### 7.4. Connection Pooling

```csharp
// Connection string'de pooling aç
string connString = @"Data Source=\\server\path\db.add;ServerType=REMOTE;Pooling=True;Min Pool Size=5;Max Pool Size=100;";
```

---

## 8. Sonraki Adımlar

### 8.1. Bu Hafta

1. ✅ Local server'a bağlan
2. ✅ Yukarıdaki kontrol listesini tamamla
3. ✅ Connection string'i test et
4. ✅ Timestamp column'ı doğrula
4. ✅ Bilgileri topla ve bana gönder

### 8.2. Gelecek Hafta

5. ✅ Bridge service'i kur (.NET 8)
6. ✅ Timestamp sync implementasyonu
7. ✅ Docker container'a al
8. ✅ VPS'te deploy et

### 8.3. Hafta 3+

9. ✅ End-to-end test
10. ✅ Performance tuning
11. ✅ Error handling
12. ✅ Monitoring

---

## 9. Kaynaklar

### Dokümantasyon

- [Advantage Database Server Documentation](https://infocenter.sybase.com/help/topic/com.sybase.infocenter.dc01205.0211/doc/html/mzg1271683118408.html)
- [Advantage .NET Provider Guide](http://docs.30c.org/conn/providers/advantage-net-data-provider.html)
- [Connection Strings Reference](https://www.connectionstrings.com/advantage-net-data-provider/)

### Community

- [SAP Advantage Community](https://community.sap.com/t5/technology-blogs-by-sap/advantage-features-for-high-availability/ba-p/13278765)
- [StackOverflow - Advantage Tag](https://stackoverflow.com/questions/tagged/advantage-database-server)

---

**Not:** Bu rehber, Advantage Database Server entegrasyonu için başlangıç noktasıdır. Local server'da yapacağınız analizlere göre güncellenecektir.
