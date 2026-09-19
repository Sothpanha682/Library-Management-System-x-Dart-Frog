import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/auth_service.dart';
import '../../../lib/validation/validators.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  try {
    final bodyStr = await context.request.body();
    final data = jsonDecode(bodyStr) as Map<String, dynamic>;

    final email = data['email'] as String?;
    final password = data['password'] as String?;

    final validation = Validators.validateLogin(email: email, password: password);
    if (!validation.isValid) {
      return ApiResponse.error(
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        statusCode: 422,
        details: validation.errors,
      );
    }

    final authService = AuthService();
    final result = await authService.login(
      email: email!,
      password: password!,
    );

    return ApiResponse.success(
      message: 'Logged in successfully',
      data: {
        'user': result.user.toMap(),
        'token': result.token,
      },
    );
  } catch (e) {
    if (e.toString().contains('INVALID_CREDENTIALS')) {
      return ApiResponse.error(
        message: 'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
        statusCode: 401,
      );
    }
    return ApiResponse.error(
      message: 'Login failed due to server error',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
