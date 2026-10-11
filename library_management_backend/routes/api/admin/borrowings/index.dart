import 'package:dart_frog/dart_frog.dart';
import 'package:library_management_backend/models/api_response.dart';
import 'package:library_management_backend/services/borrowing_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  try {
    final borrowingService = BorrowingService();
    final borrowings = await borrowingService.getAllBorrowings();

    return ApiResponse.success(
      message: 'All borrowings retrieved successfully',
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
