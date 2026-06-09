import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../data/auth_api_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.popAfterLogin = false});

  final bool popAfterLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authApiService = AuthApiService();
  bool _isSubmitting = false;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);
  static const _kakaoYellow = Color(0xFFFEE500);

  @override
  void dispose() {
    _loginIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                  _AuthTextField(
                    controller: _loginIdController,
                    label: '아이디',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _AuthTextField(
                    controller: _passwordController,
                    label: '비밀번호',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 18),
                  _PrimaryAuthButton(
                    label: _isSubmitting ? '로그인 중...' : '로그인',
                    icon: Icons.login,
                    onPressed: _isSubmitting ? null : _login,
                  ),
                  const SizedBox(height: 12),
                  _KakaoPlaceholderButton(
                    onPressed: () =>
                        _showMessage(context, '카카오 로그인은 아직 준비 중입니다.'),
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

  Future<void> _login() async {
    if (_loginIdController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage(context, '아이디와 비밀번호를 입력해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _authApiService.login(
        loginId: _loginIdController.text.trim(),
        password: _passwordController.text,
      );
      await mockAuthController.login(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userId: result.userId,
        nickname: result.nickname,
      );

      if (mounted) {
        _returnToMainNavigation(context);
      }
    } on AuthApiException catch (exception) {
      debugPrint('Login failed: $exception');
      if (mounted) {
        _showMessage(context, exception.message);
      }
    } catch (error) {
      debugPrint('Login response handling failed: $error');
      if (mounted) {
        _showMessage(context, '서버에 연결할 수 없습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _browseAsGuest(BuildContext context) async {
    await mockAuthController.logout();
    if (!context.mounted) {
      return;
    }
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

  void _showMessage(BuildContext context, String message) {
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
            backgroundColor: _LoginScreenState._lightGreen,
            child: Icon(
              Icons.eco_outlined,
              color: _LoginScreenState._green,
              size: 44,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Plogging',
            style: TextStyle(
              color: _LoginScreenState._green,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '우리 동네를 함께 깨끗하게',
            style: TextStyle(
              color: _LoginScreenState._grayText,
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
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _LoginScreenState._green),
        filled: true,
        fillColor: _LoginScreenState._background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _LoginScreenState._green,
            width: 1.4,
          ),
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
  final VoidCallback? onPressed;

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
          backgroundColor: _LoginScreenState._green,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: _LoginScreenState._green.withValues(alpha: 0.24),
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
          foregroundColor: _LoginScreenState._green,
          side: const BorderSide(color: _LoginScreenState._green),
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
          backgroundColor: _LoginScreenState._kakaoYellow,
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
