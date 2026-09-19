import '../models/user.dart';

class AuthContext {
  const AuthContext({
    required this.user,
    required this.token,
  });

  final User user;
  final String token;

  bool get isAdmin => user.isAdmin;
  bool get isStudent => user.isStudent;
}
