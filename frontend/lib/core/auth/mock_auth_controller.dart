import 'package:flutter/foundation.dart';

class MockAuthController extends ValueNotifier<bool> {
  MockAuthController() : super(false);

  String? accessToken;
  // MVP uses in-memory JWT storage. Move tokens to secure storage before production release.
  String? refreshToken;
  int? userId;
  String? nickname;

  bool get isLoggedIn => value;

  void login({
    required String accessToken,
    required String refreshToken,
    required int userId,
    required String nickname,
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.userId = userId;
    this.nickname = nickname;
    value = true;
  }

  void logout() {
    accessToken = null;
    refreshToken = null;
    userId = null;
    nickname = null;
    value = false;
  }
}

final mockAuthController = MockAuthController();
