import 'package:dart_frog/dart_frog.dart';
import '../../../lib/auth/auth_context.dart';
import '../../../lib/models/api_response.dart';
import '../../../lib/services/reservation_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final reservationId = int.tryParse(id);
  if (reservationId == null) {
    return ApiResponse.error(
      message: 'Invalid reservation ID',
      code: 'INVALID_ID',
      statusCode: 400,
    );
  }

  final authContext = context.read<AuthContext>();
  final reservationService = ReservationService();

  // GET: View details
  if (context.request.method == HttpMethod.get) {
    try {
      final reservation = await reservationService.getReservationById(reservationId);
      if (reservation == null) {
        return ApiResponse.error(
          message: 'Reservation not found',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      }

      if (!authContext.isAdmin && reservation.userId != authContext.user.id) {
        return ApiResponse.error(
          message: 'Access denied',
          code: 'FORBIDDEN',
          statusCode: 403,
        );
      }

      return ApiResponse.success(
        message: 'Reservation details retrieved',
        data: reservation.toMap(),
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to retrieve reservation',
        code: 'SERVER_ERROR',
        statusCode: 500,
      );
    }
  }

  // DELETE: Cancel reservation
  if (context.request.method == HttpMethod.delete) {
    try {
      final success = await reservationService.cancelReservation(
        reservationId: reservationId,
        requestUserId: authContext.user.id,
        isAdmin: authContext.isAdmin,
      );

      if (!success) {
        return ApiResponse.error(
          message: 'Could not cancel reservation',
          code: 'CANCEL_FAILED',
          statusCode: 400,
        );
      }

      return ApiResponse.success(
        message: 'Reservation cancelled successfully',
      );
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('RESERVATION_NOT_FOUND')) {
        return ApiResponse.error(
          message: 'Reservation not found',
          code: 'NOT_FOUND',
          statusCode: 404,
        );
      }
      if (errStr.contains('FORBIDDEN')) {
        return ApiResponse.error(
          message: 'Access denied to cancel this reservation',
          code: 'FORBIDDEN',
          statusCode: 403,
        );
      }
      if (errStr.contains('RESERVATION_NOT_ACTIVE')) {
        return ApiResponse.error(
          message: 'Only pending or active reservations can be cancelled',
          code: 'NOT_ACTIVE',
          statusCode: 400,
        );
      }

      return ApiResponse.error(
        message: 'Cancellation failed: $errStr',
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
