import 'package:test/test.dart';
import '../lib/models/borrowing.dart';

void main() {
  group('Borrowing Business Rules Unit Tests', () {
    test('Borrowing detects overdue status accurately', () {
      final now = DateTime.now();

      final activeBorrowing = Borrowing(
        id: 1,
        userId: 2,
        bookId: 5,
        borrowedAt: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 9)),
        status: 'borrowed',
        createdAt: now,
        updatedAt: now,
      );

      expect(activeBorrowing.isReturned, isFalse);
      expect(activeBorrowing.isOverdue, isFalse);

      final overdueBorrowing = Borrowing(
        id: 2,
        userId: 2,
        bookId: 6,
        borrowedAt: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 6)),
        status: 'borrowed',
        createdAt: now,
        updatedAt: now,
      );

      expect(overdueBorrowing.isOverdue, isTrue);

      final returnedBorrowing = Borrowing(
        id: 3,
        userId: 2,
        bookId: 6,
        borrowedAt: now.subtract(const Duration(days: 20)),
        dueDate: now.subtract(const Duration(days: 6)),
        returnedAt: now.subtract(const Duration(days: 7)),
        status: 'returned',
        createdAt: now,
        updatedAt: now,
      );

      expect(returnedBorrowing.isReturned, isTrue);
      expect(returnedBorrowing.isOverdue, isFalse);
    });
  });
}
