import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Configurable base URL:
  // Android Emulator uses 10.0.2.2 to reach host machine
  // iOS Simulator / Desktop / Web uses localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8081';
    } catch (_) {}
    return 'http://localhost:8081';
  }

  // Auth
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
  static String get me => '$baseUrl/api/auth/me';

  // Books
  static String get books => '$baseUrl/api/books';
  static String bookDetails(int id) => '$baseUrl/api/books/$id';
  static String searchBooks(String query) => '$baseUrl/api/books/search?q=${Uri.encodeComponent(query)}';

  // Borrowings
  static String get borrowings => '$baseUrl/api/borrowings';
  static String borrowingDetails(int id) => '$baseUrl/api/borrowings/$id';
  static String returnBook(int id) => '$baseUrl/api/borrowings/$id/return';

  // Reservations
  static String get reservations => '$baseUrl/api/reservations';
  static String reservationDetails(int id) => '$baseUrl/api/reservations/$id';

  // Admin
  static String get adminBooks => '$baseUrl/api/admin/books';
  static String adminBookDetails(int id) => '$baseUrl/api/admin/books/$id';
  static String get adminUsers => '$baseUrl/api/admin/users';
  static String get adminBorrowings => '$baseUrl/api/admin/borrowings';
  static String get adminReservations => '$baseUrl/api/admin/reservations';
}
