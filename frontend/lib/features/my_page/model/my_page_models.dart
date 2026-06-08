import 'package:flutter/material.dart';

class MyPageStat {
  const MyPageStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class UserActivitySummary {
  const UserActivitySummary({
    required this.userId,
    required this.nickname,
    required this.totalPloggingCount,
    required this.totalDistanceMeter,
    required this.totalDurationSeconds,
    required this.totalTrashCertificationCount,
  });

  factory UserActivitySummary.fromJson(Map<String, dynamic> json) {
    return UserActivitySummary(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      totalPloggingCount: (json['totalPloggingCount'] as num).toInt(),
      totalDistanceMeter: (json['totalDistanceMeter'] as num).toInt(),
      totalDurationSeconds: (json['totalDurationSeconds'] as num).toInt(),
      totalTrashCertificationCount:
          (json['totalTrashCertificationCount'] as num).toInt(),
    );
  }

  final int userId;
  final String nickname;
  final int totalPloggingCount;
  final int totalDistanceMeter;
  final int totalDurationSeconds;
  final int totalTrashCertificationCount;
}

class JoinedGroupPlogging {
  const JoinedGroupPlogging({
    required this.title,
    required this.date,
    required this.region,
    required this.status,
  });

  final String title;
  final String date;
  final String region;
  final String status;
}

class MyPagePost {
  const MyPagePost({
    required this.title,
    required this.createdDate,
    required this.likes,
    required this.comments,
  });

  final String title;
  final String createdDate;
  final int likes;
  final int comments;
}
