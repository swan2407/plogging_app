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
