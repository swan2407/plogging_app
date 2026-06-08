import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiService {
  AuthApiService({http.Client? client, this.baseUrl = 'http://localhost:8080'})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

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
    final response = await _client.post(
      Uri.parse('$baseUrl/api/auth/refresh'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: utf8.encode(jsonEncode({'refreshToken': refreshToken})),
    );

    final decoded = _decodeResponse(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        response.statusCode == 401
            ? '로그인이 만료되었습니다. 다시 로그인해 주세요.'
            : decoded['message'] as String? ?? '요청 처리 중 오류가 발생했습니다.',
      );
    }

    return TokenRefreshResult.fromJson(decoded);
  }

  Future<AuthResult> _post(
    String path, {
    required Map<String, Object?> body,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: utf8.encode(jsonEncode(body)),
    );

    final decoded = _decodeResponse(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        response.statusCode == 401
            ? '로그인이 만료되었습니다. 다시 로그인해 주세요.'
            : decoded['message'] as String? ?? '요청 처리 중 오류가 발생했습니다.',
      );
    }

    return AuthResult.fromJson(decoded);
  }

  Map<String, dynamic> _decodeResponse(List<int> bodyBytes) {
    try {
      return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw const AuthApiException('서버 응답을 확인할 수 없습니다.');
    }
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
