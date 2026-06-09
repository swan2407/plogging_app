import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';

class AuthApiService {
  AuthApiService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<AuthResult> login({
    required String loginId,
    required String password,
  }) {
    return _post(
      '/api/auth/login',
      body: {'loginId': loginId, 'password': password},
    );
  }

  Future<AuthResult> signup({
    required String loginId,
    required String password,
    required String nickname,
    String? regionSido,
    String? regionSigungu,
    required List<Map<String, Object>> agreements,
  }) {
    return _post(
      '/api/auth/signup',
      body: {
        'loginId': loginId,
        'password': password,
        'nickname': nickname,
        'regionSido': regionSido,
        'regionSigungu': regionSigungu,
        'agreements': agreements,
      },
    );
  }

  Future<TokenRefreshResult> refresh(String refreshToken) async {
    try {
      final decoded = await _apiClient.post(
        '/api/auth/refresh',
        body: {'refreshToken': refreshToken},
      );
      return TokenRefreshResult.fromJson(_requireMap(decoded));
    } on ApiException catch (exception) {
      throw AuthApiException(exception.message);
    }
  }

  Future<AuthResult> _post(
    String path, {
    required Map<String, Object?> body,
  }) async {
    try {
      final decoded = await _apiClient.post(path, body: body);
      return AuthResult.fromJson(_requireMap(decoded));
    } on ApiException catch (exception) {
      throw AuthApiException(exception.message);
    }
  }

  Map<String, dynamic> _requireMap(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const AuthApiException('서버 응답을 확인할 수 없습니다.');
    }
    return decoded;
  }
}

class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.nickname,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
    );
  }

  final String accessToken;
  final String refreshToken;
  final int userId;
  final String nickname;
}

class TokenRefreshResult {
  const TokenRefreshResult({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenRefreshResult.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResult(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  final String accessToken;
  final String refreshToken;
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
