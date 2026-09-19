import '../database/db_connection.dart';
import '../models/book.dart';

class BookRepository {
  Future<List<Book>> getAll({String? category, int page = 1, int limit = 50}) async {
    try {
      final offset = (page - 1) * limit;
      String sql = 'SELECT * FROM books';
      List<Object?> params = [];

      if (category != null && category.trim().isNotEmpty) {
        sql += ' WHERE LOWER(category) = LOWER(?)';
        params.add(category.trim());
      }

      sql += ' ORDER BY id DESC LIMIT ? OFFSET ?';
      params.addAll([limit, offset]);

      final results = await DbConnection.query(sql, params);
      return results.map((r) => Book.fromMap(r.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> count({String? category}) async {
    try {
      String sql = 'SELECT COUNT(*) AS total FROM books';
      List<Object?> params = [];

      if (category != null && category.trim().isNotEmpty) {
        sql += ' WHERE LOWER(category) = LOWER(?)';
        params.add(category.trim());
      }

      final results = await DbConnection.query(sql, params);
      if (results.isEmpty) return 0;
      return results.first['total'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Book>> search(String keyword) async {
    try {
      final pattern = '%${keyword.trim()}%';
      final sql = '''
        SELECT * FROM books
        WHERE title LIKE ? OR author LIKE ? OR category LIKE ? OR isbn LIKE ?
        ORDER BY id DESC
      ''';
      final results = await DbConnection.query(sql, [pattern, pattern, pattern, pattern]);
      return results.map((r) => Book.fromMap(r.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Book?> findById(int id) async {
    try {
      final results = await DbConnection.query('SELECT * FROM books WHERE id = ? LIMIT 1', [id]);
      if (results.isEmpty) return null;
      return Book.fromMap(results.first.fields);
    } catch (_) {
      return null;
    }
  }

  Future<Book?> findByIsbn(String isbn) async {
    try {
      final results = await DbConnection.query('SELECT * FROM books WHERE isbn = ? LIMIT 1', [isbn.trim()]);
      if (results.isEmpty) return null;
      return Book.fromMap(results.first.fields);
    } catch (_) {
      return null;
    }
  }

  Future<Book> create({
    required String title,
    required String author,
    required String category,
    required String isbn,
    String? description,
    String? coverImage,
    required int quantity,
  }) async {
    final now = DateTime.now();
    final result = await DbConnection.query(
      '''
      INSERT INTO books (title, author, category, isbn, description, cover_image, quantity, available_quantity, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        title.trim(),
        author.trim(),
        category.trim(),
        isbn.trim(),
        description?.trim(),
        coverImage?.trim(),
        quantity,
        quantity,
        now,
        now,
      ],
    );

    final id = result.insertId ?? 0;
    return Book(
      id: id,
      title: title.trim(),
      author: author.trim(),
      category: category.trim(),
      isbn: isbn.trim(),
      description: description?.trim(),
      coverImage: coverImage?.trim(),
      quantity: quantity,
      availableQuantity: quantity,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<bool> update(Book book) async {
    try {
      final now = DateTime.now();
      final result = await DbConnection.query(
        '''
        UPDATE books
        SET title = ?, author = ?, category = ?, isbn = ?, description = ?, cover_image = ?, quantity = ?, available_quantity = ?, updated_at = ?
        WHERE id = ?
        ''',
        [
          book.title,
          book.author,
          book.category,
          book.isbn,
          book.description,
          book.coverImage,
          book.quantity,
          book.availableQuantity,
          now,
          book.id,
        ],
      );
      return (result.affectedRows ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final result = await DbConnection.query('DELETE FROM books WHERE id = ?', [id]);
      return (result.affectedRows ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> adjustAvailableQuantity(int bookId, int delta, [dynamic txCtx]) async {
    try {
      final queryFunc = txCtx != null
          ? (String sql, List<Object?> params) => txCtx.query(sql, params)
          : (String sql, List<Object?> params) => DbConnection.query(sql, params);

      final result = await queryFunc(
        'UPDATE books SET available_quantity = available_quantity + ?, updated_at = ? WHERE id = ? AND available_quantity + ? >= 0',
        [delta, DateTime.now(), bookId, delta],
      );
      return (result.affectedRows ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }
}
