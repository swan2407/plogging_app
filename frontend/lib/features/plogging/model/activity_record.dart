class ActivityRecord {
  const ActivityRecord({
    required this.id,
    required this.type,
    required this.date,
    required this.region,
    required this.duration,
    required this.distance,
    required this.trashCertificationCount,
    required this.summary,
    this.status = '완료',
  });

  final String id;
  final String type;
  final String date;
  final String region;
  final String duration;
  final String distance;
  final int trashCertificationCount;
  final String summary;
  final String status;
}
