import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../model/plogging_session.dart';

class PloggingApiService {
  PloggingApiService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<PloggingSession> saveCompletedPloggingSession(
    SaveCompletedPloggingRequest request,
    String accessToken,
  ) async {
    try {
      final decoded = await _apiClient.post(
        '/api/plogging/sessions/completed',
        body: request.toJson(),
        accessToken: accessToken,
      );
      return PloggingSession.fromJson(_requireMap(decoded));
    } on ApiException catch (exception) {
      throw PloggingApiException(exception.message);
    }
  }

  Future<List<PloggingSession>> fetchMyPloggingSessions(
    String accessToken,
  ) async {
    try {
      final decoded = await _apiClient.get(
        '/api/plogging/sessions/me',
        accessToken: accessToken,
      );
      if (decoded is! List<dynamic>) {
        throw const PloggingApiException('플로깅 기록 응답 형식이 올바르지 않습니다.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PloggingSession.fromJson)
          .toList();
    } on ApiException catch (exception) {
      throw PloggingApiException(exception.message);
    }
  }

  Map<String, dynamic> _requireMap(dynamic decoded) {
    if (decoded is! Map<String, dynamic>) {
      throw const PloggingApiException('플로깅 기록 응답 형식이 올바르지 않습니다.');
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
