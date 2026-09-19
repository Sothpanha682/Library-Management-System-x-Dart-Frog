import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../database/db_config.dart';
import '../models/user.dart';

class JwtService {
  static String generateToken(User user) {
    final jwt = JWT(
      {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'role': user.role,
      },
      issuer: 'library_management_api',
    );

    return jwt.sign(
      SecretKey(DbConfig.jwtSecret),
      expiresIn: Duration(hours: DbConfig.jwtExpirationHours),
    );
  }

  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(DbConfig.jwtSecret));
      return jwt.payload as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
