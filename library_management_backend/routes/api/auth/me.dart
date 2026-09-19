import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/auth/auth_context.dart';
import '../../../lib/middleware/auth_middleware.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/auth_service.dart';

Handler middleware(Handler handler) {
  return handler.use(authRequiredMiddleware());
}

Future<Response> onRequest(RequestContext context) async {
  final authContext = context.read<AuthContext>();
  final authService = AuthService();

  if (context.request.method == HttpMethod.get) {
    final user = await authService.getMe(authContext.user.id);
    if (user == null) {
      return ApiResponse.error(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
        statusCode: 404,
      );
    }

    return ApiResponse.success(
      message: 'Profile retrieved successfully',
      data: user.toMap(),
    );
  }

  if (context.request.method == HttpMethod.put) {
    try {
      final bodyStr = await context.request.body();
      final data = jsonDecode(bodyStr) as Map<String, dynamic>;
      final name = data['name'] as String?;

      if (name == null || name.trim().length < 2) {
        return ApiResponse.error(
          message: 'Valid name is required (minimum 2 characters).',
          code: 'VALIDATION_ERROR',
          statusCode: 422,
        );
      }

      final success = await authService.updateProfile(authContext.user.id, name: name);
      if (!success) {
        return ApiResponse.error(
          message: 'Failed to update profile',
          code: 'UPDATE_FAILED',
          statusCode: 400,
        );
      }

      final updatedUser = await authService.getMe(authContext.user.id);
      return ApiResponse.success(
        message: 'Profile updated successfully',
        data: updatedUser?.toMap() ?? {},
      );
    } catch (_) {
      return ApiResponse.error(
        message: 'Invalid request body',
        code: 'BAD_REQUEST',
        statusCode: 400,
      );
    }
  }

  return ApiResponse.error(
    message: 'Method not allowed',
    code: 'METHOD_NOT_ALLOWED',
    statusCode: 405,
  );
}
