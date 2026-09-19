import 'package:test/test.dart';
import '../lib/models/reservation.dart';

void main() {
  group('Reservation Rules Unit Tests', () {
    test('Reservation calculates active state and expiration', () {
      final now = DateTime.now();

      final pendingReservation = Reservation(
        id: 1,
        userId: 3,
        bookId: 10,
        reservedAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.add(const Duration(days: 5)),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      expect(pendingReservation.isActive, isTrue);
      expect(pendingReservation.isExpired, isFalse);

      final expiredReservation = Reservation(
        id: 2,
        userId: 3,
        bookId: 10,
        reservedAt: now.subtract(const Duration(days: 10)),
        expiresAt: now.subtract(const Duration(days: 3)),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      );

      expect(expiredReservation.isExpired, isTrue);

      final cancelledReservation = Reservation(
        id: 3,
        userId: 3,
        bookId: 10,
        reservedAt: now.subtract(const Duration(days: 10)),
        expiresAt: now.subtract(const Duration(days: 3)),
        status: 'cancelled',
        createdAt: now,
        updatedAt: now,
      );

      expect(cancelledReservation.isActive, isFalse);
      expect(cancelledReservation.isExpired, isFalse);
    });
  });
}
