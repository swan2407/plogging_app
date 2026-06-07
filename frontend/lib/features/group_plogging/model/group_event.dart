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
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      leaderId: (json['leaderId'] as num).toInt(),
      leaderNickname: json['leaderNickname'] as String,
      regionSido: json['regionSido'] as String,
      regionSigungu: json['regionSigungu'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      recruitDeadlineAt: DateTime.parse(json['recruitDeadlineAt'] as String),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      currentParticipants: (json['currentParticipants'] as num).toInt(),
      placeName: json['placeName'] as String,
      address: json['address'] as String?,
      supplies: json['supplies'] as String?,
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int id;
  final String title;
  final int leaderId;
  final String leaderNickname;
  final String regionSido;
  final String regionSigungu;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime recruitDeadlineAt;
  final int maxParticipants;
  final int currentParticipants;
  final String placeName;
  final String? address;
  final String? supplies;
  final String description;
  final String status;
  final DateTime createdAt;

  String get area => '$regionSido $regionSigungu';
  String get date => '${startAt.month}월 ${startAt.day}일';
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
      _ => status,
    };
  }

  String _formatTime(DateTime value) {
    final period = value.hour < 12 ? '오전' : '오후';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$period $hour:$minute';
  }
}
