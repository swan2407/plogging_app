import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../model/my_page_models.dart';

class MyPageApiService {
  MyPageApiService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<UserActivitySummary> fetchMyActivitySummary(String accessToken) async {
    try {
      final decoded = await _apiClient.get(
        '/api/users/me/statistics',
        accessToken: accessToken,
      );
      if (decoded is! Map<String, dynamic>) {
        throw const MyPageApiException('활동 통계 응답 형식이 올바르지 않습니다.');
      }
      return UserActivitySummary.fromJson(decoded);
    } on ApiException catch (exception) {
      throw MyPageApiException(exception.message);
    }
  }
}

class MyPageApiException implements Exception {
  const MyPageApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
