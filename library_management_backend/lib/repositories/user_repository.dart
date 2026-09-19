import '../auth/password_hasher.dart';
import '../database/db_connection.dart';
import '../models/user.dart';

class UserRepository {
  Future<User?> findById(int id) async {
    try {
      final results = await DbConnection.query(
        'SELECT id, name, email, password_hash, role, created_at, updated_at FROM users WHERE id = ? LIMIT 1',
        [id],
      );

      if (results.isEmpty) return null;
      final row = results.first;
      return User.fromMap(row.fields);
    } catch (_) {
      return null;
    }
  }

  Future<User?> findByEmail(String email) async {
    try {
      final results = await DbConnection.query(
        'SELECT id, name, email, password_hash, role, created_at, updated_at FROM users WHERE LOWER(email) = LOWER(?) LIMIT 1',
        [email.trim()],
      );

      if (results.isEmpty) return null;
      final row = results.first;
      return User.fromMap(row.fields);
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
    final passwordHash = PasswordHasher.hash(password);
    final now = DateTime.now();

    final result = await DbConnection.query(
      'INSERT INTO users (name, email, password_hash, role, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
      [name.trim(), email.trim().toLowerCase(), passwordHash, role, now, now],
    );

    final insertedId = result.insertId ?? 0;
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
      final results = await DbConnection.query(
        'SELECT id, name, email, role, created_at, updated_at FROM users ORDER BY id ASC',
      );

      return results.map((row) => User.fromMap(row.fields)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> updateProfile(int id, {required String name}) async {
    try {
      final result = await DbConnection.query(
        'UPDATE users SET name = ?, updated_at = ? WHERE id = ?',
        [name.trim(), DateTime.now(), id],
      );
      return (result.affectedRows ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }
}
