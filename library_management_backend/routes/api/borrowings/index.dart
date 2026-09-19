import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/auth/auth_context.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/borrowing_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final authContext = context.read<AuthContext>();
  final borrowingService = BorrowingService();

  // GET: View borrowings
  if (context.request.method == HttpMethod.get) {
    try {
      final borrowings = await borrowingService.getMyBorrowings(authContext.user.id);
      return ApiResponse.success(
        message: 'Borrowings retrieved successfully',
        data: borrowings.map((b) => b.toMap()).toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to retrieve borrowings',
        code: 'SERVER_ERROR',
        statusCode: 500,
      );
    }
  }

  // POST: Borrow a book
  if (context.request.method == HttpMethod.post) {
    try {
      final bodyStr = await context.request.body();
      final data = jsonDecode(bodyStr) as Map<String, dynamic>;
      final bookId = data['book_id'] as int?;

      if (bookId == null || bookId <= 0) {
        return ApiResponse.error(
          message: 'A valid book_id is required',
          code: 'INVALID_INPUT',
          statusCode: 422,
        );
      }

      final borrowing = await borrowingService.borrowBook(
        userId: authContext.user.id,
        bookId: bookId,
      );

      return ApiResponse.success(
        message: 'Book borrowed successfully',
        statusCode: 201,
        data: borrowing.toMap(),
      );
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('BOOK_NOT_FOUND')) {
        return ApiResponse.error(
          message: 'Book not found',
          code: 'BOOK_NOT_FOUND',
          statusCode: 404,
        );
      }
      if (errStr.contains('BOOK_UNAVAILABLE')) {
        return ApiResponse.error(
          message: 'Book is currently not available for borrowing. You may reserve it.',
          code: 'BOOK_UNAVAILABLE',
          statusCode: 409,
        );
      }
      if (errStr.contains('DUPLICATE_ACTIVE_BORROWING')) {
        return ApiResponse.error(
          message: 'You already have an active borrowing for this book.',
          code: 'DUPLICATE_ACTIVE_BORROWING',
          statusCode: 409,
        );
      }
      return ApiResponse.error(
        message: 'Borrowing transaction failed: $errStr',
        code: 'SERVER_ERROR',
        statusCode: 500,
      );
    }
  }

  return ApiResponse.error(
    message: 'Method not allowed',
    code: 'METHOD_NOT_ALLOWED',
    statusCode: 405,
  );
}
