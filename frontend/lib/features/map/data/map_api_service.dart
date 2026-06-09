import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../model/map_models.dart';

class MapApiService {
  MapApiService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<List<TrashMapMarker>> fetchTrashMarkers() async {
    final decoded = await _apiClient.get('/api/map/trash-records');
    return _parseList(decoded, TrashMapMarker.fromJson);
  }

  Future<List<GroupEventMapMarker>> fetchGroupEventMarkers() async {
    final decoded = await _apiClient.get('/api/map/group-events');
    return _parseList(decoded, GroupEventMapMarker.fromJson);
  }

  List<T> _parseList<T>(
    dynamic decoded,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (decoded is! List<dynamic>) {
      throw const MapApiException('지도 데이터 응답 형식이 올바르지 않습니다.');
    }
    return decoded.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }
}

class MapApiException implements Exception {
  const MapApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
