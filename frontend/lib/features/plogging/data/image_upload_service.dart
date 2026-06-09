import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';

class ImageUploadService {
  ImageUploadService({http.Client? client, String baseUrl = apiBaseUrl})
    : _apiClient = ApiClient(client: client, baseUrl: baseUrl);

  final ApiClient _apiClient;

  Future<String> uploadTrashCertificationImage(
    XFile image,
    String accessToken,
  ) async {
    try {
      final decoded = await _apiClient.uploadMultipart(
        '/api/uploads/images',
        fieldName: 'file',
        bytes: await image.readAsBytes(),
        filename: image.name,
        contentType: _contentTypeFor(image),
        accessToken: accessToken,
      );
      if (decoded is! Map<String, dynamic>) {
        throw const ImageUploadException('사진 업로드에 실패했습니다.');
      }

      final imageUrl = decoded['imageUrl']?.toString().trim();
      if (imageUrl == null || imageUrl.isEmpty) {
        throw const ImageUploadException('사진 업로드에 실패했습니다.');
      }
      return imageUrl;
    } on ApiException catch (exception) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        throw const ImageUploadException('로그인이 필요합니다.');
      }
      throw ImageUploadException(exception.message);
    }
  }

  String _contentTypeFor(XFile image) {
    final reportedContentType = image.mimeType?.toLowerCase();
    if (reportedContentType == 'image/jpeg' ||
        reportedContentType == 'image/png' ||
        reportedContentType == 'image/webp') {
      return reportedContentType!;
    }

    final lowerName = image.name.toLowerCase();
    if (lowerName.endsWith('.png')) {
      return 'image/png';
    }
    if (lowerName.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}
