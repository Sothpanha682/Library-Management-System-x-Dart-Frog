import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/models/api_response.dart';
import '../../../../lib/services/book_service.dart';
import '../../../../lib/validation/validators.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final bookId = int.tryParse(id);
  if (bookId == null) {
    return ApiResponse.error(
      message: 'Invalid book ID',
      code: 'INVALID_ID',
      statusCode: 400,
    );
  }

  final bookService = BookService();

  // PUT: Update book
  if (context.request.method == HttpMethod.put) {
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
      final availableQuantity = int.tryParse(data['available_quantity']?.toString() ?? '$quantity') ?? quantity;

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

      final updatedBook = await bookService.updateBook(
        bookId,
        title: title!,
        author: author!,
        category: category!,
        isbn: isbn!,
        description: description,
        coverImage: coverImage,
        quantity: quantity,
        availableQuantity: availableQuantity,
      );

      return ApiResponse.success(
        message: 'Book updated successfully',
        data: updatedBook.toMap(),
      );
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('BOOK_NOT_FOUND')) {
        return ApiResponse.error(
          message: 'Book not found',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      }
      return ApiResponse.error(
        message: 'Failed to update book: $errStr',
        code: 'SERVER_ERROR',
        statusCode: 500,
      );
    }
  }

  // DELETE: Delete book
  if (context.request.method == HttpMethod.delete) {
    try {
      final success = await bookService.deleteBook(bookId);
      if (!success) {
        return ApiResponse.error(
          message: 'Failed to delete book. It may have active borrowings.',
          code: 'DELETE_FAILED',
          statusCode: 400,
        );
      }

      return ApiResponse.success(
        message: 'Book deleted successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Delete failed due to active references or database constraints',
        code: 'DELETE_RESTRICTED',
        statusCode: 409,
      );
    }
  }

  return ApiResponse.error(
    message: 'Method not allowed',
    code: 'METHOD_NOT_ALLOWED',
    statusCode: 405,
  );
}
