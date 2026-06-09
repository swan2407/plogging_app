import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../model/community_post.dart';

class CommunityApiService {
  CommunityApiService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<List<CommunityPost>> fetchPosts({String? category}) async {
    try {
      final decoded = await _apiClient.getWithQuery(
        '/api/posts',
        queryParameters: category == null ? null : {'category': category},
      );
      if (decoded is! List<dynamic>) {
        throw const CommunityApiException('게시글 응답 형식이 올바르지 않습니다.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CommunityPost.fromJson)
          .toList();
    } on ApiException catch (exception) {
      throw CommunityApiException(
        exception.message,
        statusCode: exception.statusCode,
      );
    }
  }

  Future<CommunityPost> createPost(
    CreateCommunityPostRequest request,
    String accessToken,
  ) async {
    return _requestPost(
      '/api/posts',
      usePost: true,
      body: request.toJson(),
      accessToken: accessToken,
    );
  }

  Future<CommunityPost> fetchPostDetail(int postId) async {
    return _requestPost('/api/posts/$postId');
  }

  Future<CommunityPost> likePost(int postId, String accessToken) async {
    return _requestPost(
      '/api/posts/$postId/likes',
      usePost: true,
      accessToken: accessToken,
    );
  }

  Future<CommunityPost> unlikePost(int postId, String accessToken) async {
    try {
      final decoded = await _apiClient.delete(
        '/api/posts/$postId/likes',
        accessToken: accessToken,
      );
      return CommunityPost.fromJson(_requireMap(decoded, '게시글'));
    } on ApiException catch (exception) {
      throw CommunityApiException(
        exception.message,
        statusCode: exception.statusCode,
      );
    }
  }

  Future<List<CommunityComment>> fetchComments(int postId) async {
    try {
      final decoded = await _apiClient.get('/api/posts/$postId/comments');
      if (decoded is! List<dynamic>) {
        throw const CommunityApiException('댓글 응답 형식이 올바르지 않습니다.');
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CommunityComment.fromJson)
          .toList();
    } on ApiException catch (exception) {
      throw CommunityApiException(
        exception.message,
        statusCode: exception.statusCode,
      );
    }
  }

  Future<CommunityComment> createComment(
    int postId,
    String content,
    String accessToken,
  ) async {
    try {
      final decoded = await _apiClient.post(
        '/api/posts/$postId/comments',
        body: {'content': content},
        accessToken: accessToken,
      );
      return CommunityComment.fromJson(_requireMap(decoded, '댓글'));
    } on ApiException catch (exception) {
      throw CommunityApiException(
        exception.message,
        statusCode: exception.statusCode,
      );
    }
  }

  Future<CommunityPost> _requestPost(
    String path, {
    bool usePost = false,
    Object? body,
    String? accessToken,
  }) async {
    try {
      final decoded = usePost
          ? await _apiClient.post(path, body: body, accessToken: accessToken)
          : await _apiClient.get(path, accessToken: accessToken);
      return CommunityPost.fromJson(_requireMap(decoded, '게시글'));
    } on ApiException catch (exception) {
      throw CommunityApiException(
        exception.message,
        statusCode: exception.statusCode,
      );
    }
  }

  Map<String, dynamic> _requireMap(dynamic decoded, String resource) {
    if (decoded is! Map<String, dynamic>) {
      throw CommunityApiException('$resource 응답 형식이 올바르지 않습니다.');
    }
    return decoded;
  }
}

class CreateCommunityPostRequest {
  const CreateCommunityPostRequest({
    required this.category,
    required this.title,
    required this.content,
    this.sessionId,
    this.imageUrl,
    this.regionSido,
    this.regionSigungu,
  });

  final String category;
  final String title;
  final String content;
  final int? sessionId;
  final String? imageUrl;
  final String? regionSido;
  final String? regionSigungu;

  Map<String, Object?> toJson() {
    return {
      'category': category,
      'title': title,
      'content': content,
      'sessionId': sessionId,
      'imageUrl': imageUrl,
      'regionSido': regionSido,
      'regionSigungu': regionSigungu,
    };
  }
}

class CommunityApiException implements Exception {
  const CommunityApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isDuplicateLike {
    return statusCode == 409;
  }

  @override
  String toString() => message;
}
