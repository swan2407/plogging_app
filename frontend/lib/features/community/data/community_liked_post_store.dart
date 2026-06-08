class CommunityLikedPostStore {
  final Set<int> _likedPostIds = {};

  bool isLiked(int postId) {
    return _likedPostIds.contains(postId);
  }

  void markLiked(int postId) {
    _likedPostIds.add(postId);
  }

  void markUnliked(int postId) {
    _likedPostIds.remove(postId);
  }
}

final communityLikedPostStore = CommunityLikedPostStore();
