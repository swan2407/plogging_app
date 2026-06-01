import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../model/group_event.dart';

class GroupPloggingDetailScreen extends StatelessWidget {
  const GroupPloggingDetailScreen({super.key, required this.event});

  final GroupEvent event;

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
        title: const Text('단체 플로깅 상세'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _DetailHeader(event: event),
            const SizedBox(height: 16),
            _DetailCard(
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.place_outlined,
                    label: '지역',
                    value: event.area,
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: '날짜',
                    value: event.date,
                  ),
                  _DetailRow(
                    icon: Icons.play_circle_outline,
                    label: '시작 시간',
                    value: event.startTime,
                  ),
                  _DetailRow(
                    icon: Icons.stop_circle_outlined,
                    label: '종료 시간',
                    value: event.endTime,
                  ),
                  _DetailRow(
                    icon: Icons.campaign_outlined,
                    label: '모집 상태',
                    value: event.status,
                  ),
                  _DetailRow(
                    icon: Icons.people_outline,
                    label: '참여 인원',
                    value: event.participantText,
                  ),
                  _DetailRow(
                    icon: Icons.person_outline,
                    label: '인솔자',
                    value: event.leaderNickname,
                  ),
                  _DetailRow(
                    icon: Icons.flag_outlined,
                    label: '출발 장소',
                    value: event.startPlace,
                  ),
                  _DetailRow(
                    icon: Icons.backpack_outlined,
                    label: '준비물',
                    value: event.supplies,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _DetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(title: '상세 설명'),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: _darkText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _MapPlaceholder(),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => _handleJoin(context),
                icon: const Icon(Icons.how_to_reg_outlined),
                label: const Text(
                  '참여하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
    );
  }

  void _handleJoin(BuildContext context) {
    if (!mockAuthController.isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(popAfterLogin: true),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('참여 완료'),
          content: const Text('단체 플로깅 참여가 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.event});

  final GroupEvent event;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: GroupPloggingDetailScreen._lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: GroupPloggingDetailScreen._green,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: GroupPloggingDetailScreen._darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${event.area} · ${event.date}',
                  style: const TextStyle(
                    color: GroupPloggingDetailScreen._grayText,
                    fontSize: 14,
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

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: GroupPloggingDetailScreen._lightGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              color: GroupPloggingDetailScreen._green,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              '모임 장소 지도',
              style: TextStyle(
                color: GroupPloggingDetailScreen._darkText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '지도 연동은 추후 구현됩니다.',
              style: TextStyle(
                color: GroupPloggingDetailScreen._grayText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
        color: GroupPloggingDetailScreen._darkText,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GroupPloggingDetailScreen._green, size: 19),
          const SizedBox(width: 9),
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: const TextStyle(
                color: GroupPloggingDetailScreen._grayText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: GroupPloggingDetailScreen._darkText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

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
