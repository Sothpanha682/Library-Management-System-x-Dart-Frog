import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookProvider extends ChangeNotifier {
  BookProvider({BookService? bookService})
      : _bookService = bookService ?? BookService();

  final BookService _bookService;

  List<Book> _books = [];
  List<Book> _searchResults = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  List<Book> get books => _books;
  List<Book> get searchResults => _searchResults;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBooks({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    if (category != null) _selectedCategory = category;
    notifyListeners();

    try {
      _books = await _bookService.getBooks(category: _selectedCategory);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _bookService.searchBooks(query);
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<Book?> getBookById(int id) async {
    try {
      return await _bookService.getBookDetails(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createBook({
    required String title,
    required String author,
    required String category,
    required String isbn,
    String? description,
    String? coverImage,
    required int quantity,
  }) async {
    try {
      await _bookService.createBook(
        title: title,
        author: author,
        category: category,
        isbn: isbn,
        description: description,
        coverImage: coverImage,
        quantity: quantity,
      );
      await fetchBooks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook({
    required int id,
    required String title,
    required String author,
    required String category,
    required String isbn,
    String? description,
    String? coverImage,
    required int quantity,
    required int availableQuantity,
  }) async {
    try {
      await _bookService.updateBook(
        id: id,
        title: title,
        author: author,
        category: category,
        isbn: isbn,
        description: description,
        coverImage: coverImage,
        quantity: quantity,
        availableQuantity: availableQuantity,
      );
      await fetchBooks();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      await _bookService.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
