import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../data/mock_my_page_data.dart';
import '../data/my_page_api_service.dart';
import '../model/my_page_models.dart';
import '../../plogging/data/mock_activity_record_store.dart';
import '../../plogging/data/plogging_api_service.dart';
import '../../plogging/model/activity_record.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key, this.popAfterLogout = false});

  final bool popAfterLogout;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  static String formatDistance(int meters) {
    if (meters < 1000) {
      return '${meters}m';
    }
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return remainingMinutes > 0 ? '$hours시간 $remainingMinutes분' : '$hours시간';
    }
    return '$minutes분';
  }

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
            const _ActivitySummarySection(),
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

class _ActivitySummarySection extends StatefulWidget {
  const _ActivitySummarySection();

  @override
  State<_ActivitySummarySection> createState() =>
      _ActivitySummarySectionState();
}

class _ActivitySummarySectionState extends State<_ActivitySummarySection> {
  final _myPageApiService = MyPageApiService();
  late Future<_ActivitySummaryResult> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _fetchSummary();
  }

  Future<_ActivitySummaryResult> _fetchSummary() async {
    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      return const _ActivitySummaryResult(
        fallbackMessage: '로그인이 필요합니다. 기존 통계를 표시합니다.',
      );
    }

    try {
      return _ActivitySummaryResult(
        summary: await _myPageApiService.fetchMyActivitySummary(accessToken),
      );
    } on MyPageApiException catch (exception) {
      return _ActivitySummaryResult(
        fallbackMessage: '${exception.message} 기존 통계를 표시합니다.',
      );
    } catch (_) {
      return const _ActivitySummaryResult(
        fallbackMessage: '활동 통계를 불러오지 못했습니다. 기존 통계를 표시합니다.',
      );
    }
  }

  void _refresh() {
    setState(() {
      _summaryFuture = _fetchSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ActivitySummaryResult>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            children: [
              _ProfileSummaryCard(summary: null),
              SizedBox(height: 18),
              _QuickStatsGrid(summary: null),
            ],
          );
        }

        final result =
            snapshot.data ??
            const _ActivitySummaryResult(
              fallbackMessage: '활동 통계를 불러오지 못했습니다. 기존 통계를 표시합니다.',
            );

        return Column(
          children: [
            _ProfileSummaryCard(summary: result.summary),
            const SizedBox(height: 18),
            if (result.fallbackMessage != null) ...[
              _SummaryFallbackState(
                message: result.fallbackMessage!,
                onRetry: _refresh,
              ),
              const SizedBox(height: 18),
            ],
            _QuickStatsGrid(summary: result.summary),
          ],
        );
      },
    );
  }
}

class _ActivitySummaryResult {
  const _ActivitySummaryResult({this.summary, this.fallbackMessage});

  final UserActivitySummary? summary;
  final String? fallbackMessage;
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
  const _ProfileSummaryCard({required this.summary});

  final UserActivitySummary? summary;

  @override
  Widget build(BuildContext context) {
    final displayNickname =
        summary?.nickname ?? mockAuthController.nickname ?? '초록걸음';
    final totalPlogging = summary == null
        ? '28회'
        : '${summary!.totalPloggingCount}회';
    final totalDistance = summary == null
        ? '74.6km'
        : MyPageScreen.formatDistance(summary!.totalDistanceMeter);
    final trashCount = summary == null
        ? '156개'
        : '${summary!.totalTrashCertificationCount}개';

    return _MyPageCard(
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
                      displayNickname,
                      style: const TextStyle(
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
                child: _ProfileMetric(value: totalPlogging, label: '총 플로깅'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileMetric(value: totalDistance, label: '총 거리'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileMetric(value: trashCount, label: '쓰레기 인증'),
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
  const _QuickStatsGrid({required this.summary});

  final UserActivitySummary? summary;

  @override
  Widget build(BuildContext context) {
    final stats = summary == null
        ? mockMyPageStats
        : [
            MyPageStat(
              label: '총 플로깅 횟수',
              value: '${summary!.totalPloggingCount}회',
              icon: Icons.calendar_month_outlined,
            ),
            MyPageStat(
              label: '총 이동 거리',
              value: MyPageScreen.formatDistance(summary!.totalDistanceMeter),
              icon: Icons.route_outlined,
            ),
            MyPageStat(
              label: '총 활동 시간',
              value: MyPageScreen.formatDuration(summary!.totalDurationSeconds),
              icon: Icons.schedule_outlined,
            ),
            MyPageStat(
              label: '쓰레기 인증 수',
              value: '${summary!.totalTrashCertificationCount}개',
              icon: Icons.delete_outline,
            ),
          ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.62,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [for (final stat in stats) _QuickStatCard(stat: stat)],
    );
  }
}

class _SummaryFallbackState extends StatelessWidget {
  const _SummaryFallbackState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _ListSurface(
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: MyPageScreen._green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: MyPageScreen._grayText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            tooltip: '통계 새로고침',
            icon: const Icon(Icons.refresh, color: MyPageScreen._green),
          ),
        ],
      ),
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

class _ActivityRecordsSection extends StatefulWidget {
  const _ActivityRecordsSection();

  @override
  State<_ActivityRecordsSection> createState() =>
      _ActivityRecordsSectionState();
}

class _ActivityRecordsSectionState extends State<_ActivityRecordsSection> {
  final _ploggingApiService = PloggingApiService();
  late Future<_ActivityRecordsResult> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords();
  }

  Future<_ActivityRecordsResult> _fetchRecords() async {
    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      return _ActivityRecordsResult(
        records: mockActivityRecordStore.records,
        fallbackMessage: '로그인이 필요합니다.',
      );
    }

    try {
      final sessions = await _ploggingApiService.fetchMyPloggingSessions(
        accessToken,
      );
      return _ActivityRecordsResult(
        records: sessions.map((session) => session.toActivityRecord()).toList(),
      );
    } on PloggingApiException catch (exception) {
      return _ActivityRecordsResult(
        records: mockActivityRecordStore.records,
        fallbackMessage: '${exception.message} 기존 기록을 표시합니다.',
      );
    } catch (_) {
      return _ActivityRecordsResult(
        records: mockActivityRecordStore.records,
        fallbackMessage: '플로깅 기록을 불러오지 못했습니다. 기존 기록을 표시합니다.',
      );
    }
  }

  void _refresh() {
    setState(() {
      _recordsFuture = _fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ActivityRecordsResult>(
      future: _recordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _MyPageSection(
            title: '나의 활동 기록',
            icon: Icons.directions_walk_outlined,
            children: [_LoadingActivityRecordState()],
          );
        }

        final result =
            snapshot.data ??
            _ActivityRecordsResult(
              records: mockActivityRecordStore.records,
              fallbackMessage: '플로깅 기록을 불러오지 못했습니다. 기존 기록을 표시합니다.',
            );
        return _MyPageSection(
          title: '나의 활동 기록',
          icon: Icons.directions_walk_outlined,
          action: IconButton(
            onPressed: _refresh,
            tooltip: '활동 기록 새로고침',
            icon: const Icon(Icons.refresh, color: MyPageScreen._green),
          ),
          children: [
            if (result.fallbackMessage != null)
              _ActivityRecordsFallbackState(message: result.fallbackMessage!),
            if (result.records.isEmpty)
              const _EmptyActivityRecordState()
            else
              for (final record in result.records)
                _ActivityRecordTile(record: record),
          ],
        );
      },
    );
  }
}

class _ActivityRecordsResult {
  const _ActivityRecordsResult({required this.records, this.fallbackMessage});

  final List<ActivityRecord> records;
  final String? fallbackMessage;
}

class _ActivityRecordsFallbackState extends StatelessWidget {
  const _ActivityRecordsFallbackState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ListSurface(
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: MyPageScreen._green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: MyPageScreen._grayText,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingActivityRecordState extends StatelessWidget {
  const _LoadingActivityRecordState();

  @override
  Widget build(BuildContext context) {
    return const _ListSurface(
      child: Center(child: CircularProgressIndicator()),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatusPill(label: record.type),
                  const SizedBox(width: 6),
                  _StatusPill(label: record.status),
                ],
              ),
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
    this.action,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _MyPageCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: icon, title: title, action: action),
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
  const _SectionHeader({required this.icon, required this.title, this.action});

  final IconData icon;
  final String title;
  final Widget? action;

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
        ?action,
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
