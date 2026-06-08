import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/my_page_models.dart';

class MyPageApiService {
  MyPageApiService({
    http.Client? client,
    this.baseUrl = 'http://localhost:8080',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<UserActivitySummary> fetchMyActivitySummary(String accessToken) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/users/me/statistics'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final decoded = response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      throw MyPageApiException(message ?? '활동 통계를 불러오지 못했습니다.');
    }

    return UserActivitySummary.fromJson(decoded as Map<String, dynamic>);
  }
}

class MyPageApiException implements Exception {
  const MyPageApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
