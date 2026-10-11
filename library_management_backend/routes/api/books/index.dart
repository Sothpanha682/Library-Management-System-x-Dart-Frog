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
    final queryParams = context.request.uri.queryParameters;
    final category = queryParams['category'];
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final limit = int.tryParse(queryParams['limit'] ?? '20') ?? 20;

    final bookService = BookService();
    final books = await bookService.getAllBooks(category: category, page: page, limit: limit);
    final total = await bookService.getTotalCount(category: category);

    return ApiResponse.list(
      message: 'Books retrieved successfully',
      data: books.map((b) => b.toMap()).toList(),
      page: page,
      limit: limit,
      total: total,
    );
  } catch (e) {
    return ApiResponse.error(
      message: 'Failed to retrieve books',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
