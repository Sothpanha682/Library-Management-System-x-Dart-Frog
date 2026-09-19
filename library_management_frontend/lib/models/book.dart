class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.isbn,
    this.description,
    this.coverImage,
    required this.quantity,
    required this.availableQuantity,
    this.createdAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Book',
      author: json['author'] as String? ?? 'Unknown Author',
      category: json['category'] as String? ?? 'General',
      isbn: json['isbn'] as String? ?? '',
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      availableQuantity: json['available_quantity'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  final int id;
  final String title;
  final String author;
  final String category;
  final String isbn;
  final String? description;
  final String? coverImage;
  final int quantity;
  final int availableQuantity;
  final DateTime? createdAt;

  bool get isAvailable => availableQuantity > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'isbn': isbn,
      'description': description,
      'cover_image': coverImage,
      'quantity': quantity,
      'available_quantity': availableQuantity,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
