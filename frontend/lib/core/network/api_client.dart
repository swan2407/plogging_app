import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const apiBaseUrl = 'http://localhost:8080';

class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<dynamic> get(String path, {String? accessToken}) {
    return _send(
      () => _client.get(_uri(path), headers: headers(accessToken: accessToken)),
      path,
    );
  }

  Future<dynamic> getWithQuery(
    String path, {
    Map<String, String>? queryParameters,
    String? accessToken,
  }) {
    return _send(
      () => _client.get(
        _uri(path, queryParameters: queryParameters),
        headers: headers(accessToken: accessToken),
      ),
      path,
    );
  }

  Future<dynamic> post(String path, {Object? body, String? accessToken}) {
    return _send(
      () => _client.post(
        _uri(path),
        headers: headers(accessToken: accessToken),
        body: body == null ? null : utf8.encode(jsonEncode(body)),
      ),
      path,
    );
  }

  Future<dynamic> delete(String path, {String? accessToken}) {
    return _send(
      () => _client.delete(
        _uri(path),
        headers: headers(accessToken: accessToken),
      ),
      path,
    );
  }

  Future<dynamic> uploadMultipart(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    required String contentType,
    required String accessToken,
  }) {
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            bytes,
            filename: filename,
            contentType: MediaType.parse(contentType),
          ),
        );
      return http.Response.fromStream(await _client.send(request));
    }, path);
  }

  Map<String, String> headers({String? accessToken}) {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
    };
  }

  Uri _uri(String path, {Map<String, String>? queryParameters}) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters: queryParameters?.isEmpty == true
          ? null
          : queryParameters,
    );
  }

  Future<dynamic> _send(
    Future<http.Response> Function() request,
    String path,
  ) async {
    late http.Response response;
    try {
      response = await request();
    } catch (error, stackTrace) {
      debugPrint('API request failed [$path]: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw const ApiException('서버에 연결할 수 없습니다.');
    }

    dynamic decoded;
    if (response.bodyBytes.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (error, stackTrace) {
        debugPrint('API response parsing failed [$path]: $error');
        debugPrintStack(stackTrace: stackTrace);
        throw ApiException(
          '서버 응답을 확인할 수 없습니다.',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final backendMessage = decoded is Map<String, dynamic>
          ? decoded['message']?.toString().trim()
          : null;
      debugPrint(
        'API error [$path] ${response.statusCode}: '
        '${backendMessage?.isNotEmpty == true ? backendMessage : decoded}',
      );
      throw ApiException(
        _friendlyErrorMessage(response.statusCode, backendMessage),
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  String _friendlyErrorMessage(int statusCode, String? backendMessage) {
    return switch (statusCode) {
      400 =>
        backendMessage?.isNotEmpty == true
            ? backendMessage!
            : '입력 내용을 확인해 주세요.',
      401 => '로그인이 만료되었습니다. 다시 로그인해 주세요.',
      403 => '요청을 처리할 권한이 없습니다.',
      404 =>
        backendMessage?.isNotEmpty == true
            ? backendMessage!
            : '요청한 정보를 찾을 수 없습니다.',
      409 =>
        backendMessage?.isNotEmpty == true ? backendMessage! : '이미 처리된 요청입니다.',
      _ =>
        backendMessage?.isNotEmpty == true
            ? backendMessage!
            : '요청 처리 중 오류가 발생했습니다.',
    };
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
