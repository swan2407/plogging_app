import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../../core/constants/korea_regions.dart';
import '../data/auth_api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.popAfterSignup = false});

  final bool popAfterSignup;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianContactController = TextEditingController();
  final _guardianRelationController = TextEditingController();
  final _authApiService = AuthApiService();

  bool? _isOver14;
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _locationAgreed = false;
  bool _photoAgreed = false;
  bool _guardianAgreed = false;
  String? _selectedSido;
  String? _selectedSigungu;
  bool _isSubmitting = false;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);
  static const _error = Color(0xFFB42318);

  static const _legalFiles = {
    _LegalDocument.terms: 'assets/legal/terms_of_service.md',
    _LegalDocument.privacy: 'assets/legal/privacy_policy.md',
    _LegalDocument.location: 'assets/legal/location_terms.md',
    _LegalDocument.photo: 'assets/legal/photo_certification_policy.md',
    _LegalDocument.guardian: 'assets/legal/child_guardian_consent_policy.md',
  };

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _idController,
      _passwordController,
      _passwordConfirmController,
      _nicknameController,
      _guardianNameController,
      _guardianContactController,
      _guardianRelationController,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    _guardianNameController.dispose();
    _guardianContactController.dispose();
    _guardianRelationController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasLetter => RegExp(r'[A-Za-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_passwordController.text);
  bool get _hasSpecial => RegExp(
    r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]',
  ).hasMatch(_passwordController.text);
  bool get _hasNoSpaces => !RegExp(r'\s').hasMatch(_passwordController.text);
  bool get _isPasswordValid =>
      _hasMinLength && _hasLetter && _hasNumber && _hasSpecial && _hasNoSpaces;
  bool get _doesPasswordMatch =>
      _passwordConfirmController.text.isNotEmpty &&
      _passwordController.text == _passwordConfirmController.text;
  bool get _requiredAgreementsDone =>
      _termsAgreed && _privacyAgreed && _locationAgreed && _photoAgreed;
  bool get _guardianFieldsDone =>
      _guardianNameController.text.trim().isNotEmpty &&
      _guardianContactController.text.trim().isNotEmpty &&
      _guardianRelationController.text.trim().isNotEmpty &&
      _guardianAgreed;
  bool get _canSubmit {
    final basicFieldsDone =
        _idController.text.trim().isNotEmpty &&
        _nicknameController.text.trim().isNotEmpty &&
        _isOver14 != null;
    final ageRequirementsDone =
        _isOver14 == true || (_isOver14 == false && _guardianFieldsDone);
    return basicFieldsDone &&
        !_isSubmitting &&
        _isPasswordValid &&
        _doesPasswordMatch &&
        _requiredAgreementsDone &&
        ageRequirementsDone;
  }

  String get _regionText {
    if (_selectedSido == null || _selectedSigungu == null) {
      return '주 활동 지역 선택';
    }
    return '$_selectedSido $_selectedSigungu';
  }

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            const _SignupHeader(),
            const SizedBox(height: 16),
            _SignupCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle(title: '기본 정보'),
                  const SizedBox(height: 12),
                  _SignupTextField(
                    controller: _idController,
                    label: '아이디',
                    icon: Icons.person_outline,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _SignupTextField(
                    controller: _passwordController,
                    label: '비밀번호',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  _PasswordRules(
                    hasMinLength: _hasMinLength,
                    hasLetter: _hasLetter,
                    hasNumber: _hasNumber,
                    hasSpecial: _hasSpecial,
                    hasNoSpaces: _hasNoSpaces,
                  ),
                  const SizedBox(height: 12),
                  _SignupTextField(
                    controller: _passwordConfirmController,
                    label: '비밀번호 확인',
                    icon: Icons.lock_reset_outlined,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  _RuleMessage(
                    passed: _doesPasswordMatch,
                    label: '비밀번호가 일치합니다.',
                    failedLabel: '비밀번호 확인이 일치해야 합니다.',
                    showFailed: _passwordConfirmController.text.isNotEmpty,
                  ),
                  const SizedBox(height: 12),
                  _SignupTextField(
                    controller: _nicknameController,
                    label: '닉네임',
                    icon: Icons.badge_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle(title: '연령 확인'),
                  const SizedBox(height: 10),
                  _AgeChoice(
                    isOver14: _isOver14,
                    onChanged: (value) {
                      setState(() {
                        _isOver14 = value;
                        if (value == true) {
                          _guardianAgreed = false;
                        }
                      });
                    },
                  ),
                  if (_isOver14 == false) ...[
                    const SizedBox(height: 14),
                    _GuardianConsentSection(
                      nameController: _guardianNameController,
                      contactController: _guardianContactController,
                      relationController: _guardianRelationController,
                      guardianAgreed: _guardianAgreed,
                      onGuardianAgreedChanged: (value) {
                        setState(() {
                          _guardianAgreed = value ?? false;
                        });
                      },
                      onViewGuardianConsent: () => _showLegalDocument(
                        _LegalDocument.guardian,
                        '만 14세 미만 아동의 법정대리인 동의 안내',
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const _SectionTitle(title: '주 활동 지역'),
                  const SizedBox(height: 10),
                  _RegionButton(
                    text: _regionText,
                    hasSelection: _selectedSido != null,
                    onPressed: _openRegionSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SignupCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle(title: '필수 약관 동의'),
                  const SizedBox(height: 8),
                  _AgreementTile(
                    value: _termsAgreed,
                    title: '이용약관',
                    onChanged: (value) =>
                        setState(() => _termsAgreed = value ?? false),
                    onView: () =>
                        _showLegalDocument(_LegalDocument.terms, '이용약관'),
                  ),
                  _AgreementTile(
                    value: _privacyAgreed,
                    title: '개인정보 처리방침',
                    onChanged: (value) =>
                        setState(() => _privacyAgreed = value ?? false),
                    onView: () =>
                        _showLegalDocument(_LegalDocument.privacy, '개인정보 처리방침'),
                  ),
                  _AgreementTile(
                    value: _locationAgreed,
                    title: '위치기반 서비스 이용약관',
                    onChanged: (value) =>
                        setState(() => _locationAgreed = value ?? false),
                    onView: () => _showLegalDocument(
                      _LegalDocument.location,
                      '위치기반 서비스 이용약관',
                    ),
                  ),
                  _AgreementTile(
                    value: _photoAgreed,
                    title: '사진 인증 및 콘텐츠 정책',
                    onChanged: (value) =>
                        setState(() => _photoAgreed = value ?? false),
                    onView: () => _showLegalDocument(
                      _LegalDocument.photo,
                      '사진 인증 및 콘텐츠 정책',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _canSubmit ? _completeSignup : null,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  _isSubmitting ? '회원가입 중...' : '회원가입 완료',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  disabledForegroundColor: Colors.white,
                  elevation: _canSubmit ? 8 : 0,
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
    );
  }

  Future<void> _openRegionSheet() async {
    String? tempSido = _selectedSido;
    String? tempSigungu = _selectedSigungu;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sigunguList = tempSido == null
                ? <String>[]
                : sigunguMap[tempSido] ?? <String>[];

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '주 활동 지역 선택',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: _RegionList(
                                title: '시/도',
                                items: sidoList,
                                selectedItem: tempSido,
                                onSelected: (item) {
                                  setSheetState(() {
                                    tempSido = item;
                                    tempSigungu = null;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _RegionList(
                                title: '시/군/구',
                                items: sigunguList,
                                selectedItem: tempSigungu,
                                emptyText: '시/도를 먼저 선택하세요.',
                                onSelected: (item) {
                                  setSheetState(() {
                                    tempSigungu = item;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSido = null;
                                  _selectedSigungu = null;
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('선택 안 함'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: tempSido != null && tempSigungu != null
                                  ? () {
                                      setState(() {
                                        _selectedSido = tempSido;
                                        _selectedSigungu = tempSigungu;
                                      });
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              child: const Text('저장'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLegalDocument(_LegalDocument document, String title) async {
    final path = _legalFiles[document]!;
    String content;

    try {
      content = await rootBundle.loadString(path);
    } catch (_) {
      content = '약관 내용을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
    }

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: _darkText,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeSignup() async {
    if (!_canSubmit) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final agreements = <Map<String, Object>>[
        _agreement('TERMS_OF_SERVICE', _termsAgreed),
        _agreement('PRIVACY_POLICY', _privacyAgreed),
        _agreement('LOCATION_TERMS', _locationAgreed),
        _agreement('PHOTO_CERTIFICATION_POLICY', _photoAgreed),
        if (_isOver14 == false)
          _agreement('CHILD_GUARDIAN_CONSENT', _guardianAgreed),
      ];
      final result = await _authApiService.signup(
        loginId: _idController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
        regionSido: _selectedSido,
        regionSigungu: _selectedSigungu,
        agreements: agreements,
      );
      mockAuthController.login(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        userId: result.userId,
        nickname: result.nickname,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다.')));

      if (widget.popAfterSignup && Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthApiException catch (exception) {
      if (mounted) {
        _showError(exception.message);
      }
    } catch (_) {
      if (mounted) {
        _showError('서버에 연결할 수 없습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Map<String, Object> _agreement(String termsType, bool agreed) {
    return {'termsType': termsType, 'termsVersion': 'v1.0', 'agreed': agreed};
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _LegalDocument { terms, privacy, location, photo, guardian }

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
                  '필수 정보와 약관 동의만 받고 바로 이용할 수 있어요.',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _SignupScreenState._darkText,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SignupTextField extends StatelessWidget {
  const _SignupTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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

class _PasswordRules extends StatelessWidget {
  const _PasswordRules({
    required this.hasMinLength,
    required this.hasLetter,
    required this.hasNumber,
    required this.hasSpecial,
    required this.hasNoSpaces,
  });

  final bool hasMinLength;
  final bool hasLetter;
  final bool hasNumber;
  final bool hasSpecial;
  final bool hasNoSpaces;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleMessage(passed: hasMinLength, label: '8자 이상'),
        _RuleMessage(passed: hasLetter, label: '영문 포함'),
        _RuleMessage(passed: hasNumber, label: '숫자 포함'),
        _RuleMessage(passed: hasSpecial, label: '특수문자 포함'),
        _RuleMessage(passed: hasNoSpaces, label: '공백 없음'),
      ],
    );
  }
}

class _RuleMessage extends StatelessWidget {
  const _RuleMessage({
    required this.passed,
    required this.label,
    this.failedLabel,
    this.showFailed = true,
  });

  final bool passed;
  final String label;
  final String? failedLabel;
  final bool showFailed;

  @override
  Widget build(BuildContext context) {
    final color = passed
        ? _SignupScreenState._green
        : _SignupScreenState._error;
    final text = passed ? label : failedLabel ?? label;

    if (!passed && !showFailed) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.error_outline,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeChoice extends StatelessWidget {
  const _AgeChoice({required this.isOver14, required this.onChanged});

  final bool? isOver14;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChoiceTile(
          selected: isOver14 == true,
          icon: Icons.verified_user_outlined,
          title: '만 14세 이상입니다',
          onTap: () => onChanged(true),
        ),
        const SizedBox(height: 8),
        _ChoiceTile(
          selected: isOver14 == false,
          icon: Icons.supervisor_account_outlined,
          title: '만 14세 미만입니다',
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? _SignupScreenState._lightGreen
              : _SignupScreenState._background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _SignupScreenState._green : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: _SignupScreenState._green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _SignupScreenState._darkText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, color: _SignupScreenState._green),
          ],
        ),
      ),
    );
  }
}

class _GuardianConsentSection extends StatelessWidget {
  const _GuardianConsentSection({
    required this.nameController,
    required this.contactController,
    required this.relationController,
    required this.guardianAgreed,
    required this.onGuardianAgreedChanged,
    required this.onViewGuardianConsent,
  });

  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController relationController;
  final bool guardianAgreed;
  final ValueChanged<bool?> onGuardianAgreedChanged;
  final VoidCallback onViewGuardianConsent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _SignupScreenState._lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '법정대리인 동의',
            style: TextStyle(
              color: _SignupScreenState._darkText,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _SignupTextField(
            controller: nameController,
            label: '보호자 이름',
            icon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _SignupTextField(
            controller: contactController,
            label: '보호자 연락처',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          _SignupTextField(
            controller: relationController,
            label: '보호자와의 관계',
            icon: Icons.family_restroom_outlined,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 8),
          _AgreementTile(
            value: guardianAgreed,
            title: '법정대리인 동의 확인',
            onChanged: onGuardianAgreedChanged,
            onView: onViewGuardianConsent,
          ),
          const SizedBox(height: 6),
          const Text(
            '실제 보호자 인증은 추후 서버와 본인인증 서비스 연동 시 구현됩니다.',
            style: TextStyle(
              color: _SignupScreenState._grayText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegionButton extends StatelessWidget {
  const _RegionButton({
    required this.text,
    required this.hasSelection,
    required this.onPressed,
  });

  final String text;
  final bool hasSelection;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        hasSelection ? Icons.location_on : Icons.add_location_alt_outlined,
      ),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _SignupScreenState._green,
        side: const BorderSide(color: _SignupScreenState._green),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _RegionList extends StatelessWidget {
  const _RegionList({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    this.emptyText,
  });

  final String title;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String> onSelected;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _SignupScreenState._grayText,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    emptyText ?? '선택 항목이 없습니다.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _SignupScreenState._grayText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item == selectedItem;
                    return InkWell(
                      onTap: () => onSelected(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? _SignupScreenState._lightGreen
                              : _SignupScreenState._background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? _SignupScreenState._green
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: selected
                                ? _SignupScreenState._green
                                : _SignupScreenState._darkText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.value,
    required this.title,
    required this.onChanged,
    required this.onView,
  });

  final bool value;
  final String title;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: _SignupScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: _SignupScreenState._green,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _SignupScreenState._darkText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.article_outlined, size: 18),
            label: const Text('보기'),
          ),
          const SizedBox(width: 4),
        ],
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
