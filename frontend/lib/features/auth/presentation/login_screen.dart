import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.popAfterLogin = false});

  final bool popAfterLogin;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);
  static const _kakaoYellow = Color(0xFFFEE500);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _darkText,
        elevation: 0,
        title: const Text('로그인'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const _LoginHero(),
            const SizedBox(height: 20),
            _AuthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthTextField(
                    label: '아이디',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _AuthTextField(
                    label: '비밀번호',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 18),
                  _PrimaryAuthButton(
                    label: '로그인',
                    icon: Icons.login,
                    onPressed: () => _login(context),
                  ),
                  const SizedBox(height: 12),
                  _KakaoPlaceholderButton(
                    onPressed: () => _showPlaceholderMessage(
                      context,
                      '카카오 로그인은 아직 준비 중입니다.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SecondaryAuthButton(
                    label: '회원가입',
                    icon: Icons.person_add_alt_1_outlined,
                    onPressed: () => _openSignup(context),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _browseAsGuest(context),
                    child: const Text(
                      '비회원으로 둘러보기',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) {
    mockAuthController.login();
    _returnToMainNavigation(context);
  }

  void _browseAsGuest(BuildContext context) {
    mockAuthController.logout();
    _returnToMainNavigation(context);
  }

  void _openSignup(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SignupScreen(popAfterSignup: true),
      ),
    );
  }

  void _returnToMainNavigation(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _showPlaceholderMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return const _AuthCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: LoginScreen._lightGreen,
            child: Icon(
              Icons.eco_outlined,
              color: LoginScreen._green,
              size: 44,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Plogging',
            style: TextStyle(
              color: LoginScreen._green,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '우리 동네를 함께 깨끗하게',
            style: TextStyle(
              color: LoginScreen._grayText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.textInputAction,
  });

  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: LoginScreen._green),
        filled: true,
        fillColor: LoginScreen._background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LoginScreen._green, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: LoginScreen._green,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: LoginScreen._green.withValues(alpha: 0.24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAuthButton extends StatelessWidget {
  const _SecondaryAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: LoginScreen._green,
          side: const BorderSide(color: LoginScreen._green),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _KakaoPlaceholderButton extends StatelessWidget {
  const _KakaoPlaceholderButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.chat_bubble_outline, size: 19),
        label: const Text(
          '카카오 로그인',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: LoginScreen._kakaoYellow,
          foregroundColor: const Color(0xFF191919),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
