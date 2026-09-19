import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/models/api_response.dart';
import '../../../../lib/services/reservation_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return ApiResponse.error(
      message: 'Method not allowed',
      code: 'METHOD_NOT_ALLOWED',
      statusCode: 405,
    );
  }

  try {
    final reservationService = ReservationService();
    final reservations = await reservationService.getAllReservations();

    return ApiResponse.success(
      message: 'All reservations retrieved successfully',
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
