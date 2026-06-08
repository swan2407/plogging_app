import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/group_event.dart';

class GroupEventApiService {
  GroupEventApiService({
    http.Client? client,
    this.baseUrl = 'http://localhost:8080',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<List<GroupEvent>> fetchGroupEvents() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/group-events'));
    final decoded = _decode(response);
    return (decoded as List<dynamic>)
        .map((item) => GroupEvent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<GroupEvent> fetchGroupEventDetail(int eventId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/group-events/$eventId'),
    );
    return GroupEvent.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<GroupEvent> createGroupEvent(
    CreateGroupEventRequest request,
    String accessToken,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/group-events'),
      headers: _authorizedHeaders(accessToken),
      body: utf8.encode(jsonEncode(request.toJson())),
    );
    return GroupEvent.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<GroupEvent> joinGroupEvent(int eventId, String accessToken) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/group-events/$eventId/join'),
      headers: _authorizedHeaders(accessToken),
    );
    return GroupEvent.fromJson(_decode(response) as Map<String, dynamic>);
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
      throw GroupEventApiException(
        response.statusCode == 401
            ? '로그인이 만료되었습니다. 다시 로그인해 주세요.'
            : message ?? '요청 처리 중 오류가 발생했습니다.',
      );
    }
    return decoded;
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
