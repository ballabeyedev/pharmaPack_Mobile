import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  final FlutterSecureStorage secureStorage;

  TokenService({required this.secureStorage});

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() {
    return secureStorage.read(key: 'jwt_token');
  }

  Future<void> setToken(String? token) async {
    if (token == null || token.isEmpty) {
      await secureStorage.delete(key: 'jwt_token');
    } else {
      await secureStorage.write(key: 'jwt_token', value: token);
    }
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: 'jwt_token');
  }
}