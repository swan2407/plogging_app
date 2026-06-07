import 'package:flutter/material.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../../core/constants/korea_regions.dart';
import '../data/group_event_api_service.dart';
import '../data/mock_group_place_data.dart';

class CreateGroupPloggingScreen extends StatefulWidget {
  const CreateGroupPloggingScreen({super.key});

  @override
  State<CreateGroupPloggingScreen> createState() =>
      _CreateGroupPloggingScreenState();
}

class _CreateGroupPloggingScreenState extends State<CreateGroupPloggingScreen> {
  final _titleController = TextEditingController();
  final _suppliesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _apiService = GroupEventApiService();

  String? _selectedSido;
  String? _selectedSigungu;
  DateTime? _activityDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _deadline;
  int _maxParticipants = 10;
  String? _selectedPlace;
  bool _isSubmitting = false;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  String? get _selectedRegion {
    if (_selectedSido == null || _selectedSigungu == null) {
      return null;
    }
    return '$_selectedSido $_selectedSigungu';
  }

  DateTime? get _startDateTime {
    if (_activityDate == null || _startTime == null) {
      return null;
    }
    return DateTime(
      _activityDate!.year,
      _activityDate!.month,
      _activityDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  DateTime? get _endDateTime {
    if (_activityDate == null || _endTime == null) {
      return null;
    }
    return DateTime(
      _activityDate!.year,
      _activityDate!.month,
      _activityDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _suppliesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _darkText,
        elevation: 0,
        title: const Text('단체 플로깅 만들기'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const _CreateHeader(),
            const SizedBox(height: 16),
            _CreateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionTitle(title: '활동 정보'),
                  const SizedBox(height: 12),
                  _CreateTextField(
                    controller: _titleController,
                    label: '활동명',
                    icon: Icons.edit_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _SelectionTile(
                    icon: Icons.location_on_outlined,
                    title: '지역',
                    value: _selectedRegion ?? '지역 선택',
                    selected: _selectedRegion != null,
                    onPressed: _openRegionSheet,
                  ),
                  const SizedBox(height: 12),
                  _SelectionTile(
                    icon: Icons.calendar_today_outlined,
                    title: '활동 날짜',
                    value: _formatDate(_activityDate) ?? '날짜 선택',
                    selected: _activityDate != null,
                    onPressed: _pickActivityDate,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectionTile(
                          icon: Icons.play_circle_outline,
                          title: '시작 시간',
                          value: _formatTime(_startTime) ?? '선택',
                          selected: _startTime != null,
                          onPressed: () => _pickActivityTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SelectionTile(
                          icon: Icons.stop_circle_outlined,
                          title: '종료 시간',
                          value: _formatTime(_endTime) ?? '선택',
                          selected: _endTime != null,
                          onPressed: () => _pickActivityTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ParticipantCounter(
                    value: _maxParticipants,
                    onChanged: (value) {
                      setState(() {
                        _maxParticipants = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _PlaceSelectionCard(
                    selectedPlace: _selectedPlace,
                    onPressed: _openPlacePlaceholder,
                  ),
                  const SizedBox(height: 12),
                  _CreateTextField(
                    controller: _suppliesController,
                    label: '준비물 메모',
                    hintText: '선택 입력',
                    icon: Icons.backpack_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _CreateTextField(
                    controller: _descriptionController,
                    label: '상세 설명',
                    icon: Icons.notes_outlined,
                    minLines: 4,
                    maxLines: 6,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 12),
                  _DeadlineTile(
                    value: _formatDateTime(_deadline) ?? '시작 시간 선택 시 자동 설정',
                    hasValue: _deadline != null,
                    onPressed: _pickDeadline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _SystemManagedCard(),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSubmitting ? '생성 중...' : '생성하기',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
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

  Future<void> _pickActivityDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _activityDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      helpText: '활동 날짜 선택',
      cancelText: '취소',
      confirmText: '선택',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _activityDate = picked;
      _syncDefaultDeadline();
    });
  }

  Future<void> _pickActivityTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? _startTime ?? TimeOfDay.now()
          : _endTime ?? TimeOfDay.now(),
      helpText: isStart ? '시작 시간 선택' : '종료 시간 선택',
      cancelText: '취소',
      confirmText: '선택',
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isStart) {
        _startTime = picked;
        _syncDefaultDeadline();
      } else {
        _endTime = picked;
      }
    });
  }

  void _syncDefaultDeadline() {
    final startDateTime = _startDateTime;
    if (startDateTime == null) {
      _deadline = null;
      return;
    }

    final defaultDeadline = startDateTime.subtract(const Duration(hours: 2));
    if (_deadline == null || !_deadline!.isBefore(startDateTime)) {
      _deadline = defaultDeadline;
    }
  }

  Future<void> _pickDeadline() async {
    final startDateTime = _startDateTime;
    if (startDateTime == null) {
      _showSnackBar('활동 날짜와 시작 시간을 먼저 선택해 주세요.');
      return;
    }

    final initialDeadline =
        _deadline ?? startDateTime.subtract(const Duration(hours: 2));
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDeadline,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: startDateTime,
      helpText: '모집 마감 날짜 선택',
      cancelText: '취소',
      confirmText: '선택',
    );

    if (pickedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDeadline),
      helpText: '모집 마감 시간 선택',
      cancelText: '취소',
      confirmText: '선택',
    );

    if (pickedTime == null) {
      return;
    }

    final deadline = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (deadline.isAfter(startDateTime)) {
      _showSnackBar('모집 마감 시간은 시작 시간 이후로 설정할 수 없습니다.');
      return;
    }

    setState(() {
      _deadline = deadline;
    });
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
                              '지역 선택',
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
                      SizedBox(
                        height: 50,
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPlacePlaceholder() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('장소 선택'),
          content: const Text('실제 장소 검색과 지도 선택은 이후 지도 API 연동 시 구현됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                // lat/lng/address will be added when the map API is connected.
                setState(() {
                  _selectedPlace = mockGroupStartPlaceName;
                });
                Navigator.of(context).pop();
              },
              child: Text('$mockGroupStartPlaceName 선택'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_hasRequiredFields()) {
      _showSnackBar('필수 항목을 모두 입력해 주세요.');
      return;
    }

    if (!_isEndAfterStart()) {
      _showSnackBar('종료 시간은 시작 시간보다 늦어야 합니다.');
      return;
    }

    final startDateTime = _startDateTime;
    final endDateTime = _endDateTime;
    if (startDateTime == null || endDateTime == null) {
      _showSnackBar('활동 날짜와 시간을 확인해 주세요.');
      return;
    }

    if (_deadline != null && _deadline!.isAfter(startDateTime)) {
      _showSnackBar('모집 마감 시간은 활동 시작 시간 이후로 설정할 수 없습니다.');
      return;
    }

    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      _showSnackBar('로그인이 필요합니다.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiService.createGroupEvent(
        CreateGroupEventRequest(
          title: _titleController.text.trim(),
          regionSido: _selectedSido!,
          regionSigungu: _selectedSigungu!,
          startAt: startDateTime,
          endAt: endDateTime,
          recruitDeadlineAt: _deadline,
          maxParticipants: _maxParticipants,
          placeName: _selectedPlace!,
          supplies: _suppliesController.text.trim().isEmpty
              ? null
              : _suppliesController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
        accessToken,
      );

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('생성 완료'),
            content: const Text('단체 플로깅이 생성되었습니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on GroupEventApiException catch (exception) {
      if (mounted) {
        _showSnackBar(exception.message);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('서버에 연결할 수 없습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _hasRequiredFields() {
    return _titleController.text.trim().isNotEmpty &&
        _selectedRegion != null &&
        _activityDate != null &&
        _startTime != null &&
        _endTime != null &&
        _maxParticipants >= 2 &&
        _maxParticipants <= 100 &&
        _selectedPlace != null &&
        _descriptionController.text.trim().isNotEmpty;
  }

  bool _isEndAfterStart() {
    if (_startTime == null || _endTime == null) {
      return false;
    }
    return _minutesOfDay(_endTime!) > _minutesOfDay(_startTime!);
  }

  int _minutesOfDay(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  String? _formatDate(DateTime? date) {
    if (date == null) {
      return null;
    }
    return '${date.year}.${_twoDigits(date.month)}.${_twoDigits(date.day)}';
  }

  String? _formatTime(TimeOfDay? time) {
    if (time == null) {
      return null;
    }
    return time.format(context);
  }

  String? _formatDateTime(DateTime? value) {
    if (value == null) {
      return null;
    }
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '${_formatDate(value)} $time';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CreateHeader extends StatelessWidget {
  const _CreateHeader();

  @override
  Widget build(BuildContext context) {
    return const _CreateCard(
      child: Row(
        children: [
          _IconBox(icon: Icons.add_location_alt_outlined),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '새 모임 만들기',
                  style: TextStyle(
                    color: _CreateGroupPloggingScreenState._darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '날짜, 시간, 지역은 선택 UI로 정확하게 입력합니다.',
                  style: TextStyle(
                    color: _CreateGroupPloggingScreenState._grayText,
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

class _SystemManagedCard extends StatelessWidget {
  const _SystemManagedCard();

  @override
  Widget build(BuildContext context) {
    return const _CreateCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: '시스템 관리 정보'),
          SizedBox(height: 12),
          _ManagedInfoRow(
            icon: Icons.campaign_outlined,
            label: '모집 상태',
            value: '모집중',
          ),
          _ManagedInfoRow(
            icon: Icons.people_outline,
            label: '현재 참여 인원',
            value: '0명',
          ),
          _ManagedInfoRow(icon: Icons.person_outline, label: '인솔자', value: '나'),
        ],
      ),
    );
  }
}

class _ManagedInfoRow extends StatelessWidget {
  const _ManagedInfoRow({
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: _CreateGroupPloggingScreenState._green, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                color: _CreateGroupPloggingScreenState._grayText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _CreateGroupPloggingScreenState._darkText,
                fontWeight: FontWeight.w900,
              ),
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
        color: _CreateGroupPloggingScreenState._darkText,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CreateTextField extends StatelessWidget {
  const _CreateTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hintText,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hintText;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: _CreateGroupPloggingScreenState._green),
        filled: true,
        fillColor: _CreateGroupPloggingScreenState._background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _CreateGroupPloggingScreenState._green,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _CreateGroupPloggingScreenState._green,
        side: const BorderSide(color: _CreateGroupPloggingScreenState._green),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _CreateGroupPloggingScreenState._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: selected
                        ? _CreateGroupPloggingScreenState._darkText
                        : _CreateGroupPloggingScreenState._grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _ParticipantCounter extends StatelessWidget {
  const _ParticipantCounter({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _CreateGroupPloggingScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_outline,
            color: _CreateGroupPloggingScreenState._green,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '모집 인원',
                  style: TextStyle(
                    color: _CreateGroupPloggingScreenState._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '최소 2명, 최대 100명',
                  style: TextStyle(
                    color: _CreateGroupPloggingScreenState._darkText,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: value > 2 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _CreateGroupPloggingScreenState._darkText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton.filled(
            onPressed: value < 100 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _PlaceSelectionCard extends StatelessWidget {
  const _PlaceSelectionCard({
    required this.selectedPlace,
    required this.onPressed,
  });

  final String? selectedPlace;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _CreateGroupPloggingScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag_outlined,
            color: _CreateGroupPloggingScreenState._green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '출발 장소',
                  style: TextStyle(
                    color: _CreateGroupPloggingScreenState._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedPlace ?? '장소를 선택해 주세요.',
                  style: TextStyle(
                    color: selectedPlace == null
                        ? _CreateGroupPloggingScreenState._grayText
                        : _CreateGroupPloggingScreenState._darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(onPressed: onPressed, child: const Text('장소 선택하기')),
        ],
      ),
    );
  }
}

class _DeadlineTile extends StatelessWidget {
  const _DeadlineTile({
    required this.value,
    required this.hasValue,
    required this.onPressed,
  });

  final String value;
  final bool hasValue;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _CreateGroupPloggingScreenState._background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_outlined,
            color: _CreateGroupPloggingScreenState._green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '모집 마감 시간',
                  style: TextStyle(
                    color: _CreateGroupPloggingScreenState._grayText,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: hasValue
                        ? _CreateGroupPloggingScreenState._darkText
                        : _CreateGroupPloggingScreenState._grayText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: const Text('마감 시간 변경'),
          ),
        ],
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
            color: _CreateGroupPloggingScreenState._grayText,
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
                      color: _CreateGroupPloggingScreenState._grayText,
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
                              ? _CreateGroupPloggingScreenState._lightGreen
                              : _CreateGroupPloggingScreenState._background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? _CreateGroupPloggingScreenState._green
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: selected
                                ? _CreateGroupPloggingScreenState._green
                                : _CreateGroupPloggingScreenState._darkText,
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

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _CreateGroupPloggingScreenState._lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        icon,
        color: _CreateGroupPloggingScreenState._green,
        size: 28,
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({required this.child});

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
