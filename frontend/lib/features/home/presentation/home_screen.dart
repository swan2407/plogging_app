import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _GreetingHeader(onLoginPressed: onLoginPressed),
            const SizedBox(height: 18),
            const _SearchBar(),
            const SizedBox(height: 18),
            const _TodayPloggingCard(),
            const SizedBox(height: 18),
            const _StartPloggingButton(),
            const SizedBox(height: 26),
            const _ScheduleSection(),
            const SizedBox(height: 26),
            const _GroupPreviewSection(),
            const SizedBox(height: 26),
            const _CommunitySection(),
          ],
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요',
                style: TextStyle(
                  color: HomeScreen._grayText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '오늘도 동네를 깨끗하게 걸어볼까요?',
                style: TextStyle(
                  color: HomeScreen._darkText,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        ValueListenableBuilder<bool>(
          valueListenable: mockAuthController,
          builder: (context, isLoggedIn, child) {
            if (isLoggedIn) {
              return const SizedBox.shrink();
            }

            return FilledButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('로그인'),
              style: FilledButton.styleFrom(
                backgroundColor: HomeScreen._green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: const [
          Icon(Icons.search, color: HomeScreen._green),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '지역 검색하기',
              style: TextStyle(
                color: HomeScreen._grayText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.tune, color: HomeScreen._grayText, size: 20),
        ],
      ),
    );
  }
}

class _TodayPloggingCard extends StatelessWidget {
  const _TodayPloggingCard();

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(
            icon: Icons.eco_outlined,
            title: '오늘의 플로깅',
            actionText: '5월 25일',
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.directions_walk,
                  value: '2.4 km',
                  label: '추천 거리',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: Icons.delete_outline,
                  value: '12개',
                  label: '목표 수거',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  icon: Icons.schedule,
                  value: '35분',
                  label: '예상 시간',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            '가까운 공원 코스를 따라 가볍게 시작해보세요.',
            style: TextStyle(
              color: HomeScreen._grayText,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartPloggingButton extends StatelessWidget {
  const _StartPloggingButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.play_arrow_rounded, size: 30),
        label: const Text(
          '개인 플로깅 시작하기',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: HomeScreen._green,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: HomeScreen._green.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  @override
  Widget build(BuildContext context) {
    return const _DashboardSection(
      title: '플로깅 일정',
      icon: Icons.calendar_month_outlined,
      children: [
        _ListItem(
          icon: Icons.park_outlined,
          title: '한강 산책로 플로깅',
          subtitle: '오늘 오후 6:30 · 마포구',
        ),
        SizedBox(height: 10),
        _ListItem(
          icon: Icons.local_florist_outlined,
          title: '주말 공원 정리',
          subtitle: '토요일 오전 9:00 · 서대문구',
        ),
      ],
    );
  }
}

class _GroupPreviewSection extends StatelessWidget {
  const _GroupPreviewSection();

  @override
  Widget build(BuildContext context) {
    return const _DashboardSection(
      title: '주변 단체 플로깅',
      icon: Icons.groups_outlined,
      children: [
        _ListItem(
          icon: Icons.location_on_outlined,
          title: '연남동 골목 플로깅',
          subtitle: '8명 참여 예정 · 1.2km 거리',
        ),
        SizedBox(height: 10),
        _ListItem(
          icon: Icons.location_on_outlined,
          title: '홍제천 환경 모임',
          subtitle: '모집중 12/20 · 내일 오후 7:00',
        ),
      ],
    );
  }
}

class _CommunitySection extends StatelessWidget {
  const _CommunitySection();

  @override
  Widget build(BuildContext context) {
    return const _DashboardSection(
      title: '최근 커뮤니티 글',
      icon: Icons.chat_bubble_outline,
      children: [
        _ListItem(
          icon: Icons.article_outlined,
          title: '오늘 수거한 캔이 정말 많았어요',
          subtitle: '마포구 · 댓글 3개',
        ),
        SizedBox(height: 10),
        _ListItem(
          icon: Icons.article_outlined,
          title: '처음 플로깅을 시작하는 분들께',
          subtitle: '서대문구 · 좋아요 18개',
        ),
      ],
    );
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, title: title, actionText: '더보기'),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.actionText,
  });

  final IconData icon;
  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: HomeScreen._lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: HomeScreen._green, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: HomeScreen._darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          actionText,
          style: const TextStyle(
            color: HomeScreen._green,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: HomeScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: HomeScreen._green, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomeScreen._darkText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomeScreen._grayText,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HomeScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: HomeScreen._green, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomeScreen._darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomeScreen._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: HomeScreen._grayText,
            size: 22,
          ),
        ],
      ),
    );
  }
}
