import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthService {
  Future<User> login(String email, String password) async {
    final response = await ApiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      requireAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    await TokenStorage.saveAuth(token: token, user: user);
    return user;
  }

  Future<User> register(String name, String email, String password) async {
    final response = await ApiClient.post(
      ApiEndpoints.register,
      body: {'name': name, 'email': email, 'password': password},
      requireAuth: false,
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    await TokenStorage.saveAuth(token: token, user: user);
    return user;
  }

  Future<User?> getMe() async {
    final response = await ApiClient.get(ApiEndpoints.me);
    final data = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(data);

    final token = await TokenStorage.getToken();
    if (token != null) {
      await TokenStorage.saveAuth(token: token, user: user);
    }
    return user;
  }

  Future<User> updateProfile(String name) async {
    final response = await ApiClient.put(
      ApiEndpoints.me,
      body: {'name': name},
    );

    final data = response['data'] as Map<String, dynamic>;
    final user = User.fromJson(data);

    final token = await TokenStorage.getToken();
    if (token != null) {
      await TokenStorage.saveAuth(token: token, user: user);
    }
    return user;
  }

  Future<void> logout() async {
    await TokenStorage.clear();
  }

  Future<List<User>> getAllUsers() async {
    final response = await ApiClient.get(ApiEndpoints.adminUsers);
    final list = response['data'] as List<dynamic>;
    return list.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
  }
}
