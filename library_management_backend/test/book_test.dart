import 'package:test/test.dart';
import '../lib/models/book.dart';
import '../lib/validation/validators.dart';

void main() {
  group('Book Model & Validation Unit Tests', () {
    test('Book model initializes properties and calculates availability', () {
      final now = DateTime.now();
      final availableBook = Book(
        id: 1,
        title: 'Clean Code',
        author: 'Robert C. Martin',
        category: 'Computer Science',
        isbn: '978-0132350884',
        quantity: 5,
        availableQuantity: 3,
        createdAt: now,
        updatedAt: now,
      );

      expect(availableBook.isAvailable, isTrue);

      final outOfStockBook = availableBook.copyWith(availableQuantity: 0);
      expect(outOfStockBook.isAvailable, isFalse);
    });

    test('Book validation enforces ISBN format, title and positive quantity', () {
      final invalid = Validators.validateBook(
        title: '',
        author: 'Author',
        category: 'Tech',
        isbn: '123-bad',
        quantity: 0,
      );

      expect(invalid.isValid, isFalse);
      expect(invalid.errors.containsKey('title'), isTrue);
      expect(invalid.errors.containsKey('isbn'), isTrue);
      expect(invalid.errors.containsKey('quantity'), isTrue);

      final valid = Validators.validateBook(
        title: 'Designing Data-Intensive Applications',
        author: 'Martin Kleppmann',
        category: 'Computer Science',
        isbn: '978-1449373320',
        quantity: 10,
      );

      expect(valid.isValid, isTrue);
    });
  });
}
