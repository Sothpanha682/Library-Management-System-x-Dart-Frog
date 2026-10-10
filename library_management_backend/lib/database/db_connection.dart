import 'package:mongo_dart/mongo_dart.dart';
import 'db_config.dart';

/// Database Manager wrapping MongoDB connection and collections
class DbConnection {
  static Db? _db;

  /// Retrieves or opens the MongoDB database connection
  static Future<Db> getDb() async {
    if (_db != null && _db!.isConnected) {
      return _db!;
    }

    try {
      final db = await Db.create(DbConfig.mongoUri);
      await db.open();
      _db = db;
      return _db!;
    } catch (e) {
      rethrow;
    }
  }

  /// Shorthand to access a specific collection
  static Future<DbCollection> getCollection(String collectionName) async {
    final db = await getDb();
    return db.collection(collectionName);
  }

  static Future<DbCollection> get users => getCollection('users');
  static Future<DbCollection> get books => getCollection('books');
  static Future<DbCollection> get borrowings => getCollection('borrowings');
  static Future<DbCollection> get reservations => getCollection('reservations');
  static Future<DbCollection> get counters => getCollection('counters');

  /// Atomically generates the next auto-increment integer ID for a given sequence name
  static Future<int> getNextSequence(String sequenceName) async {
    final coll = await counters;
    try {
      final res = await coll.findAndModify(
        query: where.eq('_id', sequenceName),
        update: modify.inc('seq', 1),
        returnNew: true,
        upsert: true,
      );
      if (res != null && res['seq'] != null) {
        return (res['seq'] as num).toInt();
      }
    } catch (_) {}

    // Fallback if findAndModify returns null
    final existing = await coll.findOne(where.eq('_id', sequenceName));
    if (existing == null) {
      await coll.insertOne({'_id': sequenceName, 'seq': 1});
      return 1;
    } else {
      final nextVal = ((existing['seq'] as num?)?.toInt() ?? 0) + 1;
      await coll.updateOne(
        where.eq('_id', sequenceName),
        modify.set('seq', nextVal),
      );
      return nextVal;
    }
  }

  /// Closes database connection
  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
    }
    _db = null;
  }
}
