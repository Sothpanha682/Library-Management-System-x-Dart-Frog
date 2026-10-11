import 'package:dart_frog/dart_frog.dart';
import 'package:library_management_backend/middleware/cors_middleware.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(corsMiddleware);
}
