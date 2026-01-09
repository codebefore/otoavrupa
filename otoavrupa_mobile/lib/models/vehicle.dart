class Vehicle {
  final int id;
  final String licensePlate;
  final String brand;
  final String model;
  final String vin;
  final String currentStatus;
  final DateTime lastUpdated;
  final int? serviceCount;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.vin,
    required this.currentStatus,
    required this.lastUpdated,
    this.serviceCount,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      licensePlate: json['license_plate'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      vin: json['vin'] as String,
      currentStatus: json['current_status'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      serviceCount: json['service_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'brand': brand,
      'model': model,
      'vin': vin,
      'current_status': currentStatus,
      'last_updated': lastUpdated.toIso8601String(),
      'service_count': serviceCount,
    };
  }

  Vehicle copyWith({
    int? id,
    String? licensePlate,
    String? brand,
    String? model,
    String? vin,
    String? currentStatus,
    DateTime? lastUpdated,
    int? serviceCount,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      vin: vin ?? this.vin,
      currentStatus: currentStatus ?? this.currentStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      serviceCount: serviceCount ?? this.serviceCount,
    );
  }

  String get fullName => '$brand $model';
  String get formattedLicensePlate => licensePlate.toUpperCase();
}
