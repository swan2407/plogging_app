class GroupEvent {
  const GroupEvent({
    required this.title,
    required this.area,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.currentParticipants,
    required this.maxParticipants,
    required this.leaderNickname,
    required this.startPlace,
    required this.supplies,
    required this.description,
  });

  final String title;
  final String area;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final int currentParticipants;
  final int maxParticipants;
  final String leaderNickname;
  final String startPlace;
  final String supplies;
  final String description;

  String get participantText => '$currentParticipants/$maxParticipants명';
}
