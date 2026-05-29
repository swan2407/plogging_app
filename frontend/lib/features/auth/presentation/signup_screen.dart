import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.popAfterSignup = false});

  final bool popAfterSignup;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _termsAgreed = false;
  bool _privacyAgreed = false;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _darkText,
        elevation: 0,
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const _SignupHeader(),
            const SizedBox(height: 18),
            _SignupCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SignupTextField(
                    label: '아이디',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _SignupTextField(
                    label: '비밀번호',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _SignupTextField(
                    label: '비밀번호 확인',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _SignupTextField(
                    label: '이름',
                    icon: Icons.badge_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _SignupTextField(
                    label: '전화번호',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _SignupTextField(
                    label: '닉네임',
                    icon: Icons.face_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  const _SignupTextField(
                    label: '지역',
                    icon: Icons.location_on_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 18),
                  _AgreementTile(
                    value: _termsAgreed,
                    label: '필수 약관 동의',
                    onChanged: (value) {
                      setState(() {
                        _termsAgreed = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _AgreementTile(
                    value: _privacyAgreed,
                    label: '개인정보 수집 및 이용 동의',
                    onChanged: (value) {
                      setState(() {
                        _privacyAgreed = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _completeSignup,
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text(
                        '회원가입 완료',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: _green.withValues(alpha: 0.24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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

  Future<void> _completeSignup() async {
    mockAuthController.login();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('가입 완료'),
          content: const Text('회원가입이 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (widget.popAfterSignup && Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    return const _SignupCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _SignupScreenState._lightGreen,
            child: Icon(
              Icons.eco_outlined,
              color: _SignupScreenState._green,
              size: 34,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plogging 시작하기',
                  style: TextStyle(
                    color: _SignupScreenState._darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'mock 정보로 간단히 가입해요.',
                  style: TextStyle(
                    color: _SignupScreenState._grayText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
  });

  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _SignupScreenState._green),
        filled: true,
        fillColor: _SignupScreenState._background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _SignupScreenState._green,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _SignupScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        activeColor: _SignupScreenState._green,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(
          label,
          style: const TextStyle(
            color: _SignupScreenState._darkText,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SignupCard extends StatelessWidget {
  const _SignupCard({required this.child});

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
