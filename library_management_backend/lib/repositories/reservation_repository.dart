import '../database/db_connection.dart';
import '../models/reservation.dart';

class ReservationRepository {
  Future<List<Reservation>> getByUser(int userId) async {
    try {
      const sql = '''
        SELECT r.*, bk.title AS book_title, bk.author AS book_author,
               bk.category AS book_category, bk.cover_image AS book_cover_image,
               u.name AS user_name, u.email AS user_email
        FROM reservations r
        JOIN books bk ON r.book_id = bk.id
        JOIN users u ON r.user_id = u.id
        WHERE r.user_id = ?
        ORDER BY r.id DESC
      ''';
      final results = await DbConnection.query(sql, [userId]);
      return results.map((r) => Reservation.fromMap(r.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Reservation>> getAll() async {
    try {
      const sql = '''
        SELECT r.*, bk.title AS book_title, bk.author AS book_author,
               bk.category AS book_category, bk.cover_image AS book_cover_image,
               u.name AS user_name, u.email AS user_email
        FROM reservations r
        JOIN books bk ON r.book_id = bk.id
        JOIN users u ON r.user_id = u.id
        ORDER BY r.id DESC
      ''';
      final results = await DbConnection.query(sql);
      return results.map((r) => Reservation.fromMap(r.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Reservation?> findById(int id) async {
    try {
      const sql = '''
        SELECT r.*, bk.title AS book_title, bk.author AS book_author,
               bk.category AS book_category, bk.cover_image AS book_cover_image,
               u.name AS user_name, u.email AS user_email
        FROM reservations r
        JOIN books bk ON r.book_id = bk.id
        JOIN users u ON r.user_id = u.id
        WHERE r.id = ?
        LIMIT 1
      ''';
      final results = await DbConnection.query(sql, [id]);
      if (results.isEmpty) return null;
      return Reservation.fromMap(results.first.fields);
    } catch (_) {
      return null;
    }
  }

  Future<Reservation?> findActiveByUserAndBook(int userId, int bookId) async {
    try {
      const sql = '''
        SELECT * FROM reservations
        WHERE user_id = ? AND book_id = ? AND status IN ('pending', 'available')
        LIMIT 1
      ''';
      final results = await DbConnection.query(sql, [userId, bookId]);
      if (results.isEmpty) return null;
      return Reservation.fromMap(results.first.fields);
    } catch (_) {
      return null;
    }
  }

  Future<Reservation> createReservation({
    required int userId,
    required int bookId,
    int holdDurationDays = 7,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: holdDurationDays));

    final result = await DbConnection.query(
      '''
      INSERT INTO reservations (user_id, book_id, reserved_at, expires_at, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, 'pending', ?, ?)
      ''',
      [userId, bookId, now, expiresAt, now, now],
    );

    final id = result.insertId ?? 0;
    return Reservation(
      id: id,
      userId: userId,
      bookId: bookId,
      reservedAt: now,
      expiresAt: expiresAt,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<bool> cancelReservation(int reservationId) async {
    try {
      final now = DateTime.now();
      final result = await DbConnection.query(
        "UPDATE reservations SET status = 'cancelled', updated_at = ? WHERE id = ? AND status IN ('pending', 'available')",
        [now, reservationId],
      );
      return (result.affectedRows ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }
}
