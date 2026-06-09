class GroupEvent {
  const GroupEvent({
    required this.id,
    required this.title,
    required this.leaderId,
    required this.leaderNickname,
    required this.regionSido,
    required this.regionSigungu,
    required this.startAt,
    required this.endAt,
    required this.recruitDeadlineAt,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.placeName,
    required this.address,
    required this.supplies,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory GroupEvent.fromJson(Map<String, dynamic> json) {
    return GroupEvent(
      id: _parseInt(json['id']),
      title: _parseString(json['title'], fallback: '제목 없음'),
      leaderId: _parseInt(json['leaderId']),
      leaderNickname: _parseString(json['leaderNickname'], fallback: '익명'),
      regionSido: _parseString(json['regionSido']),
      regionSigungu: _parseString(json['regionSigungu']),
      startAt: _parseDateTime(json['startAt']),
      endAt: _parseDateTime(json['endAt']),
      recruitDeadlineAt: _parseDateTime(json['recruitDeadlineAt']),
      maxParticipants: _parseInt(json['maxParticipants']),
      currentParticipants: _parseInt(json['currentParticipants']),
      placeName: _parseString(json['placeName'], fallback: '장소 정보 없음'),
      address: _parseNullableString(json['address']),
      supplies: _parseNullableString(json['supplies']),
      description: _parseString(json['description'], fallback: '상세 설명이 없습니다.'),
      status: _parseString(json['status']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final String title;
  final int leaderId;
  final String leaderNickname;
  final String regionSido;
  final String regionSigungu;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? recruitDeadlineAt;
  final int maxParticipants;
  final int currentParticipants;
  final String placeName;
  final String? address;
  final String? supplies;
  final String description;
  final String status;
  final DateTime? createdAt;

  String get area {
    final value = [
      regionSido,
      regionSigungu,
    ].where((item) => item.trim().isNotEmpty).join(' ');
    return value.isEmpty ? '지역 정보 없음' : value;
  }

  String get date =>
      startAt == null ? '날짜 정보 없음' : '${startAt!.month}월 ${startAt!.day}일';
  String get startTime => _formatTime(startAt);
  String get endTime => _formatTime(endAt);
  String get startPlace => placeName;
  String get suppliesText =>
      supplies?.trim().isNotEmpty == true ? supplies! : '없음';
  String get participantText => '$currentParticipants/$maxParticipants명';

  String get statusLabel {
    return switch (status) {
      'RECRUITING' => '모집중',
      'CLOSED' => '모집마감',
      'IN_PROGRESS' => '진행중',
      'COMPLETED' => '완료',
      'CANCELED' => '취소',
      _ => status.isEmpty ? '상태 정보 없음' : status,
    };
  }

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '시간 정보 없음';
    }
    final period = value.hour < 12 ? '오전' : '오후';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }
}

int _parseInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _parseString(Object? value, {String fallback = ''}) {
  return _parseNullableString(value) ?? fallback;
}

String? _parseNullableString(Object? value) {
  final parsed = value?.toString().trim();
  return parsed == null || parsed.isEmpty ? null : parsed;
}

DateTime? _parseDateTime(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '');
}
