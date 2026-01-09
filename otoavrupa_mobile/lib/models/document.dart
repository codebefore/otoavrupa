class Document {
  final int id;
  final String vehicleId;
  final int serviceRecordId;
  final String documentType; // 'service_receipt' or 'invoice'
  final String title;
  final String fileUrl;
  final DateTime createdAt;

  Document({
    required this.id,
    required this.vehicleId,
    required this.serviceRecordId,
    required this.documentType,
    required this.title,
    required this.fileUrl,
    required this.createdAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as String,
      serviceRecordId: json['service_record_id'] as int,
      documentType: json['document_type'] as String,
      title: json['title'] as String,
      fileUrl: json['file_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'service_record_id': serviceRecordId,
      'document_type': documentType,
      'title': title,
      'file_url': fileUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isServiceReceipt => documentType == 'service_receipt';
  bool get isInvoice => documentType == 'invoice';

  String get formattedDate => '${createdAt.day}.${createdAt.month}.${createdAt.year}';
}
