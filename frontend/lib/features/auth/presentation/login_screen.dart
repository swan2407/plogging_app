import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.popAfterLogin = false});

  final bool popAfterLogin;

  static const _green = Color(0xFF2E7D32);
  static const _background = Color(0xFFF6F7F5);
  static const _grayText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        elevation: 0,
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            const Text(
              '플로깅',
              style: TextStyle(
                color: _green,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '로그인하고 나의 플로깅 기록을 이어가세요.',
              style: TextStyle(
                color: _grayText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            const _LoginField(label: '아이디', icon: Icons.person_outline),
            const SizedBox(height: 14),
            const _LoginField(
              label: '비밀번호',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: () {
                  mockAuthController.login();

                  if (popAfterLogin && Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                '아직 계정이 없으신가요? 회원가입은 다음 단계에서 제공됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _grayText,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  final String label;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
