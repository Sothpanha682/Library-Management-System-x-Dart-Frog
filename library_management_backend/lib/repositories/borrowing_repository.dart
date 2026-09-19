import '../database/db_connection.dart';
import '../models/borrowing.dart';

class BorrowingRepository {
  Future<List<Borrowing>> getByUser(int userId) async {
    try {
      const sql = '''
        SELECT b.*, bk.title AS book_title, bk.author AS book_author,
               bk.category AS book_category, bk.cover_image AS book_cover_image,
               u.name AS user_name, u.email AS user_email
        FROM borrowings b
        JOIN books bk ON b.book_id = bk.id
        JOIN users u ON b.user_id = u.id
        WHERE b.user_id = ?
        ORDER BY b.id DESC
      ''';
      final results = await DbConnection.query(sql, [userId]);
      return results.map((r) => Borrowing.fromMap(r.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Borrowing>> getAll() async {
    try {
      const sql = '''
        SELECT b.*, bk.title AS book_title, bk.author AS book_author,
               bk.category AS book_category, bk.cover_image AS book_cover_image,
               u.name AS user_name, u.email AS user_email
        FROM borrowings b
        JOIN books bk ON b.book_id = bk.id
        JOIN users u ON b.user_id = u.id
        ORDER BY b.id DESC
      ''';
      final results = await DbConnection.query(sql);
      return results.map((r) => Borrowing.fromMap(r.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Borrowing?> findById(int id) async {
    try {
      const sql = '''
        SELECT b.*, bk.title AS book_title, bk.author AS book_author,
               bk.category AS book_category, bk.cover_image AS book_cover_image,
               u.name AS user_name, u.email AS user_email
        FROM borrowings b
        JOIN books bk ON b.book_id = bk.id
        JOIN users u ON b.user_id = u.id
        WHERE b.id = ?
        LIMIT 1
      ''';
      final results = await DbConnection.query(sql, [id]);
      if (results.isEmpty) return null;
      return Borrowing.fromMap(results.first.fields);
    } catch (_) {
      return null;
    }
  }

  Future<Borrowing?> findActiveByUserAndBook(int userId, int bookId) async {
    try {
      const sql = '''
        SELECT * FROM borrowings
        WHERE user_id = ? AND book_id = ? AND status IN ('borrowed', 'overdue')
        LIMIT 1
      ''';
      final results = await DbConnection.query(sql, [userId, bookId]);
      if (results.isEmpty) return null;
      return Borrowing.fromMap(results.first.fields);
    } catch (_) {
      return null;
    }
  }

  Future<Borrowing> createBorrowing({
    required int userId,
    required int bookId,
    required int loanDurationDays,
  }) async {
    return DbConnection.transaction<Borrowing>((ctx) async {
      final now = DateTime.now();
      final dueDate = now.add(Duration(days: loanDurationDays));

      // 1. Decrement available quantity
      final updateResult = await ctx.query(
        'UPDATE books SET available_quantity = available_quantity - 1, updated_at = ? WHERE id = ? AND available_quantity > 0',
        [now, bookId],
      );

      if ((updateResult.affectedRows ?? 0) == 0) {
        throw Exception('BOOK_UNAVAILABLE');
      }

      // 2. Insert borrowing record
      final insertResult = await ctx.query(
        '''
        INSERT INTO borrowings (user_id, book_id, borrowed_at, due_date, status, created_at, updated_at)
        VALUES (?, ?, ?, ?, 'borrowed', ?, ?)
        ''',
        [userId, bookId, now, dueDate, now, now],
      );

      final borrowingId = insertResult.insertId ?? 0;

      return Borrowing(
        id: borrowingId,
        userId: userId,
        bookId: bookId,
        borrowedAt: now,
        dueDate: dueDate,
        status: 'borrowed',
        createdAt: now,
        updatedAt: now,
      );
    });
  }

  Future<bool> returnBook(int borrowingId) async {
    return DbConnection.transaction<bool>((ctx) async {
      final now = DateTime.now();

      // Find borrowing
      final results = await ctx.query('SELECT book_id, status FROM borrowings WHERE id = ? LIMIT 1', [borrowingId]);
      if (results.isEmpty) return false;
      final bookId = results.first['book_id'] as int;
      final currentStatus = results.first['status'] as String;

      if (currentStatus == 'returned') {
        throw Exception('ALREADY_RETURNED');
      }

      // Mark returned
      await ctx.query(
        "UPDATE borrowings SET status = 'returned', returned_at = ?, updated_at = ? WHERE id = ?",
        [now, now, borrowingId],
      );

      // Increment available quantity
      await ctx.query(
        'UPDATE books SET available_quantity = available_quantity + 1, updated_at = ? WHERE id = ?',
        [now, bookId],
      );

      return true;
    });
  }
}
