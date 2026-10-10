import 'package:mongo_dart/mongo_dart.dart';
import '../database/db_connection.dart';
import '../models/book.dart';

class BookRepository {
  Future<List<Book>> getAll({String? category, int page = 1, int limit = 50}) async {
    try {
      final coll = await DbConnection.books;
      final offset = (page - 1) * limit;

      var q = where.sortBy('id', descending: true);
      if (category != null && category.trim().isNotEmpty) {
        q = where
            .match('category', '^${RegExp.escape(category.trim())}\$', caseInsensitive: true)
            .sortBy('id', descending: true);
      }

      final results = await coll.find(q.skip(offset).limit(limit)).toList();
      return results.map((doc) => Book.fromMap(doc)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> count({String? category}) async {
    try {
      final coll = await DbConnection.books;
      if (category != null && category.trim().isNotEmpty) {
        return await coll.count(
          where.match('category', '^${RegExp.escape(category.trim())}\$', caseInsensitive: true),
        );
      }
      return await coll.count();
    } catch (_) {
      return 0;
    }
  }

  Future<List<Book>> search(String keyword) async {
    try {
      final coll = await DbConnection.books;
      final escaped = RegExp.escape(keyword.trim());
      final q = where
          .match('title', escaped, caseInsensitive: true)
          .or(where.match('author', escaped, caseInsensitive: true))
          .or(where.match('category', escaped, caseInsensitive: true))
          .or(where.match('isbn', escaped, caseInsensitive: true))
          .sortBy('id', descending: true);

      final results = await coll.find(q).toList();
      return results.map((doc) => Book.fromMap(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Book?> findById(int id) async {
    try {
      final coll = await DbConnection.books;
      final doc = await coll.findOne(where.eq('id', id));
      if (doc == null) return null;
      return Book.fromMap(doc);
    } catch (_) {
      return null;
    }
  }

  Future<Book?> findByIsbn(String isbn) async {
    try {
      final coll = await DbConnection.books;
      final doc = await coll.findOne(where.eq('isbn', isbn.trim()));
      if (doc == null) return null;
      return Book.fromMap(doc);
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
    final coll = await DbConnection.books;
    final now = DateTime.now();
    final id = await DbConnection.getNextSequence('bookId');

    final doc = {
      'id': id,
      'title': title.trim(),
      'author': author.trim(),
      'category': category.trim(),
      'isbn': isbn.trim(),
      'description': description?.trim(),
      'cover_image': coverImage?.trim(),
      'quantity': quantity,
      'available_quantity': quantity,
      'created_at': now,
      'updated_at': now,
    };

    await coll.insertOne(doc);

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
      final coll = await DbConnection.books;
      final now = DateTime.now();
      final res = await coll.updateOne(
        where.eq('id', book.id),
        modify
            .set('title', book.title)
            .set('author', book.author)
            .set('category', book.category)
            .set('isbn', book.isbn)
            .set('description', book.description)
            .set('cover_image', book.coverImage)
            .set('quantity', book.quantity)
            .set('available_quantity', book.availableQuantity)
            .set('updated_at', now),
      );
      return res.nModified > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(int id) async {
    try {
      final coll = await DbConnection.books;
      final res = await coll.deleteOne(where.eq('id', id));
      return res.nRemoved > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> adjustAvailableQuantity(int bookId, int delta, [dynamic txCtx]) async {
    try {
      final coll = await DbConnection.books;
      var q = where.eq('id', bookId);
      if (delta < 0) {
        q = q.gte('available_quantity', -delta);
      }

      final res = await coll.updateOne(
        q,
        modify.inc('available_quantity', delta).set('updated_at', DateTime.now()),
      );
      return res.nModified > 0;
    } catch (_) {
      return false;
    }
  }
}
