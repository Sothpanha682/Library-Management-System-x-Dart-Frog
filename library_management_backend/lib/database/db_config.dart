import 'dart:io';

class DbConfig {
  static String get host => Platform.environment['DATABASE_HOST'] ?? 'localhost';
  static int get port => int.tryParse(Platform.environment['DATABASE_PORT'] ?? '3306') ?? 3306;
  static String get dbName => Platform.environment['DATABASE_NAME'] ?? 'library_management';
  static String get user => Platform.environment['DATABASE_USER'] ?? 'root';
  static String get password => Platform.environment['DATABASE_PASSWORD'] ?? '';
  static String get jwtSecret => Platform.environment['JWT_SECRET'] ?? 'univ_library_management_jwt_super_secret_key_2026_x789qaz';
  static int get jwtExpirationHours => int.tryParse(Platform.environment['JWT_EXPIRATION_HOURS'] ?? '24') ?? 24;
}
