import '../models/borrowing.dart';
import '../repositories/book_repository.dart';
import '../repositories/borrowing_repository.dart';

class BorrowingService {
  BorrowingService({
    BorrowingRepository? borrowingRepository,
    BookRepository? bookRepository,
  })  : _borrowingRepository = borrowingRepository ?? BorrowingRepository(),
        _bookRepository = bookRepository ?? BookRepository();

  final BorrowingRepository _borrowingRepository;
  final BookRepository _bookRepository;

  Future<List<Borrowing>> getMyBorrowings(int userId) async {
    return _borrowingRepository.getByUser(userId);
  }

  Future<List<Borrowing>> getAllBorrowings() async {
    return _borrowingRepository.getAll();
  }

  Future<Borrowing?> getBorrowingById(int id) async {
    return _borrowingRepository.findById(id);
  }

  Future<Borrowing> borrowBook({
    required int userId,
    required int bookId,
    int loanDurationDays = 14,
  }) async {
    // 1. Verify book exists
    final book = await _bookRepository.findById(bookId);
    if (book == null) {
      throw Exception('BOOK_NOT_FOUND');
    }

    // 2. Verify availability
    if (book.availableQuantity <= 0) {
      throw Exception('BOOK_UNAVAILABLE');
    }

    // 3. Verify no active duplicate borrowing
    final activeBorrowing = await _borrowingRepository.findActiveByUserAndBook(userId, bookId);
    if (activeBorrowing != null) {
      throw Exception('DUPLICATE_ACTIVE_BORROWING');
    }

    // 4. Perform transaction
    return _borrowingRepository.createBorrowing(
      userId: userId,
      bookId: bookId,
      loanDurationDays: loanDurationDays,
    );
  }

  Future<bool> returnBook({
    required int borrowingId,
    required int requestUserId,
    required bool isAdmin,
  }) async {
    // 1. Verify borrowing exists
    final borrowing = await _borrowingRepository.findById(borrowingId);
    if (borrowing == null) {
      throw Exception('BORROWING_NOT_FOUND');
    }

    // 2. Verify ownership unless admin
    if (!isAdmin && borrowing.userId != requestUserId) {
      throw Exception('FORBIDDEN');
    }

    // 3. Verify not already returned
    if (borrowing.isReturned) {
      throw Exception('ALREADY_RETURNED');
    }

    return _borrowingRepository.returnBook(borrowingId);
  }
}
