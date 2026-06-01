import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/mock_group_events.dart';
import '../model/group_event.dart';
import 'create_group_plogging_screen.dart';
import 'group_plogging_detail_screen.dart';

class GroupPloggingScreen extends StatelessWidget {
  const GroupPloggingScreen({super.key});

  static const green = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);
  static const background = Color(0xFFF6F7F5);
  static const darkText = Color(0xFF1F2937);
  static const grayText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleCreatePressed(context),
        backgroundColor: green,
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
                color: darkText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final event in mockGroupEvents) ...[
              _GroupEventCard(
                event: event,
                onTap: () => _openDetailScreen(context, event),
                onJoinPressed: () => _handleJoinPressed(context, event),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  static void _openDetailScreen(BuildContext context, GroupEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GroupPloggingDetailScreen(event: event),
      ),
    );
  }

  static void _handleJoinPressed(BuildContext context, GroupEvent event) {
    if (!mockAuthController.isLoggedIn) {
      _openLoginScreen(context);
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('참여 완료'),
          content: Text('${event.title} 참여가 완료되었습니다.'),
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

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const CreateGroupPloggingScreen(),
      ),
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
    return const _GreenCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: Icons.groups_outlined),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께하는 플로깅',
                  style: TextStyle(
                    color: GroupPloggingScreen.darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '가까운 이웃과 일정을 맞춰 동네를 깨끗하게 걸어보세요.',
                  style: TextStyle(
                    color: GroupPloggingScreen.grayText,
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
          _FilterChip(label: '모집 상태 필터', value: '모집 가능', icon: Icons.tune),
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
        color: GroupPloggingScreen.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GroupPloggingScreen.green, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: GroupPloggingScreen.grayText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: GroupPloggingScreen.darkText,
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
  const _GroupEventCard({
    required this.event,
    required this.onTap,
    required this.onJoinPressed,
  });

  final GroupEvent event;
  final VoidCallback onTap;
  final VoidCallback onJoinPressed;

  @override
  Widget build(BuildContext context) {
    return _GreenCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
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
                        color: GroupPloggingScreen.darkText,
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
              _InfoRow(
                icon: Icons.place_outlined,
                label: '지역',
                value: event.area,
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: '날짜',
                value: event.date,
              ),
              _InfoRow(
                icon: Icons.schedule_outlined,
                label: '시간',
                value: '${event.startTime} - ${event.endTime}',
              ),
              _InfoRow(
                icon: Icons.people_outline,
                label: '참여 인원',
                value: event.participantText,
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
                    backgroundColor: GroupPloggingScreen.green,
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
        ),
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
        color: GroupPloggingScreen.lightGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: GroupPloggingScreen.green,
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
          Icon(icon, color: GroupPloggingScreen.green, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                color: GroupPloggingScreen.grayText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: GroupPloggingScreen.darkText,
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

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: GroupPloggingScreen.lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: GroupPloggingScreen.green, size: 26),
    );
  }
}

class _GreenCard extends StatelessWidget {
  const _GreenCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
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
