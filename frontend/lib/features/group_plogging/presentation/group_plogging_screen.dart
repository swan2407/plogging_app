import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/group_event_api_service.dart';
import '../model/group_event.dart';
import 'create_group_plogging_screen.dart';
import 'group_plogging_detail_screen.dart';

class GroupPloggingScreen extends StatefulWidget {
  const GroupPloggingScreen({super.key});

  static const green = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFFE8F5E9);
  static const background = Color(0xFFF6F7F5);
  static const darkText = Color(0xFF1F2937);
  static const grayText = Color(0xFF6B7280);

  @override
  State<GroupPloggingScreen> createState() => _GroupPloggingScreenState();
}

class _GroupPloggingScreenState extends State<GroupPloggingScreen> {
  final _apiService = GroupEventApiService();
  List<GroupEvent> _events = const [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _joiningEventId;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final events = await _apiService.fetchGroupEvents();
      if (mounted) {
        setState(() => _events = events);
      }
    } on GroupEventApiException catch (exception) {
      debugPrint('Group events load failed: $exception');
      if (mounted) {
        setState(() {
          _events = const [];
          _errorMessage = exception.message;
        });
      }
    } catch (error) {
      debugPrint('Group events load failed: $error');
      if (mounted) {
        setState(() {
          _events = const [];
          _errorMessage = '서버에서 단체 플로깅 목록을 불러오지 못했습니다.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroupPloggingScreen.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreatePressed,
        backgroundColor: GroupPloggingScreen.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '단체 플로깅 만들기',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 104),
        children: [
          const _SummaryCard(),
          const SizedBox(height: 18),
          const _FilterArea(),
          if (_errorMessage != null) ...[
            const SizedBox(height: 18),
            _LoadErrorCard(message: _errorMessage!, onRetry: _loadEvents),
          ],
          const SizedBox(height: 18),
          const Text(
            '모집 중인 단체 플로깅',
            style: TextStyle(
              color: GroupPloggingScreen.darkText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (_events.isEmpty)
            const _EmptyEventCard()
          else
            for (final event in _events) ...[
              _GroupEventCard(
                event: event,
                isJoining: _joiningEventId == event.id,
                onTap: () => _openDetailScreen(event),
                onJoinPressed: () => _handleJoinPressed(event),
              ),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }

  Future<void> _openDetailScreen(GroupEvent event) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GroupPloggingDetailScreen(event: event),
      ),
    );
    await _loadEvents();
  }

  Future<void> _handleJoinPressed(GroupEvent event) async {
    if (!mockAuthController.isLoggedIn) {
      _openLoginScreen();
      return;
    }

    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      _showMessage('로그인이 필요합니다.');
      return;
    }

    setState(() => _joiningEventId = event.id);
    try {
      final updated = await _apiService.joinGroupEvent(event.id, accessToken);
      if (!mounted) {
        return;
      }
      setState(() {
        _events = _events
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
      _showMessage('단체 플로깅 참여가 완료되었습니다.');
    } on GroupEventApiException catch (exception) {
      debugPrint('Group event join failed: $exception');
      if (mounted) {
        _showMessage(exception.message);
      }
    } catch (error) {
      debugPrint('Group event join failed: $error');
      if (mounted) {
        _showMessage('서버에 연결할 수 없습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _joiningEventId = null);
      }
    }
  }

  Future<void> _handleCreatePressed() async {
    if (!mockAuthController.isLoggedIn) {
      _openLoginScreen();
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (context) => const CreateGroupPloggingScreen(),
      ),
    );
    if (created == true) {
      await _loadEvents();
    }
  }

  void _openLoginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(popAfterLogin: true),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LoadErrorCard extends StatelessWidget {
  const _LoadErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _GreenCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: GroupPloggingScreen.grayText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

class _EmptyEventCard extends StatelessWidget {
  const _EmptyEventCard();

  @override
  Widget build(BuildContext context) {
    return const _GreenCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          '등록된 단체 플로깅이 없습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: GroupPloggingScreen.grayText,
            fontWeight: FontWeight.w800,
          ),
        ),
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
    required this.isJoining,
    required this.onTap,
    required this.onJoinPressed,
  });

  final GroupEvent event;
  final bool isJoining;
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
                  _StatusBadge(status: event.statusLabel),
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
                value: event.suppliesText,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: isJoining ? null : onJoinPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: GroupPloggingScreen.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isJoining ? '참여 중...' : '참여하기',
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
