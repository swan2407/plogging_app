import 'package:flutter/foundation.dart';

class MockAuthController extends ValueNotifier<bool> {
  MockAuthController() : super(false);

  bool get isLoggedIn => value;

  void login() {
    value = true;
  }

  void logout() {
    value = false;
  }
}

final mockAuthController = MockAuthController();
