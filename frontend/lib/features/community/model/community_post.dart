class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.region,
    required this.authorNickname,
    required this.createdDate,
    required this.likeCount,
    required this.commentCount,
    required this.sourceType,
    this.linkedActivitySummary,
  });

  final String id;
  final String category;
  final String title;
  final String content;
  final String region;
  final String authorNickname;
  final String createdDate;
  final int likeCount;
  final int commentCount;
  final String sourceType;
  final String? linkedActivitySummary;
}
