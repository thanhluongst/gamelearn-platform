import '../../../core/network/api_client.dart';

class TeacherRepository {
  final ApiClient _client;
  TeacherRepository(this._client);

  Future<List<dynamic>> getMyClasses() async {
    final response = await _client.get('/classes/teacher');
    return response.data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> createClass(Map<String, dynamic> data) async {
    final response = await _client.post('/classes', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getClassMembers(String classId) async {
    final response = await _client.get('/classes/$classId/members');
    return response.data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getClassAnalytics(String classId) async {
    final response = await _client.get('/statistics/class/$classId');
    return response.data as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> createGameSession(Map<String, dynamic> data) async {
    final response = await _client.post('/game-sessions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getGameSessions({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final response = await _client.get('/game-sessions$query');
    return (response.data['data'] as List<dynamic>?) ?? [];
  }

  Future<List<dynamic>> getQuestionBanks() async {
    final response = await _client.get('/question-banks');
    return response.data as List<dynamic>? ?? [];
  }
}
