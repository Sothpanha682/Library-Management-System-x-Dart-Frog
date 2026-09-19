import 'package:dart_frog/dart_frog.dart';
import 'package:library_management_backend/middleware/auth_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(authRequiredMiddleware());
}
