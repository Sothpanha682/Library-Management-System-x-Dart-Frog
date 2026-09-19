class Reservation {
  const Reservation({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.reservedAt,
    required this.expiresAt,
    required this.status,
    this.bookTitle,
    this.bookAuthor,
    this.bookCategory,
    this.bookCoverImage,
    this.userName,
    this.userEmail,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      bookId: json['book_id'] as int? ?? 0,
      reservedAt: json['reserved_at'] != null
          ? DateTime.tryParse(json['reserved_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      bookTitle: json['book_title'] as String?,
      bookAuthor: json['book_author'] as String?,
      bookCategory: json['book_category'] as String?,
      bookCoverImage: json['book_cover_image'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
    );
  }

  final int id;
  final int userId;
  final int bookId;
  final DateTime reservedAt;
  final DateTime expiresAt;
  final String status;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCategory;
  final String? bookCoverImage;
  final String? userName;
  final String? userEmail;

  bool get isActive => status == 'pending' || status == 'available';
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
