class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now(),
    );
  }

  final int id;
  final String name;
  final String email;
  final String passwordHash;
  final String role; // 'student' or 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAdmin => role == 'admin';
  bool get isStudent => role == 'student';

  Map<String, dynamic> toMap({bool includePassword = false}) {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (includePassword) 'password_hash': passwordHash,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
