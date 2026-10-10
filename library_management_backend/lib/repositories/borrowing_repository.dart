import 'package:mongo_dart/mongo_dart.dart';
import '../database/db_connection.dart';
import '../models/borrowing.dart';

class BorrowingRepository {
  Future<Map<String, dynamic>> _populateSingle(Map<String, dynamic> doc) async {
    final m = Map<String, dynamic>.from(doc);
    final userId = m['user_id'] as int?;
    final bookId = m['book_id'] as int?;

    if (userId != null) {
      final userColl = await DbConnection.users;
      final userDoc = await userColl.findOne(where.eq('id', userId));
      if (userDoc != null) {
        m['user_name'] = userDoc['name'];
        m['user_email'] = userDoc['email'];
      }
    }

    if (bookId != null) {
      final bookColl = await DbConnection.books;
      final bookDoc = await bookColl.findOne(where.eq('id', bookId));
      if (bookDoc != null) {
        m['book_title'] = bookDoc['title'];
        m['book_author'] = bookDoc['author'];
        m['book_category'] = bookDoc['category'];
        m['book_cover_image'] = bookDoc['cover_image'];
      }
    }

    return m;
  }

  Future<List<Borrowing>> _populateList(List<Map<String, dynamic>> docs) async {
    if (docs.isEmpty) return [];

    final userIds = docs.map((d) => d['user_id'] as int).toSet().toList();
    final bookIds = docs.map((d) => d['book_id'] as int).toSet().toList();

    final userColl = await DbConnection.users;
    final bookColl = await DbConnection.books;

    final usersList = await userColl.find(where.oneFrom('id', userIds)).toList();
    final booksList = await bookColl.find(where.oneFrom('id', bookIds)).toList();

    final userMap = {for (var u in usersList) u['id'] as int: u};
    final bookMap = {for (var b in booksList) b['id'] as int: b};

    return docs.map((d) {
      final m = Map<String, dynamic>.from(d);
      final u = userMap[m['user_id']];
      if (u != null) {
        m['user_name'] = u['name'];
        m['user_email'] = u['email'];
      }
      final b = bookMap[m['book_id']];
      if (b != null) {
        m['book_title'] = b['title'];
        m['book_author'] = b['author'];
        m['book_category'] = b['category'];
        m['book_cover_image'] = b['cover_image'];
      }
      return Borrowing.fromMap(m);
    }).toList();
  }

  Future<List<Borrowing>> getByUser(int userId) async {
    try {
      final coll = await DbConnection.borrowings;
      final docs = await coll
          .find(where.eq('user_id', userId).sortBy('id', descending: true))
          .toList();
      return _populateList(docs);
    } catch (_) {
      return [];
    }
  }

  Future<List<Borrowing>> getAll() async {
    try {
      final coll = await DbConnection.borrowings;
      final docs = await coll
          .find(where.sortBy('id', descending: true))
          .toList();
      return _populateList(docs);
    } catch (_) {
      return [];
    }
  }

  Future<Borrowing?> findById(int id) async {
    try {
      final coll = await DbConnection.borrowings;
      final doc = await coll.findOne(where.eq('id', id));
      if (doc == null) return null;
      final populated = await _populateSingle(doc);
      return Borrowing.fromMap(populated);
    } catch (_) {
      return null;
    }
  }

  Future<Borrowing?> findActiveByUserAndBook(int userId, int bookId) async {
    try {
      final coll = await DbConnection.borrowings;
      final doc = await coll.findOne(
        where
            .eq('user_id', userId)
            .eq('book_id', bookId)
            .oneFrom('status', ['borrowed', 'overdue']),
      );
      if (doc == null) return null;
      final populated = await _populateSingle(doc);
      return Borrowing.fromMap(populated);
    } catch (_) {
      return null;
    }
  }

  Future<Borrowing> createBorrowing({
    required int userId,
    required int bookId,
    required int loanDurationDays,
  }) async {
    final now = DateTime.now();
    final dueDate = now.add(Duration(days: loanDurationDays));

    // 1. Decrement available quantity atomically if available > 0
    final bookColl = await DbConnection.books;
    final updateResult = await bookColl.updateOne(
      where.eq('id', bookId).gt('available_quantity', 0),
      modify.inc('available_quantity', -1).set('updated_at', now),
    );

    if (updateResult.nModified == 0) {
      throw Exception('BOOK_UNAVAILABLE');
    }

    // 2. Insert borrowing record
    final borrowingColl = await DbConnection.borrowings;
    final borrowingId = await DbConnection.getNextSequence('borrowingId');

    final doc = {
      'id': borrowingId,
      'user_id': userId,
      'book_id': bookId,
      'borrowed_at': now,
      'due_date': dueDate,
      'returned_at': null,
      'status': 'borrowed',
      'created_at': now,
      'updated_at': now,
    };

    await borrowingColl.insertOne(doc);

    final populated = await _populateSingle(doc);
    return Borrowing.fromMap(populated);
  }

  Future<bool> returnBook(int borrowingId) async {
    final borrowingColl = await DbConnection.borrowings;
    final borrowing = await borrowingColl.findOne(where.eq('id', borrowingId));
    if (borrowing == null) return false;

    final currentStatus = borrowing['status'] as String?;
    if (currentStatus == 'returned') {
      throw Exception('ALREADY_RETURNED');
    }

    final bookId = borrowing['book_id'] as int;
    final now = DateTime.now();

    // Mark returned
    await borrowingColl.updateOne(
      where.eq('id', borrowingId),
      modify
          .set('status', 'returned')
          .set('returned_at', now)
          .set('updated_at', now),
    );

    // Increment available quantity
    final bookColl = await DbConnection.books;
    await bookColl.updateOne(
      where.eq('id', bookId),
      modify.inc('available_quantity', 1).set('updated_at', now),
    );

    return true;
  }
}
