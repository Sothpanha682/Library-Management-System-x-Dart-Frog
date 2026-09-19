import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_frontend/models/book.dart';
import 'package:library_management_frontend/models/borrowing.dart';
import 'package:library_management_frontend/models/reservation.dart';
import 'package:library_management_frontend/models/user.dart';

void main() {
  group('Frontend Models Test Suite', () {
    test('User model parses json and identifies roles correctly', () {
      final userJson = {
        'id': 1,
        'name': 'Administrator',
        'email': 'admin@library.edu',
        'role': 'admin',
        'created_at': '2026-01-01T00:00:00Z',
      };

      final user = User.fromJson(userJson);
      expect(user.id, equals(1));
      expect(user.isAdmin, isTrue);
      expect(user.isStudent, isFalse);

      final student = User.fromJson({
        'id': 2,
        'name': 'Student',
        'email': 'student@library.edu',
        'role': 'student',
      });
      expect(student.isAdmin, isFalse);
      expect(student.isStudent, isTrue);
    });

    test('Book model calculates availability correctly', () {
      final availableBook = Book.fromJson({
        'id': 10,
        'title': 'Introduction to Algorithms',
        'author': 'Cormen',
        'category': 'Computer Science',
        'isbn': '978-0262033848',
        'quantity': 5,
        'available_quantity': 2,
      });

      expect(availableBook.isAvailable, isTrue);

      final unavailableBook = Book.fromJson({
        'id': 11,
        'title': 'Operating System Concepts',
        'author': 'Silberschatz',
        'category': 'Computer Science',
        'isbn': '978-1118063330',
        'quantity': 3,
        'available_quantity': 0,
      });

      expect(unavailableBook.isAvailable, isFalse);
    });

    test('Borrowing model flags overdue loans properly', () {
      final now = DateTime.now();

      final activeLoan = Borrowing(
        id: 1,
        userId: 2,
        bookId: 10,
        borrowedAt: now.subtract(const Duration(days: 3)),
        dueDate: now.add(const Duration(days: 11)),
        status: 'borrowed',
      );
      expect(activeLoan.isOverdue, isFalse);
      expect(activeLoan.isReturned, isFalse);

      final overdueLoan = Borrowing(
        id: 2,
        userId: 2,
        bookId: 10,
        borrowedAt: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 6)),
        status: 'borrowed',
      );
      expect(overdueLoan.isOverdue, isTrue);
      expect(overdueLoan.isReturned, isFalse);
    });

    test('Reservation model tracks active and expiration status', () {
      final now = DateTime.now();

      final activeReservation = Reservation(
        id: 1,
        userId: 2,
        bookId: 11,
        reservedAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 6)),
        status: 'pending',
      );
      expect(activeReservation.isActive, isTrue);
      expect(activeReservation.isExpired, isFalse);
    });
  });
}
