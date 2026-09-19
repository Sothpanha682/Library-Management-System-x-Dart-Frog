import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/models/api_response.dart';
import '../../../../lib/services/book_service.dart';
import '../../../../lib/validation/validators.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return ApiResponse.error(
      message: 'Method not allowed. Use POST to add books.',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  try {
    final bodyStr = await context.request.body();
    final data = jsonDecode(bodyStr) as Map<String, dynamic>;

    final title = data['title'] as String?;
    final author = data['author'] as String?;
    final category = data['category'] as String?;
    final isbn = data['isbn'] as String?;
    final description = data['description'] as String?;
    final coverImage = data['cover_image'] as String?;
    final quantity = int.tryParse(data['quantity']?.toString() ?? '1') ?? 1;

    final validation = Validators.validateBook(
      title: title,
      author: author,
      category: category,
      isbn: isbn,
      quantity: quantity,
    );

    if (!validation.isValid) {
      return ApiResponse.error(
        message: 'Validation failed',
        code: 'VALIDATION_ERROR',
        statusCode: 422,
        details: validation.errors,
      );
    }

    final bookService = BookService();
    final newBook = await bookService.createBook(
      title: title!,
      author: author!,
      category: category!,
      isbn: isbn!,
      description: description,
      coverImage: coverImage,
      quantity: quantity,
    );

    return ApiResponse.success(
      message: 'Book created successfully by admin',
      statusCode: 201,
      data: newBook.toMap(),
    );
  } catch (e) {
    if (e.toString().contains('ISBN_ALREADY_EXISTS')) {
      return ApiResponse.error(
        message: 'A book with this ISBN already exists',
        code: 'ISBN_ALREADY_EXISTS',
        statusCode: 409,
      );
    }

    return ApiResponse.error(
      message: 'Failed to create book',
      code: 'SERVER_ERROR',
      statusCode: 500,
    );
  }
}
