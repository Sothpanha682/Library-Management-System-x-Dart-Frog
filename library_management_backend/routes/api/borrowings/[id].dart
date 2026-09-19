import 'package:dart_frog/dart_frog.dart';
import '../../../lib/auth/auth_context.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/borrowing_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  final borrowingId = int.tryParse(id);
  if (borrowingId == null) {
    return ApiResponse.error(
      message: 'Invalid borrowing ID',
      code: 'INVALID_ID',
      statusCode: 400,
    );
  }

  final authContext = context.read<AuthContext>();
  final borrowingService = BorrowingService();

  try {
    final borrowing = await borrowingService.getBorrowingById(borrowingId);
    if (borrowing == null) {
      return ApiResponse.error(
        message: 'Borrowing record not found',
        code: 'NOT_FOUND',
        statusCode: 404,
      );
    }

    if (!authContext.isAdmin && borrowing.userId != authContext.user.id) {
      return ApiResponse.error(
        message: 'Access denied to this borrowing record',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }

    return ApiResponse.success(
      message: 'Borrowing record retrieved successfully',
      data: borrowing.toMap(),
    );
  } catch (e) {
    return ApiResponse.error(
      message: 'Failed to retrieve borrowing record',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
