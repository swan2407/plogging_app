import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../model/group_event.dart';

class GroupEventApiService {
  GroupEventApiService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<List<GroupEvent>> fetchGroupEvents() async {
    try {
      final decoded = await _apiClient.get('/api/group-events');
      if (decoded is! List<dynamic>) {
        throw const GroupEventApiException('단체 플로깅 응답 형식이 올바르지 않습니다.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(GroupEvent.fromJson)
          .toList();
    } on ApiException catch (exception) {
      throw GroupEventApiException(exception.message);
    }
  }

  Future<GroupEvent> fetchGroupEventDetail(int eventId) async {
    return _requestEvent('/api/group-events/$eventId');
  }

  Future<GroupEvent> createGroupEvent(
    CreateGroupEventRequest request,
    String accessToken,
  ) async {
    return _requestEvent(
      '/api/group-events',
      usePost: true,
      body: request.toJson(),
      accessToken: accessToken,
    );
  }

  Future<GroupEvent> joinGroupEvent(int eventId, String accessToken) async {
    return _requestEvent(
      '/api/group-events/$eventId/join',
      usePost: true,
      accessToken: accessToken,
    );
  }

  Future<GroupEvent> _requestEvent(
    String path, {
    bool usePost = false,
    Object? body,
    String? accessToken,
  }) async {
    try {
      final decoded = usePost
          ? await _apiClient.post(path, body: body, accessToken: accessToken)
          : await _apiClient.get(path, accessToken: accessToken);
      if (decoded is! Map<String, dynamic>) {
        throw const GroupEventApiException('단체 플로깅 응답 형식이 올바르지 않습니다.');
      }
      return GroupEvent.fromJson(decoded);
    } on ApiException catch (exception) {
      throw GroupEventApiException(exception.message);
    }
  }
}

class CreateGroupEventRequest {
  const CreateGroupEventRequest({
    required this.title,
    required this.regionSido,
    required this.regionSigungu,
    required this.startAt,
    required this.endAt,
    required this.maxParticipants,
    required this.placeName,
    required this.description,
    this.recruitDeadlineAt,
    this.address,
    this.lat,
    this.lng,
    this.supplies,
  });

  final String title;
  final String regionSido;
  final String regionSigungu;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? recruitDeadlineAt;
  final int maxParticipants;
  final String placeName;
  final String? address;
  final double? lat;
  final double? lng;
  final String? supplies;
  final String description;

  Map<String, Object?> toJson() {
    return {
      'title': title,
      'regionSido': regionSido,
      'regionSigungu': regionSigungu,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      if (recruitDeadlineAt != null)
        'recruitDeadlineAt': recruitDeadlineAt!.toIso8601String(),
      'maxParticipants': maxParticipants,
      'placeName': placeName,
      'address': address,
      'lat': lat,
      'lng': lng,
      'supplies': supplies,
      'description': description,
    };
  }
}

class GroupEventApiException implements Exception {
  const GroupEventApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
