import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/book.dart';

class BookService {
  Future<List<Book>> getBooks({String? category}) async {
    String url = ApiEndpoints.books;
    if (category != null && category != 'All') {
      url += '?category=${Uri.encodeComponent(category)}';
    }

    final response = await ApiClient.get(url, requireAuth: false);
    final list = response['data'] as List<dynamic>;
    return list.map((b) => Book.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final response = await ApiClient.get(
      ApiEndpoints.searchBooks(query),
      requireAuth: false,
    );
    final list = response['data'] as List<dynamic>;
    return list.map((b) => Book.fromJson(b as Map<String, dynamic>)).toList();
  }

  Future<Book> getBookDetails(int id) async {
    final response = await ApiClient.get(
      ApiEndpoints.bookDetails(id),
      requireAuth: false,
    );
    return Book.fromJson(response['data'] as Map<String, dynamic>);
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
    final response = await ApiClient.post(
      ApiEndpoints.adminBooks,
      body: {
        'title': title,
        'author': author,
        'category': category,
        'isbn': isbn,
        'description': description,
        'cover_image': coverImage,
        'quantity': quantity,
      },
    );
    return Book.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Book> updateBook({
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
    final response = await ApiClient.put(
      ApiEndpoints.adminBookDetails(id),
      body: {
        'title': title,
        'author': author,
        'category': category,
        'isbn': isbn,
        'description': description,
        'cover_image': coverImage,
        'quantity': quantity,
        'available_quantity': availableQuantity,
      },
    );
    return Book.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteBook(int id) async {
    await ApiClient.delete(ApiEndpoints.adminBookDetails(id));
  }
}
