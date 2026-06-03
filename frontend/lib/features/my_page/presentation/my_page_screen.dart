import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../data/mock_my_page_data.dart';
import '../model/my_page_models.dart';
import '../../plogging/data/mock_activity_record_store.dart';
import '../../plogging/model/activity_record.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key, this.popAfterLogout = false});

  final bool popAfterLogout;

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
            const _PageHeader(),
            const SizedBox(height: 18),
            const _ProfileSummaryCard(),
            const SizedBox(height: 18),
            const _QuickStatsGrid(),
            const SizedBox(height: 26),
            const _ActivityRecordsSection(),
            const SizedBox(height: 26),
            const _JoinedGroupPloggingSection(),
            const SizedBox(height: 26),
            const _MyPostsSection(),
            const SizedBox(height: 26),
            _SettingsActionsSection(onLogout: () => _logout(context)),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    mockAuthController.logout();

    if (popAfterLogout && Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '마이페이지',
          style: TextStyle(
            color: MyPageScreen._darkText,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '나의 플로깅 기록과 활동을 모아봤어요.',
          style: TextStyle(
            color: MyPageScreen._grayText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    return const _MyPageCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: MyPageScreen._lightGreen,
                child: Icon(
                  Icons.person_outline,
                  color: MyPageScreen._green,
                  size: 38,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '초록걸음',
                      style: TextStyle(
                        color: MyPageScreen._darkText,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: MyPageScreen._green,
                          size: 17,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '서울 마포구',
                          style: TextStyle(
                            color: MyPageScreen._grayText,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ProfileMetric(value: '28회', label: '총 플로깅'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ProfileMetric(value: '74.6km', label: '총 거리'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ProfileMetric(value: '156개', label: '쓰레기 인증'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: MyPageScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MyPageScreen._green,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MyPageScreen._grayText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  const _QuickStatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.62,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final stat in mockMyPageStats) _QuickStatCard(stat: stat),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({required this.stat});

  final MyPageStat stat;

  @override
  Widget build(BuildContext context) {
    return _MyPageCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: MyPageScreen._lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(stat.icon, color: MyPageScreen._green, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyPageScreen._darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyPageScreen._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
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

class _ActivityRecordsSection extends StatelessWidget {
  const _ActivityRecordsSection();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ActivityRecord>>(
      valueListenable: mockActivityRecordStore.recordsListenable,
      builder: (context, records, child) {
        return _MyPageSection(
          title: '나의 활동 기록',
          icon: Icons.directions_walk_outlined,
          children: records.isEmpty
              ? const [_EmptyActivityRecordState()]
              : [
                  for (final record in records)
                    _ActivityRecordTile(record: record),
                ],
        );
      },
    );
  }
}

class _ActivityRecordTile extends StatelessWidget {
  const _ActivityRecordTile({required this.record});

  final ActivityRecord record;

  @override
  Widget build(BuildContext context) {
    return _ListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.date,
                  style: const TextStyle(
                    color: MyPageScreen._darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(label: record.type),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: MyPageScreen._green,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  record.region,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyPageScreen._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InlineMetric(
                  icon: Icons.route_outlined,
                  label: record.distance,
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  icon: Icons.schedule_outlined,
                  label: record.duration,
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  icon: Icons.delete_outline,
                  label: '${record.trashCertificationCount}개',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.summary,
            style: const TextStyle(
              color: MyPageScreen._darkText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivityRecordState extends StatelessWidget {
  const _EmptyActivityRecordState();

  @override
  Widget build(BuildContext context) {
    return const _ListSurface(
      child: Row(
        children: [
          Icon(Icons.info_outline, color: MyPageScreen._green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '아직 저장된 플로깅 기록이 없어요.',
              style: TextStyle(
                color: MyPageScreen._grayText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedGroupPloggingSection extends StatelessWidget {
  const _JoinedGroupPloggingSection();

  @override
  Widget build(BuildContext context) {
    return _MyPageSection(
      title: '참여한 단체 플로깅',
      icon: Icons.groups_outlined,
      children: [
        for (final item in mockJoinedGroupPloggings)
          _GroupPloggingTile(item: item),
      ],
    );
  }
}

class _GroupPloggingTile extends StatelessWidget {
  const _GroupPloggingTile({required this.item});

  final JoinedGroupPlogging item;

  @override
  Widget build(BuildContext context) {
    return _ListSurface(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: MyPageScreen._green,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyPageScreen._darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.date} · ${item.region}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyPageScreen._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusPill(label: item.status),
        ],
      ),
    );
  }
}

class _MyPostsSection extends StatelessWidget {
  const _MyPostsSection();

  @override
  Widget build(BuildContext context) {
    return _MyPageSection(
      title: '내가 쓴 글',
      icon: Icons.article_outlined,
      children: [for (final post in mockMyPagePosts) _MyPostTile(post: post)],
    );
  }
}

class _MyPostTile extends StatelessWidget {
  const _MyPostTile({required this.post});

  final MyPagePost post;

  @override
  Widget build(BuildContext context) {
    return _ListSurface(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MyPageScreen._darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.createdDate,
                  style: const TextStyle(
                    color: MyPageScreen._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _InlineMetric(icon: Icons.favorite_border, label: '${post.likes}'),
          const SizedBox(width: 10),
          _InlineMetric(
            icon: Icons.chat_bubble_outline,
            label: '${post.comments}',
          ),
        ],
      ),
    );
  }
}

class _SettingsActionsSection extends StatelessWidget {
  const _SettingsActionsSection({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return _MyPageSection(
      title: '설정 및 활동',
      icon: Icons.settings_outlined,
      children: [
        const _ActionTile(icon: Icons.edit_outlined, label: '내 정보 수정'),
        const _ActionTile(icon: Icons.campaign_outlined, label: '공지사항'),
        const _ActionTile(icon: Icons.tune_outlined, label: '설정'),
        _ActionTile(
          icon: Icons.logout,
          label: '로그아웃',
          onTap: onLogout,
          isDestructive: true,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFB91C1C) : MyPageScreen._green;

    return Material(
      color: MyPageScreen._background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDestructive
                        ? const Color(0xFF991B1B)
                        : MyPageScreen._darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDestructive ? color : MyPageScreen._grayText,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPageSection extends StatelessWidget {
  const _MyPageSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _MyPageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, title: title),
          const SizedBox(height: 14),
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MyPageCard extends StatelessWidget {
  const _MyPageCard({
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
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: MyPageScreen._lightGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: MyPageScreen._green, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: MyPageScreen._darkText,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ListSurface extends StatelessWidget {
  const _ListSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyPageScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: MyPageScreen._green, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MyPageScreen._grayText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: MyPageScreen._lightGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: MyPageScreen._green,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
