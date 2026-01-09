class AppConstants {
  // API
  static const String baseUrl = 'https://api.otoavrupa.com';
  static const String apiVersion = '/v1';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyPhoneNumber = 'phone_number';
  static const String keyUserId = 'user_id';

  // App Settings
  static const String appName = 'OtoAvrupa';
  static const String appVersion = '1.0.0';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // OTP
  static const int otpLength = 6;
  static const Duration otpResendDelay = Duration(seconds: 60);
}

class ApiEndpoints {
  // Auth
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';

  // Vehicles
  static const String getVehicles = '/vehicles';
  static const String getVehicleDetail = '/vehicles/{id}';

  // Service History
  static const String getServiceHistory = '/vehicles/{id}/services';
  static const String getServiceDetail = '/services/{id}';

  // Documents
  static const String getDocuments = '/vehicles/{id}/documents';
  static const String downloadPdf = '/documents/{id}/pdf';
}

class StatusConstants {
  static const String inService = 'in_service';
  static const String inProgress = 'in_progress';
  static const String ready = 'ready';
  static const String delivered = 'delivered';
}

class AppStrings {
  // General
  static const String error = 'Hata';
  static const String success = 'Başarılı';
  static const String loading = 'Yükleniyor...';
  static const String retry = 'Tekrar Dene';
  static const String cancel = 'İptal';
  static const String confirm = 'Onayla';
  static const String close = 'Kapat';
  static const String back = 'Geri';
  static const String next = 'İleri';
  static const String done = 'Tamam';
  static const String noData = 'Veri bulunamadı';
  static const String lastUpdated = 'Son güncelleme';

  // Auth
  static const String login = 'Giriş Yap';
  static const String logout = 'Çıkış Yap';
  static const String phoneNumber = 'Telefon Numarası';
  static const String enterPhoneNumber = 'Telefon numaranızı girin';
  static const String enterOtp = 'Doğrulama kodunu girin';
  static const String otpSent = 'Doğrulama kodu gönderildi';
  static const String resendOtp = 'Kodu tekrar gönder';
  static const String invalidPhone = 'Geçersiz telefon numarası';
  static const String invalidOtp = 'Geçersiz doğrulama kodu';

  // Vehicles
  static const String myVehicles = 'Araçlarım';
  static const String vehicleDetail = 'Araç Detayı';
  static const String licensePlate = 'Plaka';
  static const String brand = 'Marka';
  static const String model = 'Model';
  static const String vin = 'Şase Numarası (VIN)';
  static const String currentStatus = 'Durum';

  // Status
  static const String statusInService = 'Serviste';
  static const String statusInProgress = 'İşlemde';
  static const String statusReady = 'Hazır';
  static const String statusDelivered = 'Teslim Edildi';

  // Service
  static const String serviceHistory = 'Servis Geçmişi';
  static const String serviceDetail = 'Servis Detayı';
  static const String date = 'Tarih';
  static const String mileage = 'KM';
  static const String operations = 'Yapılan İşlemler';
  static const String parts = 'Değişen Parçalar';
  static const String totalAmount = 'Toplam Tutar';
  static const String viewDocuments = 'Belgeler';

  // Documents
  static const String documents = 'Belgeler';
  static const String serviceReceipt = 'Servis Fişi';
  static const String invoice = 'Fatura';
  static const String download = 'İndir';
  static const String view = 'Görüntüle';

  // Notifications
  static const String notificationVehicleReceived = 'Aracınız servise alındı';
  static const String notificationVehicleReady = 'Aracınız hazır!';
  static const String notificationVehicleDelivered = 'Aracınız teslim edildi';
}
