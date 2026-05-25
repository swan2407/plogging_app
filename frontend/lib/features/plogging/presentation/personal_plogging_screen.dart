import 'package:flutter/material.dart';

class PersonalPloggingScreen extends StatefulWidget {
  const PersonalPloggingScreen({super.key});

  @override
  State<PersonalPloggingScreen> createState() => _PersonalPloggingScreenState();
}

class _PersonalPloggingScreenState extends State<PersonalPloggingScreen> {
  bool _isStarted = false;
  bool _isPaused = false;
  int _trashCount = 0;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  void _startPlogging() {
    setState(() {
      _isStarted = true;
      _isPaused = false;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _finishPlogging() {
    setState(() {
      _isStarted = false;
      _isPaused = false;
      _trashCount = 0;
    });
  }

  void _showTrashRegistrationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _TrashRegistrationSheet(
          onRegister: () {
            setState(() {
              _trashCount++;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const _ScreenHeader(),
            const SizedBox(height: 18),
            const _MapPlaceholderCard(),
            const SizedBox(height: 18),
            if (_isStarted) ...[
              _StatusCard(isPaused: _isPaused, trashCount: _trashCount),
              const SizedBox(height: 18),
              _ActionButtons(
                isPaused: _isPaused,
                onPausePressed: _togglePause,
                onTrashPressed: _showTrashRegistrationSheet,
                onFinishPressed: _finishPlogging,
              ),
            ] else
              _StartButton(onPressed: _startPlogging),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '개인 플로깅',
          style: TextStyle(
            color: _PersonalPloggingScreenState._darkText,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '가볍게 시작하고 활동 기록을 남겨보세요.',
          style: TextStyle(
            color: _PersonalPloggingScreenState._grayText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MapPlaceholderCard extends StatelessWidget {
  const _MapPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _PersonalPloggingScreenState._lightGreen,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              color: _PersonalPloggingScreenState._green,
              size: 46,
            ),
            SizedBox(height: 10),
            Text(
              '지도 영역',
              style: TextStyle(
                color: _PersonalPloggingScreenState._green,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '실제 지도와 GPS는 추후 연결 예정',
              style: TextStyle(
                color: _PersonalPloggingScreenState._grayText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.isPaused, required this.trashCount});

  final bool isPaused;
  final int trashCount;

  @override
  Widget build(BuildContext context) {
    return _PloggingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _PersonalPloggingScreenState._lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaused ? Icons.pause : Icons.directions_walk,
                  color: _PersonalPloggingScreenState._green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isPaused ? '일시정지 중' : '플로깅 진행 중',
                  style: const TextStyle(
                    color: _PersonalPloggingScreenState._darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: _StatusMetric(
                  icon: Icons.schedule,
                  value: '18분',
                  label: '활동 시간',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _StatusMetric(
                  icon: Icons.route_outlined,
                  value: '1.2 km',
                  label: '이동 거리',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatusMetric(
                  icon: Icons.delete_outline,
                  value: '$trashCount개',
                  label: '수거한 쓰레기',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: _PersonalPloggingScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: _PersonalPloggingScreenState._green, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _PersonalPloggingScreenState._darkText,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _PersonalPloggingScreenState._grayText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.play_arrow_rounded, size: 30),
        label: const Text(
          '플로깅 시작하기',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _PersonalPloggingScreenState._green,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: _PersonalPloggingScreenState._green.withValues(
            alpha: 0.28,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isPaused,
    required this.onPausePressed,
    required this.onTrashPressed,
    required this.onFinishPressed,
  });

  final bool isPaused;
  final VoidCallback onPausePressed;
  final VoidCallback onTrashPressed;
  final VoidCallback onFinishPressed;

  @override
  Widget build(BuildContext context) {
    return _PloggingCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPausePressed,
                  icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                  label: Text(isPaused ? '재개' : '일시정지'),
                  style: _secondaryButtonStyle(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTrashPressed,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('쓰레기 등록'),
                  style: _secondaryButtonStyle(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: onFinishPressed,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('종료'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB91C1C),
                side: const BorderSide(color: Color(0xFFB91C1C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: _PersonalPloggingScreenState._green,
      side: const BorderSide(color: _PersonalPloggingScreenState._green),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );
  }
}

class _TrashRegistrationSheet extends StatefulWidget {
  const _TrashRegistrationSheet({required this.onRegister});

  final VoidCallback onRegister;

  @override
  State<_TrashRegistrationSheet> createState() =>
      _TrashRegistrationSheetState();
}

class _TrashRegistrationSheetState extends State<_TrashRegistrationSheet> {
  String? _trashType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '쓰레기 인증 등록',
              style: TextStyle(
                color: _PersonalPloggingScreenState._darkText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            const _PhotoCertificationCard(),
            const SizedBox(height: 22),
            const _OptionalSectionTitle(),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _trashType,
              decoration: _inputDecoration('쓰레기 종류 선택'),
              hint: const Text('선택'),
              items: const [
                DropdownMenuItem(value: '플라스틱', child: Text('플라스틱')),
                DropdownMenuItem(value: '캔', child: Text('캔')),
                DropdownMenuItem(value: '유리', child: Text('유리')),
                DropdownMenuItem(value: '종이', child: Text('종이')),
                DropdownMenuItem(value: '일반 쓰레기', child: Text('일반 쓰레기')),
              ],
              onChanged: (value) {
                setState(() {
                  _trashType = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('개수 선택'),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('예상 무게 선택'),
            ),
            const SizedBox(height: 12),
            TextField(maxLines: 3, decoration: _inputDecoration('메모 선택')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () {
                  widget.onRegister();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('쓰레기 인증을 등록했습니다.')),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _PersonalPloggingScreenState._green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '인증 등록하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: '$label (선택)',
      filled: true,
      fillColor: _PersonalPloggingScreenState._background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _PhotoCertificationCard extends StatelessWidget {
  const _PhotoCertificationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _PersonalPloggingScreenState._lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _PersonalPloggingScreenState._green),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_a_photo_outlined,
                  color: _PersonalPloggingScreenState._green,
                  size: 42,
                ),
                SizedBox(height: 10),
                Text(
                  '사진으로 간단히 인증해 주세요',
                  style: TextStyle(
                    color: _PersonalPloggingScreenState._darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('카메라 연결은 추후 제공됩니다.')),
                );
              },
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('사진 추가'),
              style: FilledButton.styleFrom(
                backgroundColor: _PersonalPloggingScreenState._green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionalSectionTitle extends StatelessWidget {
  const _OptionalSectionTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '추가 정보',
          style: TextStyle(
            color: _PersonalPloggingScreenState._darkText,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _PersonalPloggingScreenState._lightGreen,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            '선택',
            style: TextStyle(
              color: _PersonalPloggingScreenState._green,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PloggingCard extends StatelessWidget {
  const _PloggingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
