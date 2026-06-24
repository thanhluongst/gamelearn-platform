import '../../../core/network/api_client.dart';

class StudentRepository {
  final ApiClient _client;
  StudentRepository(this._client);

  Future<Map<String, dynamic>> getMyStats() async {
    final response = await _client.get('/statistics/me');
    return response.data as Map<String, dynamic>? ?? {};
  }

  Future<List<dynamic>> getMyMissions() async {
    final response = await _client.get('/missions');
    return response.data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> claimMission(String missionId) async {
    final response = await _client.post('/missions/$missionId/claim');
    return response.data as Map<String, dynamic>? ?? {};
  }

  Future<List<dynamic>> getChartData(String period) async {
    final response = await _client.get('/statistics/me/chart?period=$period');
    return response.data as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getMyAchievements() async {
    final response = await _client.get('/achievements/me');
    return response.data as Map<String, dynamic>? ?? {};
  }
}
