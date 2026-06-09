class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.userId,
    required this.authorNickname,
    required this.sessionId,
    required this.category,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.regionSido,
    required this.regionSigungu,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.sourceType = 'backend',
    this.linkedActivitySummary,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: _parseInt(json['id']),
      userId: _parseInt(json['userId']),
      authorNickname: _parseOptionalString(json['authorNickname']) ?? '익명',
      sessionId: _parseNullableInt(json['sessionId']),
      category: _parseOptionalString(json['category']) ?? '',
      title: _parseOptionalString(json['title']) ?? '',
      content: _parseOptionalString(json['content']) ?? '',
      imageUrl: _parseOptionalString(json['imageUrl']),
      regionSido: _parseOptionalString(json['regionSido']),
      regionSigungu: _parseOptionalString(json['regionSigungu']),
      likeCount: _parseInt(json['likeCount']),
      commentCount: _parseInt(json['commentCount']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final int userId;
  final String authorNickname;
  final int? sessionId;
  final String category;
  final String title;
  final String content;
  final String? imageUrl;
  final String? regionSido;
  final String? regionSigungu;
  final int likeCount;
  final int commentCount;
  final DateTime? createdAt;
  final String sourceType;
  final String? linkedActivitySummary;

  String get categoryLabel => communityCategoryLabel(category);

  String get region {
    final values = [regionSido, regionSigungu]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    return values.isEmpty ? '지역 정보 없음' : values.join(' ');
  }

  String get createdDate => formatCommunityDate(createdAt);

  CommunityPost copyWith({int? likeCount, int? commentCount}) {
    return CommunityPost(
      id: id,
      userId: userId,
      authorNickname: authorNickname,
      sessionId: sessionId,
      category: category,
      title: title,
      content: content,
      imageUrl: imageUrl,
      regionSido: regionSido,
      regionSigungu: regionSigungu,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      sourceType: sourceType,
      linkedActivitySummary: linkedActivitySummary,
    );
  }
}

class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.authorNickname,
    required this.content,
    required this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: _parseInt(json['id']),
      postId: _parseInt(json['postId']),
      userId: _parseInt(json['userId']),
      authorNickname: _parseOptionalString(json['authorNickname']) ?? '익명',
      content: _parseOptionalString(json['content']) ?? '',
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  final int id;
  final int postId;
  final int userId;
  final String authorNickname;
  final String content;
  final DateTime? createdAt;

  String get createdDate => formatCommunityDate(createdAt);
}

const communityPostCategories = ['활동 후기', '모집 홍보', '정보 공유', '질문'];
const communityPostFilterCategories = ['전체', ...communityPostCategories];

const _categoryValueByLabel = {
  '활동 후기': 'ACTIVITY_REVIEW',
  '모집 홍보': 'GROUP_PROMOTION',
  '정보 공유': 'INFO_SHARE',
  '질문': 'QUESTION',
};

const _categoryLabelByValue = {
  'ACTIVITY_REVIEW': '활동 후기',
  'GROUP_PROMOTION': '모집 홍보',
  'INFO_SHARE': '정보 공유',
  'QUESTION': '질문',
};

String? communityCategoryValue(String label) {
  if (label == '전체') {
    return null;
  }
  return _categoryValueByLabel[label];
}

String communityCategoryLabel(String value) {
  return _categoryLabelByValue[value] ?? (value.isEmpty ? '기타' : value);
}

String formatCommunityDate(DateTime? dateTime) {
  return dateTime == null ? '날짜 정보 없음' : '${dateTime.month}월 ${dateTime.day}일';
}

int _parseInt(Object? value) {
  return _parseNullableInt(value) ?? 0;
}

int? _parseNullableInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _parseOptionalString(Object? value) {
  final parsed = value?.toString().trim();
  return parsed == null || parsed.isEmpty ? null : parsed;
}

DateTime? _parseDateTime(Object? value) {
  return DateTime.tryParse(value?.toString() ?? '');
}
