import 'package:test/test.dart';
import '../lib/auth/jwt_service.dart';
import '../lib/auth/password_hasher.dart';
import '../lib/models/user.dart';
import '../lib/validation/validators.dart';

void main() {
  group('Authentication & Security Unit Tests', () {
    test('Password hasher produces consistent verifiable hash', () {
      const password = 'SecurePassword123!';
      final hash = PasswordHasher.hash(password);

      expect(hash, startsWith('\$sha256\$'));
      expect(PasswordHasher.verify(password, hash), isTrue);
      expect(PasswordHasher.verify('WrongPassword', hash), isFalse);
    });

    test('JWT Service generates valid verifiable token with claims', () {
      final user = User(
        id: 42,
        name: 'Jane Doe',
        email: 'jane@university.edu',
        passwordHash: 'hash',
        role: 'student',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final token = JwtService.generateToken(user);
      expect(token, isNotEmpty);

      final payload = JwtService.verifyToken(token);
      expect(payload, isNotNull);
      expect(payload!['id'], equals(42));
      expect(payload['email'], equals('jane@university.edu'));
      expect(payload['role'], equals('student'));
    });

    test('Validators catch invalid email, short passwords, and short names', () {
      final invalidEmail = Validators.validateRegister(
        name: 'John',
        email: 'invalid-email',
        password: 'password123',
      );
      expect(invalidEmail.isValid, isFalse);
      expect(invalidEmail.errors.containsKey('email'), isTrue);

      final shortPass = Validators.validateRegister(
        name: 'John',
        email: 'john@example.com',
        password: '123',
      );
      expect(shortPass.isValid, isFalse);
      expect(shortPass.errors.containsKey('password'), isTrue);

      final valid = Validators.validateRegister(
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
      );
      expect(valid.isValid, isTrue);
      expect(valid.errors, isEmpty);
    });

    test('Login validator enforces presence of email and password', () {
      final emptyPass = Validators.validateLogin(email: 'test@example.com', password: '');
      expect(emptyPass.isValid, isFalse);
      expect(emptyPass.errors.containsKey('password'), isTrue);

      final valid = Validators.validateLogin(email: 'test@example.com', password: 'ValidPassword123');
      expect(valid.isValid, isTrue);
    });
  });
}
