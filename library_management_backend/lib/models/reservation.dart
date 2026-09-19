class Reservation {
  const Reservation({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.reservedAt,
    required this.expiresAt,
    required this.status, // 'pending', 'available', 'completed', 'cancelled', 'expired'
    required this.createdAt,
    required this.updatedAt,
    this.bookTitle,
    this.bookAuthor,
    this.bookCategory,
    this.bookCoverImage,
    this.userName,
    this.userEmail,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      bookId: map['book_id'] as int,
      reservedAt: map['reserved_at'] is DateTime
          ? map['reserved_at'] as DateTime
          : DateTime.tryParse(map['reserved_at'].toString()) ?? DateTime.now(),
      expiresAt: map['expires_at'] is DateTime
          ? map['expires_at'] as DateTime
          : DateTime.tryParse(map['expires_at'].toString()) ?? DateTime.now(),
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now(),
      bookTitle: map['book_title'] as String?,
      bookAuthor: map['book_author'] as String?,
      bookCategory: map['book_category'] as String?,
      bookCoverImage: map['book_cover_image'] as String?,
      userName: map['user_name'] as String?,
      userEmail: map['user_email'] as String?,
    );
  }

  final int id;
  final int userId;
  final int bookId;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCategory;
  final String? bookCoverImage;
  final String? userName;
  final String? userEmail;

  bool get isActive => status == 'pending' || status == 'available';
  bool get isExpired {
    if (status == 'completed' || status == 'cancelled') return false;
    return DateTime.now().isAfter(expiresAt);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'reserved_at': reservedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'status': isExpired && status == 'pending' ? 'expired' : status,
      'is_expired': isExpired,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (bookTitle != null) 'book_title': bookTitle,
      if (bookAuthor != null) 'book_author': bookAuthor,
      if (bookCategory != null) 'book_category': bookCategory,
      if (bookCoverImage != null) 'book_cover_image': bookCoverImage,
      if (userName != null) 'user_name': userName,
      if (userEmail != null) 'user_email': userEmail,
    };
  }
}
