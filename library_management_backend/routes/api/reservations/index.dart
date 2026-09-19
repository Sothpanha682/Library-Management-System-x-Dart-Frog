import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/auth/auth_context.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/reservation_service.dart';

Future<Response> onRequest(RequestContext context) async {
  final authContext = context.read<AuthContext>();
  final reservationService = ReservationService();

  // GET: View user's reservations
  if (context.request.method == HttpMethod.get) {
    try {
      final reservations = await reservationService.getMyReservations(authContext.user.id);
      return ApiResponse.success(
        message: 'Reservations retrieved successfully',
        data: reservations.map((r) => r.toMap()).toList(),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to retrieve reservations',
        code: 'SERVER_ERROR',
        statusCode: 500,
      );
    }
  }

  // POST: Reserve a book
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

      final reservation = await reservationService.createReservation(
        userId: authContext.user.id,
        bookId: bookId,
      );

      return ApiResponse.success(
        message: 'Book reserved successfully',
        statusCode: 201,
        data: reservation.toMap(),
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
      if (errStr.contains('DUPLICATE_ACTIVE_RESERVATION')) {
        return ApiResponse.error(
          message: 'You already have an active reservation for this book.',
          code: 'DUPLICATE_ACTIVE_RESERVATION',
          statusCode: 409,
        );
      }

      return ApiResponse.error(
        message: 'Failed to reserve book: $errStr',
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
