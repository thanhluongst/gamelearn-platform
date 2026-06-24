import '../../../core/network/api_client.dart';

class GameRepository {
  final ApiClient _api;
  GameRepository(this._api);

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> dto) async {
    final response = await _api.post('/game-sessions', data: dto);
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSession(String sessionId) async {
    final response = await _api.get('/game-sessions/$sessionId');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSessionResults(String sessionId) async {
    final response = await _api.get('/game-sessions/$sessionId/results');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMySessions() async {
    final response = await _api.get('/game-sessions');
    return response.data['data'] as List<dynamic>;
  }
}
