import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookService {
  BookService({BookRepository? bookRepository})
      : _bookRepository = bookRepository ?? BookRepository();

  final BookRepository _bookRepository;

  Future<List<Book>> getAllBooks({String? category, int page = 1, int limit = 50}) async {
    return _bookRepository.getAll(category: category, page: page, limit: limit);
  }

  Future<int> getTotalCount({String? category}) async {
    return _bookRepository.count(category: category);
  }

  Future<List<Book>> searchBooks(String keyword) async {
    if (keyword.trim().isEmpty) {
      return getAllBooks();
    }
    return _bookRepository.search(keyword);
  }

  Future<Book?> getBookById(int id) async {
    return _bookRepository.findById(id);
  }

  Future<Book> createBook({
    required String title,
    required String author,
    required String category,
    required String isbn,
    String? description,
    String? coverImage,
    required int quantity,
  }) async {
    final existing = await _bookRepository.findByIsbn(isbn);
    if (existing != null) {
      throw Exception('ISBN_ALREADY_EXISTS');
    }

    return _bookRepository.create(
      title: title,
      author: author,
      category: category,
      isbn: isbn,
      description: description,
      coverImage: coverImage,
      quantity: quantity,
    );
  }

  Future<Book> updateBook(int id, {
    required String title,
    required String author,
    required String category,
    required String isbn,
    String? description,
    String? coverImage,
    required int quantity,
    required int availableQuantity,
  }) async {
    final existing = await _bookRepository.findById(id);
    if (existing == null) {
      throw Exception('BOOK_NOT_FOUND');
    }

    final updated = existing.copyWith(
      title: title,
      author: author,
      category: category,
      isbn: isbn,
      description: description,
      coverImage: coverImage,
      quantity: quantity,
      availableQuantity: availableQuantity,
      updatedAt: DateTime.now(),
    );

    final success = await _bookRepository.update(updated);
    if (!success) {
      throw Exception('UPDATE_FAILED');
    }

    return updated;
  }

  Future<bool> deleteBook(int id) async {
    final existing = await _bookRepository.findById(id);
    if (existing == null) {
      throw Exception('BOOK_NOT_FOUND');
    }
    return _bookRepository.delete(id);
  }
}
