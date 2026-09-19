import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/reservation.dart';

class ReservationService {
  Future<List<Reservation>> getMyReservations() async {
    final response = await ApiClient.get(ApiEndpoints.reservations);
    final list = response['data'] as List<dynamic>;
    return list.map((r) => Reservation.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<List<Reservation>> getAllReservations() async {
    final response = await ApiClient.get(ApiEndpoints.adminReservations);
    final list = response['data'] as List<dynamic>;
    return list.map((r) => Reservation.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Reservation> createReservation(int bookId) async {
    final response = await ApiClient.post(
      ApiEndpoints.reservations,
      body: {'book_id': bookId},
    );
    return Reservation.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> cancelReservation(int reservationId) async {
    await ApiClient.delete(ApiEndpoints.reservationDetails(reservationId));
  }
}
