import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _api;
  final _storage = const FlutterSecureStorage();

  AuthRepository(this._api);

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _api.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    final data = response.data['data'] as Map<String, dynamic>;
    await _storage.write(key: 'access_token', value: data['accessToken'] as String);
    await _storage.write(key: 'refresh_token', value: data['refreshToken'] as String);
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> dto) async {
    final response = await _api.post('/auth/register', data: dto);
    final data = response.data['data'] as Map<String, dynamic>;
    await _storage.write(key: 'access_token', value: data['accessToken'] as String);
    await _storage.write(key: 'refresh_token', value: data['refreshToken'] as String);
    return data;
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    try {
      final response = await _api.get('/auth/me');
      return response.data['data'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _storage.deleteAll();
  }
}
