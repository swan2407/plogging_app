import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/plogging_session.dart';

class PloggingApiService {
  PloggingApiService({
    http.Client? client,
    this.baseUrl = 'http://localhost:8080',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<PloggingSession> saveCompletedPloggingSession(
    SaveCompletedPloggingRequest request,
    String accessToken,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/plogging/sessions/completed'),
      headers: _authorizedHeaders(accessToken),
      body: utf8.encode(jsonEncode(request.toJson())),
    );
    return PloggingSession.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<PloggingSession>> fetchMyPloggingSessions(
    String accessToken,
  ) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/plogging/sessions/me'),
      headers: _authorizedHeaders(accessToken),
    );
    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => PloggingSession.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Map<String, String> _authorizedHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  dynamic _decode(http.Response response) {
    final decoded = response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      throw PloggingApiException(message ?? '활동 기록 저장에 실패했습니다.');
    }
    return decoded;
  }
}

class SaveCompletedPloggingRequest {
  const SaveCompletedPloggingRequest({
    required this.startAt,
    required this.endAt,
    required this.durationSeconds,
    required this.distanceMeter,
    required this.regionSido,
    required this.regionSigungu,
    required this.trashCertificationCount,
    required this.trashRecords,
  });

  final DateTime startAt;
  final DateTime endAt;
  final int durationSeconds;
  final int distanceMeter;
  final String? regionSido;
  final String? regionSigungu;
  final int trashCertificationCount;
  final List<TrashRecordRequest> trashRecords;

  Map<String, Object?> toJson() {
    return {
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'distanceMeter': distanceMeter,
      'regionSido': regionSido,
      'regionSigungu': regionSigungu,
      'trashCertificationCount': trashCertificationCount,
      'trashRecords': trashRecords.map((record) => record.toJson()).toList(),
    };
  }
}

class TrashRecordRequest {
  const TrashRecordRequest({
    required this.imageUrl,
    required this.lat,
    required this.lng,
    this.trashType,
    this.count,
    this.weightGram,
    this.memo,
  });

  final String imageUrl;
  final double lat;
  final double lng;
  final String? trashType;
  final int? count;
  final int? weightGram;
  final String? memo;

  Map<String, Object?> toJson() {
    return {
      'imageUrl': imageUrl,
      'lat': lat,
      'lng': lng,
      'trashType': trashType,
      'count': count,
      'weightGram': weightGram,
      'memo': memo,
    };
  }
}

class PloggingApiException implements Exception {
  const PloggingApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
