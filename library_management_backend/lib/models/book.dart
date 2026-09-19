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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int,
      title: map['title'] as String,
      author: map['author'] as String,
      category: map['category'] as String,
      isbn: map['isbn'] as String,
      description: map['description'] as String?,
      coverImage: map['cover_image'] as String?,
      quantity: map['quantity'] as int,
      availableQuantity: map['available_quantity'] as int,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now(),
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
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAvailable => availableQuantity > 0;

  Map<String, dynamic> toMap() {
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
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? category,
    String? isbn,
    String? description,
    String? coverImage,
    int? quantity,
    int? availableQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      isbn: isbn ?? this.isbn,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      quantity: quantity ?? this.quantity,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
