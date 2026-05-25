import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import 'my_page_screen.dart';

class MyPageGate extends StatelessWidget {
  const MyPageGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: mockAuthController,
      builder: (context, isLoggedIn, child) {
        if (!isLoggedIn) {
          return const LoginScreen();
        }

        return const MyPageScreen();
      },
    );
  }
}
