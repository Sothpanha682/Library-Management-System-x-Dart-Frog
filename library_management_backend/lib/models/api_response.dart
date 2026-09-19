import 'package:dart_frog/dart_frog.dart';

/// Standard response wrapper complying with requirement 9.
class ApiResponse {
  static Response success({
    String message = 'Success',
    dynamic data,
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data ?? {},
      },
    );
  }

  static Response list({
    String message = 'Success',
    required List<dynamic> data,
    int page = 1,
    int limit = 20,
    required int total,
    int statusCode = 200,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'message': message,
        'data': data,
        'meta': {
          'page': page,
          'limit': limit,
          'total': total,
        },
      },
    );
  }

  static Response error({
    required String message,
    String code = 'ERROR',
    int statusCode = 400,
    dynamic details,
  }) {
    final body = <String, dynamic>{
      'success': false,
      'message': message,
      'error': {
        'code': code,
        if (details != null) 'details': details,
      },
    };

    return Response.json(
      statusCode: statusCode,
      body: body,
    );
  }
}
