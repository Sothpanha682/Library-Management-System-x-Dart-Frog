import 'package:dart_frog/dart_frog.dart';
import 'package:library_management_backend/models/api_response.dart';
import 'package:library_management_backend/services/book_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  try {
    final query = context.request.uri.queryParameters['q'] ?? '';
    final bookService = BookService();
    final books = await bookService.searchBooks(query);

    return ApiResponse.success(
      message: 'Search completed successfully',
      data: books.map((b) => b.toMap()).toList(),
    );
  } catch (e) {
    return ApiResponse.error(
      message: 'Search failed due to server error',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
