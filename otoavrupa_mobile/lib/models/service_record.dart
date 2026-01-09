class ServiceRecord {
  final int id;
  final int vehicleId;
  final DateTime serviceDate;
  final int mileage;
  final String operations;
  final String? parts;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceDate,
    required this.mileage,
    required this.operations,
    this.parts,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int,
      serviceDate: DateTime.parse(json['service_date'] as String),
      mileage: json['mileage'] as int,
      operations: json['operations'] as String,
      parts: json['parts'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'service_date': serviceDate.toIso8601String(),
      'mileage': mileage,
      'operations': operations,
      'parts': parts,
      'total_amount': totalAmount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedMileage => '$mileage KM';
  String get formattedAmount => '₺${totalAmount.toStringAsFixed(2)}';
  String get formattedDate => '${serviceDate.day}.${serviceDate.month}.${serviceDate.year}';

  List<String> get operationsList => operations.split(',').map((e) => e.trim()).toList();
  List<String>? get partsList => parts?.split(',').map((e) => e.trim()).toList();
}
