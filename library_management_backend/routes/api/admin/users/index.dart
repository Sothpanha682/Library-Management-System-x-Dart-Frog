import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/models/api_response.dart';
import '../../../../lib/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  try {
    final authService = AuthService();
    final users = await authService.getAllUsers();

    return ApiResponse.success(
      message: 'Users retrieved successfully',
      data: users.map((u) => u.toMap()).toList(),
    );
  } catch (e) {
    return ApiResponse.error(
      message: 'Failed to retrieve users',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
