import 'dart:io';

class DbConfig {
  static String get host =>
      Platform.environment['MONGODB_HOST'] ??
      Platform.environment['DATABASE_HOST'] ??
      '127.0.0.1';

  static int get port =>
      int.tryParse(Platform.environment['MONGODB_PORT'] ??
          Platform.environment['DATABASE_PORT'] ??
          '27017') ??
      27017;

  static String get dbName =>
      Platform.environment['MONGODB_DB_NAME'] ??
      Platform.environment['DATABASE_NAME'] ??
      'library_management';

  static String? get user =>
      Platform.environment['MONGODB_USER'] ??
      Platform.environment['DATABASE_USER'];

  static String? get password =>
      Platform.environment['MONGODB_PASSWORD'] ??
      Platform.environment['DATABASE_PASSWORD'];

  /// Full MongoDB connection string URI
  static String get mongoUri {
    final explicitUri = Platform.environment['MONGODB_URI'];
    if (explicitUri != null && explicitUri.isNotEmpty) {
      return explicitUri;
    }

    final h = host == 'localhost' ? '127.0.0.1' : host;
    final u = user;
    final p = password;

    if (u != null && u.isNotEmpty && p != null && p.isNotEmpty) {
      final encodedUser = Uri.encodeComponent(u);
      final encodedPass = Uri.encodeComponent(p);
      return 'mongodb://$encodedUser:$encodedPass@$h:$port/$dbName';
    }

    return 'mongodb://$h:$port/$dbName';
  }

  static String get jwtSecret =>
      Platform.environment['JWT_SECRET'] ??
      'univ_library_management_jwt_super_secret_key_2026_x789qaz';

  static int get jwtExpirationHours =>
      int.tryParse(Platform.environment['JWT_EXPIRATION_HOURS'] ?? '24') ?? 24;
}
