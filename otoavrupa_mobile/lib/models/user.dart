class User {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? email;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.email,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  String get formattedPhoneNumber {
    // Format: +90 555 123 4567
    if (phoneNumber.length == 12 && phoneNumber.startsWith('+')) {
      return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6, 9)} ${phoneNumber.substring(9)}';
    }
    return phoneNumber;
  }

  String get displayName => name ?? 'Müşteri';
}
