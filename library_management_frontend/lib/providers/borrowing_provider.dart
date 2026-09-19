import 'package:flutter/material.dart';
import '../models/borrowing.dart';
import '../services/borrowing_service.dart';

class BorrowingProvider extends ChangeNotifier {
  BorrowingProvider({BorrowingService? borrowingService})
      : _borrowingService = borrowingService ?? BorrowingService();

  final BorrowingService _borrowingService;

  List<Borrowing> _borrowings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Borrowing> get borrowings => _borrowings;
  List<Borrowing> get activeBorrowings =>
      _borrowings.where((b) => !b.isReturned).toList();
  List<Borrowing> get historyBorrowings =>
      _borrowings.where((b) => b.isReturned).toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyBorrowings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _borrowings = await _borrowingService.getMyBorrowings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> borrowBook(int bookId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _borrowingService.borrowBook(bookId);
      await fetchMyBorrowings();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> returnBook(int borrowingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _borrowingService.returnBook(borrowingId);
      await fetchMyBorrowings();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
