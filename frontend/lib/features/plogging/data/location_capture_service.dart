import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationCaptureService {
  Future<Position> getCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationCaptureException('위치 서비스를 켜 주세요.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationCaptureException('위치 권한이 필요합니다.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationCaptureException('설정에서 위치 권한을 허용해 주세요.');
      }

      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } on LocationCaptureException {
      rethrow;
    } catch (error) {
      debugPrint('Current location capture failed: $error');
      throw LocationCaptureException(
        kIsWeb ? '웹에서 현재 위치를 확인할 수 없습니다.' : '현재 위치를 확인할 수 없습니다.',
      );
    }
  }
}

class LocationCaptureException implements Exception {
  const LocationCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}
