class Borrowing {
  const Borrowing({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.borrowedAt,
    required this.dueDate,
    this.returnedAt,
    required this.status, // 'borrowed', 'returned', 'overdue'
    required this.createdAt,
    required this.updatedAt,
    this.bookTitle,
    this.bookAuthor,
    this.bookCategory,
    this.bookCoverImage,
    this.userName,
    this.userEmail,
  });

  factory Borrowing.fromMap(Map<String, dynamic> map) {
    return Borrowing(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      bookId: map['book_id'] as int,
      borrowedAt: map['borrowed_at'] is DateTime
          ? map['borrowed_at'] as DateTime
          : DateTime.tryParse(map['borrowed_at'].toString()) ?? DateTime.now(),
      dueDate: map['due_date'] is DateTime
          ? map['due_date'] as DateTime
          : DateTime.tryParse(map['due_date'].toString()) ?? DateTime.now(),
      returnedAt: map['returned_at'] != null
          ? (map['returned_at'] is DateTime
              ? map['returned_at'] as DateTime
              : DateTime.tryParse(map['returned_at'].toString()))
          : null,
      status: map['status'] as String? ?? 'borrowed',
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
  final DateTime borrowedAt;
  final DateTime dueDate;
  final DateTime? returnedAt;
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

  bool get isReturned => status == 'returned';
  bool get isOverdue {
    if (isReturned) return false;
    return DateTime.now().isAfter(dueDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'borrowed_at': borrowedAt.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'returned_at': returnedAt?.toIso8601String(),
      'status': isOverdue && status == 'borrowed' ? 'overdue' : status,
      'is_overdue': isOverdue,
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
