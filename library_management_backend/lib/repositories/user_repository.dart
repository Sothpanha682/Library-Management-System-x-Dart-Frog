import 'package:mongo_dart/mongo_dart.dart';
import '../auth/password_hasher.dart';
import '../database/db_connection.dart';
import '../models/user.dart';

class UserRepository {
  Future<User?> findById(int id) async {
    try {
      final coll = await DbConnection.users;
      final doc = await coll.findOne(where.eq('id', id));
      if (doc == null) return null;
      return User.fromMap(doc);
    } catch (_) {
      return null;
    }
  }

  Future<User?> findByEmail(String email) async {
    try {
      final coll = await DbConnection.users;
      final cleanEmail = email.trim().toLowerCase();
      final doc = await coll.findOne(
        where.match('email', '^${RegExp.escape(cleanEmail)}\$', caseInsensitive: true),
      );
      if (doc == null) return null;
      return User.fromMap(doc);
    } catch (_) {
      return null;
    }
  }

  Future<User> create({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    final coll = await DbConnection.users;
    final passwordHash = PasswordHasher.hash(password);
    final now = DateTime.now();
    final insertedId = await DbConnection.getNextSequence('userId');

    final doc = {
      'id': insertedId,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password_hash': passwordHash,
      'role': role,
      'created_at': now,
      'updated_at': now,
    };

    await coll.insertOne(doc);

    return User(
      id: insertedId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: passwordHash,
      role: role,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<List<User>> getAll() async {
    try {
      final coll = await DbConnection.users;
      final list = await coll.find(where.sortBy('id')).toList();
      return list.map((doc) => User.fromMap(doc)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateProfile(int id, {required String name}) async {
    try {
      final coll = await DbConnection.users;
      final res = await coll.updateOne(
        where.eq('id', id),
        modify.set('name', name.trim()).set('updated_at', DateTime.now()),
      );
      return res.nModified > 0;
    } catch (_) {
      return false;
    }
  }
}
