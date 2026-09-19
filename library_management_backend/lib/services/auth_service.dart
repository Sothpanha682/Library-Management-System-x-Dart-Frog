import '../auth/jwt_service.dart';
import '../auth/password_hasher.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthResult {
  const AuthResult({
    required this.user,
    required this.token,
  });

  final User user;
  final String token;
}

class AuthService {
  AuthService({UserRepository? userRepository})
      : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    final existing = await _userRepository.findByEmail(email);
    if (existing != null) {
      throw Exception('EMAIL_ALREADY_EXISTS');
    }

    final user = await _userRepository.create(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    final token = JwtService.generateToken(user);
    return AuthResult(user: user, token: token);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final user = await _userRepository.findByEmail(email);
    if (user == null) {
      throw Exception('INVALID_CREDENTIALS');
    }

    final isValid = PasswordHasher.verify(password, user.passwordHash);
    if (!isValid) {
      throw Exception('INVALID_CREDENTIALS');
    }

    final token = JwtService.generateToken(user);
    return AuthResult(user: user, token: token);
  }

  Future<User?> getMe(int userId) async {
    return _userRepository.findById(userId);
  }

  Future<List<User>> getAllUsers() async {
    return _userRepository.getAll();
  }

  Future<bool> updateProfile(int userId, {required String name}) async {
    return _userRepository.updateProfile(userId, name: name);
  }
}
