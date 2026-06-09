import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/community_post.dart';

class CommunityApiService {
  CommunityApiService({
    http.Client? client,
    this.baseUrl = 'http://localhost:8080',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Future<List<CommunityPost>> fetchPosts({String? category}) async {
    final uri = Uri.parse('$baseUrl/api/posts').replace(
      queryParameters: category == null ? null : {'category': category},
    );
    final response = await _client.get(uri);
    final decoded = _decode(response);
    if (decoded is! List<dynamic>) {
      throw const CommunityApiException('게시글 응답 형식이 올바르지 않습니다.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CommunityPost.fromJson)
        .toList();
  }

  Future<CommunityPost> createPost(
    CreateCommunityPostRequest request,
    String accessToken,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/posts'),
      headers: _authorizedHeaders(accessToken),
      body: utf8.encode(jsonEncode(request.toJson())),
    );
    return CommunityPost.fromJson(_decodeMap(response, '게시글'));
  }

  Future<CommunityPost> fetchPostDetail(int postId) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/posts/$postId'));
    return CommunityPost.fromJson(_decodeMap(response, '게시글'));
  }

  Future<CommunityPost> likePost(int postId, String accessToken) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/posts/$postId/likes'),
      headers: _authorizedHeaders(accessToken),
    );
    return CommunityPost.fromJson(_decodeMap(response, '게시글'));
  }

  Future<CommunityPost> unlikePost(int postId, String accessToken) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/api/posts/$postId/likes'),
      headers: _authorizedHeaders(accessToken),
    );
    return CommunityPost.fromJson(_decodeMap(response, '게시글'));
  }

  Future<List<CommunityComment>> fetchComments(int postId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/api/posts/$postId/comments'),
    );
    final decoded = _decode(response);
    if (decoded is! List<dynamic>) {
      throw const CommunityApiException('댓글 응답 형식이 올바르지 않습니다.');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CommunityComment.fromJson)
        .toList();
  }

  Future<CommunityComment> createComment(
    int postId,
    String content,
    String accessToken,
  ) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/posts/$postId/comments'),
      headers: _authorizedHeaders(accessToken),
      body: utf8.encode(jsonEncode({'content': content})),
    );
    return CommunityComment.fromJson(_decodeMap(response, '댓글'));
  }

  Map<String, String> _authorizedHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  dynamic _decode(http.Response response) {
    final decoded = response.bodyBytes.isEmpty
        ? null
        : jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message'] as String?
          : null;
      throw CommunityApiException(
        response.statusCode == 401
            ? '로그인이 만료되었습니다. 다시 로그인해 주세요.'
            : message ?? '게시글을 불러오지 못했습니다.',
        statusCode: response.statusCode,
      );
    }
    return decoded;
  }

  Map<String, dynamic> _decodeMap(http.Response response, String resource) {
    final decoded = _decode(response);
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
