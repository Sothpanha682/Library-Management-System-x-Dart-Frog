import 'package:dart_frog/dart_frog.dart';
import '../lib/models/api_response.dart';

Response onRequest(RequestContext context) {
  return ApiResponse.success(
    message: 'Welcome to University Library Management System REST API',
    data: {
      'name': 'Library Management API',
      'version': '1.0.0',
      'docs': '/api/docs',
      'endpoints': {
        'auth': '/api/auth',
        'books': '/api/books',
        'borrowings': '/api/borrowings',
        'reservations': '/api/reservations',
        'admin': '/api/admin',
      },
    },
  );
}
