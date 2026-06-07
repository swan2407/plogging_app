import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../../community/presentation/community_post_create_screen.dart';
import '../data/mock_activity_record_store.dart';
import '../data/mock_plogging_result_data.dart';
import '../data/plogging_api_service.dart';

class PloggingResultScreen extends StatefulWidget {
  const PloggingResultScreen({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  @override
  State<PloggingResultScreen> createState() => _PloggingResultScreenState();
}

class _PloggingResultScreenState extends State<PloggingResultScreen> {
  final _ploggingApiService = PloggingApiService();
  bool _isSaved = false;
  bool _isSaving = false;

  String get _activityDate {
    final now = DateTime.now();
    return '${now.year}.${_twoDigits(now.month)}.${_twoDigits(now.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  Future<void> _saveActivity() async {
    if (_isSaved || _isSaving) {
      return;
    }

    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      _showMessage('로그인이 필요합니다.');
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const LoginScreen(popAfterLogin: true),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final endAt = DateTime.now();
    final startAt = endAt.subtract(const Duration(minutes: 42));

    try {
      final session = await _ploggingApiService.saveCompletedPloggingSession(
        SaveCompletedPloggingRequest(
          startAt: startAt,
          endAt: endAt,
          durationSeconds: 2520,
          distanceMeter: 2400,
          regionSido: '경기',
          regionSigungu: '수원시',
          trashCertificationCount:
              mockPloggingResultSummary.trashCertificationCount,
          trashRecords: List.generate(
            mockPloggingResultSummary.trashCertificationCount,
            (index) => TrashRecordRequest(
              imageUrl: 'mock://trash/photo-${index + 1}.jpg',
              lat: 37.4200000,
              lng: 127.1260000,
              trashType: index == 0 ? 'PLASTIC' : null,
              count: index == 0 ? 1 : null,
              weightGram: index == 0 ? 120 : null,
              memo: index == 0 ? '플라스틱 병 수거' : null,
            ),
          ),
        ),
        accessToken,
      );
      mockActivityRecordStore.addRecord(session.toActivityRecord());

      if (mounted) {
        setState(() => _isSaved = true);
        _showMessage('활동 기록이 저장되었습니다.');
      }
    } on PloggingApiException catch (exception) {
      if (mounted) {
        _showMessage(exception.message);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('활동 기록 저장에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _shareToCommunity(BuildContext context) {
    final summary =
        '${mockPloggingResultSummary.duration} · '
        '${mockPloggingResultSummary.distance} · '
        '쓰레기 인증 ${mockPloggingResultSummary.trashCertifications} · '
        '${mockPloggingResultSummary.region}';

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CommunityPostCreateScreen(
          initialCategory: '활동 후기',
          initialTitle: '오늘 플로깅 완료!',
          initialContent:
              '오늘 ${mockPloggingResultSummary.region}에서 '
              '${mockPloggingResultSummary.duration} 동안 '
              '${mockPloggingResultSummary.distance}를 걸으며 플로깅을 완료했어요. '
              '쓰레기 인증은 ${mockPloggingResultSummary.trashCertifications} 남겼습니다.',
          initialRegion: mockPloggingResultSummary.region,
          linkedActivitySummary: summary,
          returnToRootOnSubmit: true,
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PloggingResultScreen._background,
      appBar: AppBar(
        title: const Text('플로깅 완료'),
        backgroundColor: PloggingResultScreen._background,
        foregroundColor: PloggingResultScreen._darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _CompletionHeader(),
            const SizedBox(height: 18),
            _SummaryCard(activityDate: _activityDate),
            const SizedBox(height: 18),
            const _TrashSummaryCard(),
            const SizedBox(height: 18),
            const _PhotoCertificationList(),
            const SizedBox(height: 18),
            const _SaveStatusCard(),
            const SizedBox(height: 20),
            _ResultActions(
              isSaved: _isSaved,
              isSaving: _isSaving,
              onSavePressed: _saveActivity,
              onSharePressed: () => _shareToCommunity(context),
              onHomePressed: () => _goHome(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionHeader extends StatelessWidget {
  const _CompletionHeader();

  @override
  Widget build(BuildContext context) {
    return const _ResultCard(
      child: Row(
        children: [
          _IconBadge(icon: Icons.check_circle_outline),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '플로깅 완료',
                  style: TextStyle(
                    color: PloggingResultScreen._darkText,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '오늘의 활동 요약을 확인해 보세요.',
                  style: TextStyle(
                    color: PloggingResultScreen._grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.activityDate});

  final String activityDate;

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.insights_outlined, title: '활동 요약'),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: '활동 날짜',
            value: activityDate,
          ),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: '활동 시간',
            value: mockPloggingResultSummary.duration,
          ),
          _InfoRow(
            icon: Icons.route_outlined,
            label: '이동 거리',
            value: mockPloggingResultSummary.distance,
          ),
          _InfoRow(
            icon: Icons.add_a_photo_outlined,
            label: '쓰레기 인증',
            value: mockPloggingResultSummary.trashCertifications,
          ),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: '활동 지역',
            value: mockPloggingResultSummary.region,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _TrashSummaryCard extends StatelessWidget {
  const _TrashSummaryCard();

  @override
  Widget build(BuildContext context) {
    return const _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(icon: Icons.delete_outline, title: '수거한 쓰레기 요약'),
          SizedBox(height: 14),
          _SummaryPill(icon: Icons.photo_camera_outlined, label: '사진 인증 3건'),
          SizedBox(height: 10),
          _SummaryPill(icon: Icons.edit_note_outlined, label: '선택 입력 1건'),
        ],
      ),
    );
  }
}

class _PhotoCertificationList extends StatelessWidget {
  const _PhotoCertificationList();

  @override
  Widget build(BuildContext context) {
    return _ResultCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.photo_library_outlined, title: '사진 인증'),
          const SizedBox(height: 14),
          for (var index = 1; index <= 3; index++) ...[
            _PhotoPlaceholder(index: index),
            if (index < 3) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SaveStatusCard extends StatelessWidget {
  const _SaveStatusCard();

  @override
  Widget build(BuildContext context) {
    return const _ResultCard(
      child: Row(
        children: [
          _IconBadge(icon: Icons.cloud_done_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '저장 대기 중',
                  style: TextStyle(
                    color: PloggingResultScreen._darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '활동 기록 저장하기를 누르면 내 활동 기록에 반영됩니다.',
                  style: TextStyle(
                    color: PloggingResultScreen._grayText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _ResultActions extends StatelessWidget {
  const _ResultActions({
    required this.isSaved,
    required this.isSaving,
    required this.onSavePressed,
    required this.onSharePressed,
    required this.onHomePressed,
  });

  final bool isSaved;
  final bool isSaving;
  final VoidCallback onSavePressed;
  final VoidCallback onSharePressed;
  final VoidCallback onHomePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: isSaved || isSaving ? null : onSavePressed,
            icon: Icon(
              isSaved
                  ? Icons.check_circle_outline
                  : isSaving
                  ? Icons.hourglass_top
                  : Icons.bookmark_add_outlined,
            ),
            label: Text(
              isSaved
                  ? '저장 완료'
                  : isSaving
                  ? '저장 중...'
                  : '활동 기록 저장하기',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: PloggingResultScreen._green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onSharePressed,
            icon: const Icon(Icons.ios_share_outlined),
            label: const Text('커뮤니티에 공유하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PloggingResultScreen._green,
              side: const BorderSide(color: PloggingResultScreen._green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton.icon(
            onPressed: onHomePressed,
            icon: const Icon(Icons.home_outlined),
            label: const Text('홈으로 돌아가기'),
            style: TextButton.styleFrom(
              foregroundColor: PloggingResultScreen._grayText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: PloggingResultScreen._green, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: PloggingResultScreen._grayText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: PloggingResultScreen._darkText,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (showDivider) const Divider(height: 22, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: PloggingResultScreen._green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: PloggingResultScreen._darkText,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: PloggingResultScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: PloggingResultScreen._green, size: 21),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: PloggingResultScreen._darkText,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PloggingResultScreen._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: PloggingResultScreen._lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.image_outlined,
              color: PloggingResultScreen._green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '사진 인증 $index',
              style: const TextStyle(
                color: PloggingResultScreen._darkText,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: PloggingResultScreen._green,
            size: 21,
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: PloggingResultScreen._lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: PloggingResultScreen._green, size: 26),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child});

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
