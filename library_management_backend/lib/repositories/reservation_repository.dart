import 'package:mongo_dart/mongo_dart.dart';
import '../database/db_connection.dart';
import '../models/reservation.dart';

class ReservationRepository {
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

  Future<List<Reservation>> _populateList(List<Map<String, dynamic>> docs) async {
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
      return Reservation.fromMap(m);
    }).toList();
  }

  Future<List<Reservation>> getByUser(int userId) async {
    try {
      final coll = await DbConnection.reservations;
      final docs = await coll
          .find(where.eq('user_id', userId).sortBy('id', descending: true))
          .toList();
      return _populateList(docs);
    } catch (_) {
      return [];
    }
  }

  Future<List<Reservation>> getAll() async {
    try {
      final coll = await DbConnection.reservations;
      final docs = await coll
          .find(where.sortBy('id', descending: true))
          .toList();
      return _populateList(docs);
    } catch (_) {
      return [];
    }
  }

  Future<Reservation?> findById(int id) async {
    try {
      final coll = await DbConnection.reservations;
      final doc = await coll.findOne(where.eq('id', id));
      if (doc == null) return null;
      final populated = await _populateSingle(doc);
      return Reservation.fromMap(populated);
    } catch (_) {
      return null;
    }
  }

  Future<Reservation?> findActiveByUserAndBook(int userId, int bookId) async {
    try {
      final coll = await DbConnection.reservations;
      final doc = await coll.findOne(
        where
            .eq('user_id', userId)
            .eq('book_id', bookId)
            .oneFrom('status', ['pending', 'available']),
      );
      if (doc == null) return null;
      final populated = await _populateSingle(doc);
      return Reservation.fromMap(populated);
    } catch (_) {
      return null;
    }
  }

  Future<Reservation> createReservation({
    required int userId,
    required int bookId,
    int holdDurationDays = 7,
  }) async {
    final coll = await DbConnection.reservations;
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: holdDurationDays));
    final id = await DbConnection.getNextSequence('reservationId');

    final doc = {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'reserved_at': now,
      'expires_at': expiresAt,
      'status': 'pending',
      'created_at': now,
      'updated_at': now,
    };

    await coll.insertOne(doc);

    final populated = await _populateSingle(doc);
    return Reservation.fromMap(populated);
  }

  Future<bool> cancelReservation(int reservationId) async {
    try {
      final coll = await DbConnection.reservations;
      final now = DateTime.now();
      final res = await coll.updateOne(
        where
            .eq('id', reservationId)
            .oneFrom('status', ['pending', 'available']),
        modify.set('status', 'cancelled').set('updated_at', now),
      );
      return res.nModified > 0;
    } catch (_) {
      return false;
    }
  }
}
