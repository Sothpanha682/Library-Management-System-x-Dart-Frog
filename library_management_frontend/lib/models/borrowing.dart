class Borrowing {
  const Borrowing({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.borrowedAt,
    required this.dueDate,
    this.returnedAt,
    required this.status,
    this.bookTitle,
    this.bookAuthor,
    this.bookCategory,
    this.bookCoverImage,
    this.userName,
    this.userEmail,
  });

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    return Borrowing(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      bookId: json['book_id'] as int? ?? 0,
      borrowedAt: json['borrowed_at'] != null
          ? DateTime.tryParse(json['borrowed_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      returnedAt: json['returned_at'] != null
          ? DateTime.tryParse(json['returned_at'].toString())
          : null,
      status: json['status'] as String? ?? 'borrowed',
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
  final DateTime borrowedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;
  final String status;
  final String? bookTitle;
  final String? bookAuthor;
  final String? bookCategory;
  final String? bookCoverImage;
  final String? userName;
  final String? userEmail;

  bool get isReturned => status == 'returned';
  bool get isOverdue {
    if (isReturned) return false;
    return DateTime.now().isAfter(dueDate);
  }
}
