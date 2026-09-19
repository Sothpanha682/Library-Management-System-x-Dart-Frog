import 'package:dart_frog/dart_frog.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/book_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.get) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  final bookId = int.tryParse(id);
  if (bookId == null) {
    return ApiResponse.error(
      message: 'Invalid book ID',
      code: 'INVALID_ID',
      statusCode: 400,
    );
  }

  try {
    final bookService = BookService();
    final book = await bookService.getBookById(bookId);

    if (book == null) {
      return ApiResponse.error(
        message: 'Book not found',
        code: 'BOOK_NOT_FOUND',
        statusCode: 404,
      );
    }

    return ApiResponse.success(
      message: 'Book retrieved successfully',
      data: book.toMap(),
    );
  } catch (e) {
    return ApiResponse.error(
      message: 'Failed to retrieve book',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
