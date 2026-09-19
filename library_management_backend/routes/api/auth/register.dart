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

    final name = data['name'] as String?;
    final email = data['email'] as String?;
    final password = data['password'] as String?;
    final role = (data['role'] as String?) ?? 'student';

    final validation = Validators.validateRegister(name: name, email: email, password: password);
    if (!validation.isValid) {
      return ApiResponse.error(
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        statusCode: 422,
        details: validation.errors,
      );
    }

    final authService = AuthService();
    final result = await authService.register(
      name: name!,
      email: email!,
      password: password!,
      role: role == 'admin' ? 'admin' : 'student',
    );

    return ApiResponse.success(
      message: 'User registered successfully',
      statusCode: 201,
      data: {
        'user': result.user.toMap(),
        'token': result.token,
      },
    );
  } catch (e) {
    if (e.toString().contains('EMAIL_ALREADY_EXISTS')) {
      return ApiResponse.error(
        message: 'A user with this email address already exists.',
        code: 'EMAIL_ALREADY_EXISTS',
        statusCode: 409,
      );
    }
    return ApiResponse.error(
      message: 'Failed to register user',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
