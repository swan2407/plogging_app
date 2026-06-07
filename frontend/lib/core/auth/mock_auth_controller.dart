import 'package:flutter/foundation.dart';

class MockAuthController extends ValueNotifier<bool> {
  MockAuthController() : super(false);

  String? accessToken;
  int? userId;
  String? nickname;

  bool get isLoggedIn => value;

  void login({
    required String accessToken,
    required int userId,
    required String nickname,
  }) {
    this.accessToken = accessToken;
    this.userId = userId;
    this.nickname = nickname;
    value = true;
  }

  void logout() {
    accessToken = null;
    userId = null;
    nickname = null;
    value = false;
  }
}

final mockAuthController = MockAuthController();
