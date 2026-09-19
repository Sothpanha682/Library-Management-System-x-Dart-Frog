import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/borrowing.dart';

class BorrowingService {
  Future<List<Borrowing>> getMyBorrowings() async {
    final response = await ApiClient.get(ApiEndpoints.borrowings);
    final list = response['data'] as List<dynamic>;
    return list.map((b) => Borrowing.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<List<Borrowing>> getAllBorrowings() async {
    final response = await ApiClient.get(ApiEndpoints.adminBorrowings);
    final list = response['data'] as List<dynamic>;
    return list.map((b) => Borrowing.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<Borrowing> getBorrowingDetails(int id) async {
    final response = await ApiClient.get(ApiEndpoints.borrowingDetails(id));
    return Borrowing.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Borrowing> borrowBook(int bookId) async {
    final response = await ApiClient.post(
      ApiEndpoints.borrowings,
      body: {'book_id': bookId},
    );
    return Borrowing.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Borrowing> returnBook(int borrowingId) async {
    final response = await ApiClient.put(ApiEndpoints.returnBook(borrowingId));
    return Borrowing.fromJson(response['data'] as Map<String, dynamic>);
  }
}
