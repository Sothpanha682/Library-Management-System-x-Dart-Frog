import 'package:test/test.dart';
import '../lib/database/db_connection.dart';
import '../lib/repositories/book_repository.dart';
import '../lib/repositories/user_repository.dart';
import '../lib/repositories/borrowing_repository.dart';
import '../lib/repositories/reservation_repository.dart';

void main() {
  group('MongoDB Live Integration Tests', () {
    tearDownAll(() async {
      await DbConnection.close();
    });

    test('Connected to MongoDB and can query seeded users', () async {
      final userRepo = UserRepository();
      final users = await userRepo.getAll();
      expect(users.length, greaterThanOrEqualTo(4));

      final admin = await userRepo.findByEmail('admin@library.edu');
      expect(admin, isNotNull);
      expect(admin!.role, equals('admin'));
    });

    test('Can query seeded books and search', () async {
      final bookRepo = BookRepository();
      final books = await bookRepo.getAll();
      expect(books.length, equals(16));

      final searchResults = await bookRepo.search('Clean Code');
      expect(searchResults.isNotEmpty, isTrue);
      expect(searchResults.first.title, contains('Clean Code'));

      final csCount = await bookRepo.count(category: 'Computer Science');
      expect(csCount, greaterThan(0));
    });

    test('Can query borrowings with populated user and book data', () async {
      final borrowingRepo = BorrowingRepository();
      final borrowings = await borrowingRepo.getAll();
      expect(borrowings.isNotEmpty, isTrue);

      final first = borrowings.first;
      expect(first.bookTitle, isNotNull);
      expect(first.userName, isNotNull);
    });

    test('Can query reservations with populated user and book data', () async {
      final reservationRepo = ReservationRepository();
      final reservations = await reservationRepo.getAll();
      expect(reservations.isNotEmpty, isTrue);

      final first = reservations.first;
      expect(first.bookTitle, isNotNull);
      expect(first.userName, isNotNull);
    });
  });
}
