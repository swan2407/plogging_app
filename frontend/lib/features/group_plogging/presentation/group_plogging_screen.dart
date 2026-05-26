import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';

class GroupPloggingScreen extends StatelessWidget {
  const GroupPloggingScreen({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  static const _events = [
    _GroupEvent(
      title: '한강공원 아침 플로깅',
      area: '서울 마포구',
      date: '5월 28일',
      time: '오전 8:00',
      status: '모집중',
      participants: '12/20명',
      startPlace: '망원한강공원 2번 출구',
      supplies: '장갑, 텀블러, 편한 운동화',
    ),
    _GroupEvent(
      title: '도심 골목 정화 모임',
      area: '서울 종로구',
      date: '5월 30일',
      time: '오후 6:30',
      status: '마감임박',
      participants: '17/18명',
      startPlace: '종각역 4번 출구',
      supplies: '집게, 개인 물병',
    ),
    _GroupEvent(
      title: '주말 공원 가족 플로깅',
      area: '경기 성남시',
      date: '6월 1일',
      time: '오전 10:00',
      status: '모집중',
      participants: '8/15명',
      startPlace: '중앙공원 시계탑 앞',
      supplies: '모자, 장갑, 작은 가방',
    ),
    _GroupEvent(
      title: '퇴근길 하천 산책 플로깅',
      area: '인천 연수구',
      date: '6월 3일',
      time: '오후 7:00',
      status: '대기접수',
      participants: '20/20명',
      startPlace: '송도 센트럴파크 입구',
      supplies: '야간 안전등, 장갑',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreatePressed(context),
        backgroundColor: _green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '단체 플로깅 만들기',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
          children: [
            const _SummaryCard(),
            const SizedBox(height: 18),
            const _FilterArea(),
            const SizedBox(height: 18),
            const Text(
              '모집 중인 단체 플로깅',
              style: TextStyle(
                color: _darkText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final event in _events) ...[
              _GroupEventCard(
                event: event,
                onJoinPressed: () => _handleJoinPressed(context, event),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  static void _handleJoinPressed(BuildContext context, _GroupEvent event) {
    if (!mockAuthController.isLoggedIn) {
      _openLoginScreen(context);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('참여 신청 완료'),
          content: Text('${event.title}에 참여 신청했습니다.'),
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

  static void _handleCreatePressed(BuildContext context) {
    if (!mockAuthController.isLoggedIn) {
      _openLoginScreen(context);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('단체 플로깅 만들기'),
          content: const Text('단체 플로깅 생성 화면은 준비 중입니다.'),
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

  static void _openLoginScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(popAfterLogin: true),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return _GreenCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: GroupPloggingScreen._lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: GroupPloggingScreen._green,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께하는 플로깅',
                  style: TextStyle(
                    color: GroupPloggingScreen._darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '가까운 이웃과 일정을 맞춰 동네를 깨끗하게 걸어보세요.',
                  style: TextStyle(
                    color: GroupPloggingScreen._grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
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

class _FilterArea extends StatelessWidget {
  const _FilterArea();

  @override
  Widget build(BuildContext context) {
    return const _GreenCard(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _FilterChip(label: '지역 필터', value: '전체 지역', icon: Icons.place),
          _FilterChip(
            label: '날짜 필터',
            value: '가까운 일정',
            icon: Icons.calendar_month,
          ),
          _FilterChip(
            label: '모집 상태 필터',
            value: '모집 가능',
            icon: Icons.tune,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: GroupPloggingScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GroupPloggingScreen._green, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: GroupPloggingScreen._grayText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: GroupPloggingScreen._darkText,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupEventCard extends StatelessWidget {
  const _GroupEventCard({required this.event, required this.onJoinPressed});

  final _GroupEvent event;
  final VoidCallback onJoinPressed;

  @override
  Widget build(BuildContext context) {
    return _GreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    color: GroupPloggingScreen._darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusBadge(status: event.status),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.place_outlined, label: '지역', value: event.area),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: '날짜',
            value: event.date,
          ),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: '시간',
            value: event.time,
          ),
          _InfoRow(
            icon: Icons.people_outline,
            label: '참여 인원',
            value: event.participants,
          ),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: '출발 장소',
            value: event.startPlace,
          ),
          _InfoRow(
            icon: Icons.backpack_outlined,
            label: '준비물',
            value: event.supplies,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onJoinPressed,
              style: FilledButton.styleFrom(
                backgroundColor: GroupPloggingScreen._green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '참여하기',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: GroupPloggingScreen._lightGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: GroupPloggingScreen._green,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GroupPloggingScreen._green, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: GroupPloggingScreen._grayText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: GroupPloggingScreen._darkText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GreenCard extends StatelessWidget {
  const _GreenCard({required this.child});

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

class _GroupEvent {
  const _GroupEvent({
    required this.title,
    required this.area,
    required this.date,
    required this.time,
    required this.status,
    required this.participants,
    required this.startPlace,
    required this.supplies,
  });

  final String title;
  final String area;
  final String date;
  final String time;
  final String status;
  final String participants;
  final String startPlace;
  final String supplies;
}
