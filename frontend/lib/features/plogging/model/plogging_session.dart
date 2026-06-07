import 'activity_record.dart';

class PloggingSession {
  const PloggingSession({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.durationSeconds,
    required this.distanceMeter,
    required this.regionSido,
    required this.regionSigungu,
    required this.trashCertificationCount,
    required this.createdAt,
  });

  factory PloggingSession.fromJson(Map<String, dynamic> json) {
    return PloggingSession(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      type: json['type'] as String,
      status: json['status'] as String,
      startAt: DateTime.parse(json['startAt'] as String),
      endAt: DateTime.parse(json['endAt'] as String),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      distanceMeter: (json['distanceMeter'] as num).toInt(),
      regionSido: json['regionSido'] as String?,
      regionSigungu: json['regionSigungu'] as String?,
      trashCertificationCount: (json['trashCertificationCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int id;
  final int userId;
  final String type;
  final String status;
  final DateTime startAt;
  final DateTime endAt;
  final int durationSeconds;
  final int distanceMeter;
  final String? regionSido;
  final String? regionSigungu;
  final int trashCertificationCount;
  final DateTime createdAt;

  ActivityRecord toActivityRecord() {
    return ActivityRecord(
      id: 'backend-$id',
      type: type == 'PERSONAL' ? '개인' : '단체',
      date:
          '${startAt.year}.${_twoDigits(startAt.month)}.${_twoDigits(startAt.day)}',
      region: [regionSido, regionSigungu]
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .join(' ')
          .ifEmpty('지역 정보 없음'),
      duration: _formatDuration(durationSeconds),
      distance: '${(distanceMeter / 1000).toStringAsFixed(1)}km',
      trashCertificationCount: trashCertificationCount,
      summary: '개인 플로깅 활동 기록',
      status: _statusLabel(status),
    );
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return remainingMinutes > 0 ? '$hours시간 $remainingMinutes분' : '$hours시간';
    }
    return '$minutes분';
  }

  String _statusLabel(String value) {
    return switch (value) {
      'IN_PROGRESS' => '진행 중',
      'PAUSED' => '일시정지',
      'COMPLETED' => '완료',
      'CANCELED' => '취소',
      _ => value,
    };
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
