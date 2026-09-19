import '../models/reservation.dart';
import '../repositories/book_repository.dart';
import '../repositories/reservation_repository.dart';

class ReservationService {
  ReservationService({
    ReservationRepository? reservationRepository,
    BookRepository? bookRepository,
  })  : _reservationRepository = reservationRepository ?? ReservationRepository(),
        _bookRepository = bookRepository ?? BookRepository();

  final ReservationRepository _reservationRepository;
  final BookRepository _bookRepository;

  Future<List<Reservation>> getMyReservations(int userId) async {
    return _reservationRepository.getByUser(userId);
  }

  Future<List<Reservation>> getAllReservations() async {
    return _reservationRepository.getAll();
  }

  Future<Reservation?> getReservationById(int id) async {
    return _reservationRepository.findById(id);
  }

  Future<Reservation> createReservation({
    required int userId,
    required int bookId,
  }) async {
    // 1. Verify book exists
    final book = await _bookRepository.findById(bookId);
    if (book == null) {
      throw Exception('BOOK_NOT_FOUND');
    }

    // 2. Prevent duplicate active reservation
    final existingActive = await _reservationRepository.findActiveByUserAndBook(userId, bookId);
    if (existingActive != null) {
      throw Exception('DUPLICATE_ACTIVE_RESERVATION');
    }

    // 3. Create reservation
    return _reservationRepository.createReservation(
      userId: userId,
      bookId: bookId,
    );
  }

  Future<bool> cancelReservation({
    required int reservationId,
    required int requestUserId,
    required bool isAdmin,
  }) async {
    final reservation = await _reservationRepository.findById(reservationId);
    if (reservation == null) {
      throw Exception('RESERVATION_NOT_FOUND');
    }

    if (!isAdmin && reservation.userId != requestUserId) {
      throw Exception('FORBIDDEN');
    }

    if (!reservation.isActive) {
      throw Exception('RESERVATION_NOT_ACTIVE');
    }

    return _reservationRepository.cancelReservation(reservationId);
  }
}
