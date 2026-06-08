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
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      authorNickname: json['authorNickname'] as String,
      sessionId: (json['sessionId'] as num?)?.toInt(),
      category: json['category'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      regionSido: json['regionSido'] as String?,
      regionSigungu: json['regionSigungu'] as String?,
      likeCount: (json['likeCount'] as num).toInt(),
      commentCount: (json['commentCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
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
  final DateTime createdAt;
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

  String get createdDate => '${createdAt.month}월 ${createdAt.day}일';

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
      id: (json['id'] as num).toInt(),
      postId: (json['postId'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      authorNickname: json['authorNickname'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int id;
  final int postId;
  final int userId;
  final String authorNickname;
  final String content;
  final DateTime createdAt;
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
  return _categoryLabelByValue[value] ?? value;
}
