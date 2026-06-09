import 'package:flutter/material.dart';

enum MapLayer { groupPlogging, trashRecord, recyclingStation, publicTrashCan }

class MapLayerConfig {
  const MapLayerConfig({
    required this.layer,
    required this.label,
    required this.icon,
  });

  final MapLayer layer;
  final String label;
  final IconData icon;
}

class MapMarker {
  const MapMarker({
    required this.layer,
    required this.title,
    required this.address,
    required this.distance,
  });

  final MapLayer layer;
  final String title;
  final String address;
  final String distance;
}

class TrashMapMarker {
  const TrashMapMarker({
    required this.id,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.trashType,
    required this.memo,
    required this.createdAt,
  });

  factory TrashMapMarker.fromJson(Map<String, dynamic> json) {
    return TrashMapMarker(
      id: _parseInt(json['id']),
      imageUrl: _parseNullableString(json['imageUrl']),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      trashType: _parseNullableString(json['trashType']),
      memo: _parseNullableString(json['memo']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final String? imageUrl;
  final double? lat;
  final double? lng;
  final String? trashType;
  final String? memo;
  final DateTime? createdAt;

  MapMarker toMapMarker() => MapMarker(
    layer: MapLayer.trashRecord,
    title: trashType ?? '쓰레기 기록',
    address: memo ?? _coordinateText(lat, lng),
    distance: _dateText(createdAt),
  );
}

class GroupEventMapMarker {
  const GroupEventMapMarker({
    required this.id,
    required this.title,
    required this.placeName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.startAt,
    required this.status,
    required this.currentParticipants,
    required this.maxParticipants,
  });

  factory GroupEventMapMarker.fromJson(Map<String, dynamic> json) {
    return GroupEventMapMarker(
      id: _parseInt(json['id']),
      title: _parseString(json['title'], fallback: '단체 플로깅'),
      placeName: _parseNullableString(json['placeName']),
      address: _parseNullableString(json['address']),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      startAt: _parseDateTime(json['startAt']),
      status: _parseNullableString(json['status']),
      currentParticipants: _parseInt(json['currentParticipants']),
      maxParticipants: _parseInt(json['maxParticipants']),
    );
  }

  final int id;
  final String title;
  final String? placeName;
  final String? address;
  final double? lat;
  final double? lng;
  final DateTime? startAt;
  final String? status;
  final int currentParticipants;
  final int maxParticipants;

  MapMarker toMapMarker() => MapMarker(
    layer: MapLayer.groupPlogging,
    title: title,
    address: address ?? placeName ?? _coordinateText(lat, lng),
    distance: '$currentParticipants/$maxParticipants명',
  );
}

int _parseInt(Object? value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double? _parseDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String _parseString(Object? value, {required String fallback}) =>
    _parseNullableString(value) ?? fallback;

String? _parseNullableString(Object? value) {
  final parsed = value?.toString().trim();
  return parsed == null || parsed.isEmpty ? null : parsed;
}

DateTime? _parseDateTime(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '');

String _coordinateText(double? lat, double? lng) {
  if (lat == null || lng == null) return '위치 정보 없음';
  return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
}

String _dateText(DateTime? value) =>
    value == null ? '날짜 정보 없음' : '${value.month}/${value.day}';
