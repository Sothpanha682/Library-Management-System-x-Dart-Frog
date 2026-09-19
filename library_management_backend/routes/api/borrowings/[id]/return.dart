import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/auth/auth_context.dart';
import '../../../../lib/models/api_response.dart';
import '../../../../lib/services/borrowing_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.put && context.request.method != HttpMethod.post) {
    return ApiResponse.error(
      message: 'Method not allowed. Use PUT to return a book.',
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
    final success = await borrowingService.returnBook(
      borrowingId: borrowingId,
      requestUserId: authContext.user.id,
      isAdmin: authContext.isAdmin,
    );

    if (!success) {
      return ApiResponse.error(
        message: 'Could not process book return',
        code: 'RETURN_FAILED',
        statusCode: 400,
      );
    }

    final updatedBorrowing = await borrowingService.getBorrowingById(borrowingId);

    return ApiResponse.success(
      message: 'Book returned successfully. Inventory updated.',
      data: updatedBorrowing?.toMap() ?? {},
    );
  } catch (e) {
    final errStr = e.toString();
    if (errStr.contains('BORROWING_NOT_FOUND')) {
      return ApiResponse.error(
        message: 'Borrowing record not found',
        code: 'NOT_FOUND',
        statusCode: 404,
      );
    }
    if (errStr.contains('FORBIDDEN')) {
      return ApiResponse.error(
        message: 'You are not authorized to return this borrowing record',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
    }
    if (errStr.contains('ALREADY_RETURNED')) {
      return ApiResponse.error(
        message: 'This book has already been returned',
        code: 'ALREADY_RETURNED',
        statusCode: 409,
      );
    }

    return ApiResponse.error(
      message: 'Return transaction failed: $errStr',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
