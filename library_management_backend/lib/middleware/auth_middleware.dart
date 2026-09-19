import 'package:dart_frog/dart_frog.dart';
import '../auth/auth_context.dart';
import '../auth/jwt_service.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

Middleware authRequiredMiddleware() {
  return (handler) {
    return (context) async {
      final authHeader = context.request.headers['Authorization'] ??
          context.request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return ApiResponse.error(
          message: 'Missing or malformed Authorization header',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );
      }

      final token = authHeader.substring(7).trim();
      final payload = JwtService.verifyToken(token);
      if (payload == null) {
        return ApiResponse.error(
          message: 'Invalid or expired token',
          code: 'TOKEN_INVALID',
          statusCode: 401,
        );
      }

      final userId = payload['id'] as int?;
      if (userId == null) {
        return ApiResponse.error(
          message: 'Token payload missing user ID',
          code: 'TOKEN_MALFORMED',
          statusCode: 401,
        );
      }

      final userRepository = UserRepository();
      final user = await userRepository.findById(userId);
      if (user == null) {
        return ApiResponse.error(
          message: 'User no longer exists',
          code: 'USER_NOT_FOUND',
          statusCode: 401,
        );
      }

      final authContext = AuthContext(user: user, token: token);
      return handler(context.provide<AuthContext>(() => authContext));
    };
  };
}

Middleware adminRequiredMiddleware() {
  return (handler) {
    return (context) async {
      try {
        final authContext = context.read<AuthContext>();
        if (!authContext.isAdmin) {
          return ApiResponse.error(
            message: 'Admin authorization required for this resource',
            code: 'FORBIDDEN',
            statusCode: 403,
          );
        }
      } catch (_) {
        return ApiResponse.error(
          message: 'Authentication required',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );
      }

      return handler(context);
    };
  };
}
