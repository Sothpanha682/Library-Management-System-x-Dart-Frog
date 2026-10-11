import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';

Handler corsMiddleware(Handler handler) {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization, Accept, X-Requested-With',
  };

  return (context) async {
    if (context.request.method == HttpMethod.options) {
      return Response(
        statusCode: 204,
        headers: corsHeaders,
      );
    }

    try {
      final response = await handler(context);
      return response.copyWith(
        headers: {
          ...response.headers,
          ...corsHeaders,
        },
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('Unhandled backend server error: $e\n$st');
      return Response(
        statusCode: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'success': false,
          'message': 'Server error: $e',
          'error': {'code': 'INTERNAL_SERVER_ERROR'},
        }),
      );
    }
  };
}
