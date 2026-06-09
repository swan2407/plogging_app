import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/mock_auth_controller.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/image_upload_service.dart';
import '../data/location_capture_service.dart';
import '../model/trash_certification_draft.dart';
import 'plogging_result_screen.dart';

class PersonalPloggingScreen extends StatefulWidget {
  const PersonalPloggingScreen({super.key});

  @override
  State<PersonalPloggingScreen> createState() => _PersonalPloggingScreenState();
}

class _PersonalPloggingScreenState extends State<PersonalPloggingScreen> {
  bool _isStarted = false;
  bool _isPaused = false;
  int _trashCertificationCount = 0;
  final List<TrashCertificationDraft> _trashCertifications = [];

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  void _startPlogging() {
    setState(() {
      _isStarted = true;
      _isPaused = false;
      _trashCertificationCount = 0;
      _trashCertifications.clear();
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _finishPlogging() async {
    if (!_isStarted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 플로깅을 시작해 주세요.')));
      return;
    }

    final shouldFinish = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('플로깅을 종료할까요?'),
          content: const Text('현재까지의 활동 기록과 쓰레기 인증 내역이 요약됩니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('종료하기'),
            ),
          ],
        );
      },
    );

    if (shouldFinish != true || !mounted) {
      return;
    }

    setState(() {
      _isStarted = false;
      _isPaused = false;
      _trashCertificationCount = 0;
    });

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PloggingResultScreen(
          trashCertifications: List.unmodifiable(_trashCertifications),
        ),
      ),
    );
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
          onRegister: (certification) {
            setState(() {
              _trashCertifications.add(certification);
              _trashCertificationCount++;
            });
          },
        );
      },
    );
  }

  void _openLoginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(popAfterLogin: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: ValueListenableBuilder<bool>(
        valueListenable: mockAuthController,
        builder: (context, isLoggedIn, child) {
          if (!isLoggedIn) {
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: _LoginRequiredCard(onLoginPressed: _openLoginScreen),
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                const _ScreenHeader(),
                const SizedBox(height: 18),
                const _MapPlaceholderCard(),
                const SizedBox(height: 18),
                if (_isStarted) ...[
                  _StatusCard(
                    isPaused: _isPaused,
                    trashCertificationCount: _trashCertificationCount,
                  ),
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
          );
        },
      ),
    );
  }
}

class _LoginRequiredCard extends StatelessWidget {
  const _LoginRequiredCard({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return _PloggingCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _PersonalPloggingScreenState._lightGreen,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: _PersonalPloggingScreenState._green,
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '로그인이 필요해요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _PersonalPloggingScreenState._darkText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '플로깅 기록과 쓰레기 인증을 저장하려면 로그인이 필요합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _PersonalPloggingScreenState._grayText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton.icon(
              onPressed: onLoginPressed,
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                '로그인하고 플로깅 시작하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
          ),
        ],
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
          '가볍게 시작하고 오늘의 활동을 기록해 보세요.',
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
              '실제 GPS와 지도는 이후 연결됩니다.',
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
  const _StatusCard({
    required this.isPaused,
    required this.trashCertificationCount,
  });

  final bool isPaused;
  final int trashCertificationCount;

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
                  icon: Icons.add_a_photo_outlined,
                  value: '$trashCertificationCount개',
                  label: '사진 인증',
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

  final ValueChanged<TrashCertificationDraft> onRegister;

  @override
  State<_TrashRegistrationSheet> createState() =>
      _TrashRegistrationSheetState();
}

class _TrashRegistrationSheetState extends State<_TrashRegistrationSheet> {
  final _imagePicker = ImagePicker();
  final _imageUploadService = ImageUploadService();
  final _locationCaptureService = LocationCaptureService();
  String? _trashType;
  XFile? _selectedTrashImageFile;
  Uint8List? _selectedTrashImageBytes;
  String? _uploadedTrashImageUrl;
  String? _uploadErrorMessage;
  double? _trashLatitude;
  double? _trashLongitude;
  String? _locationErrorMessage;
  int _selectedImageVersion = 0;
  bool _isChoosingImageSource = false;
  bool _isPickingImage = false;
  bool _isUploadingImage = false;
  bool _isCapturingLocation = false;

  Future<void> _showImageSourceSheet() async {
    if (_isChoosingImageSource || _isPickingImage || _isUploadingImage) {
      return;
    }

    setState(() => _isChoosingImageSource = true);
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('사진 촬영'),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('앨범에서 선택'),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (!mounted) {
        return;
      }
      if (source == null) {
        _showMessage('사진 선택이 취소되었습니다.');
        return;
      }
      await _pickImage(source);
    } finally {
      if (mounted) {
        setState(() => _isChoosingImageSource = false);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingImage = true);
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
      );
      if (!mounted) {
        return;
      }
      if (image == null) {
        _showMessage('사진 선택이 취소되었습니다.');
        return;
      }

      final imageBytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedTrashImageFile = image;
        _selectedTrashImageBytes = imageBytes;
        _uploadedTrashImageUrl = null;
        _uploadErrorMessage = null;
        _trashLatitude = null;
        _trashLongitude = null;
        _locationErrorMessage = null;
        _selectedImageVersion++;
      });
      await _uploadSelectedImage();
    } catch (error) {
      debugPrint('Trash certification image pick failed: $error');
      if (mounted) {
        _showMessage('사진을 불러오지 못했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _registerCertification() {
    if (_selectedTrashImageFile == null) {
      _showMessage('사진을 먼저 선택해 주세요.');
      return;
    }
    final imageUrl = _uploadedTrashImageUrl;
    if (_isUploadingImage) {
      _showMessage('사진 업로드가 완료된 후 저장해주세요.');
      return;
    }
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      _showMessage('쓰레기 인증 사진 업로드가 필요합니다.');
      return;
    }
    if (_isCapturingLocation) {
      _showMessage('현재 위치를 확인하는 중입니다.');
      return;
    }
    final latitude = _trashLatitude;
    final longitude = _trashLongitude;
    if (latitude == null || longitude == null) {
      _captureCurrentLocation(_selectedImageVersion);
      return;
    }

    widget.onRegister(
      TrashCertificationDraft(
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('사진 인증이 등록되었습니다.')));
  }

  Future<void> _uploadSelectedImage() async {
    final image = _selectedTrashImageFile;
    if (image == null || _isUploadingImage) {
      return;
    }
    final uploadImageVersion = _selectedImageVersion;

    final accessToken = mockAuthController.accessToken;
    if (accessToken == null) {
      setState(() {
        _uploadedTrashImageUrl = null;
        _uploadErrorMessage = '로그인이 필요합니다.';
      });
      _showMessage('로그인이 필요합니다.');
      return;
    }

    setState(() {
      _isUploadingImage = true;
      _uploadedTrashImageUrl = null;
      _uploadErrorMessage = null;
    });
    try {
      final imageUrl = await _imageUploadService.uploadTrashCertificationImage(
        image,
        accessToken,
      );
      if (!mounted) {
        return;
      }
      if (uploadImageVersion != _selectedImageVersion) {
        return;
      }
      setState(() => _uploadedTrashImageUrl = imageUrl);
      debugPrint('Trash certification image uploaded: $imageUrl');
      _showMessage('사진 업로드가 완료되었습니다.');
      await _captureCurrentLocation(uploadImageVersion);
    } on ImageUploadException catch (exception) {
      debugPrint('Trash certification image upload failed: $exception');
      if (mounted) {
        if (uploadImageVersion != _selectedImageVersion) {
          return;
        }
        setState(() => _uploadErrorMessage = '사진 업로드에 실패했습니다.');
        _showMessage(
          exception.message == '로그인이 필요합니다.'
              ? exception.message
              : '사진 업로드에 실패했습니다.',
        );
      }
    } catch (error) {
      debugPrint('Trash certification image upload failed: $error');
      if (mounted) {
        if (uploadImageVersion != _selectedImageVersion) {
          return;
        }
        setState(() => _uploadErrorMessage = '사진 업로드에 실패했습니다.');
        _showMessage('사진 업로드에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _captureCurrentLocation(int imageVersion) async {
    if (_isCapturingLocation || imageVersion != _selectedImageVersion) {
      return;
    }

    setState(() {
      _isCapturingLocation = true;
      _trashLatitude = null;
      _trashLongitude = null;
      _locationErrorMessage = null;
    });
    try {
      final position = await _locationCaptureService.getCurrentPosition();
      if (!mounted || imageVersion != _selectedImageVersion) {
        return;
      }
      setState(() {
        _trashLatitude = position.latitude;
        _trashLongitude = position.longitude;
      });
    } on LocationCaptureException catch (exception) {
      debugPrint('Trash certification location capture failed: $exception');
      if (mounted && imageVersion == _selectedImageVersion) {
        setState(() => _locationErrorMessage = exception.message);
        _showMessage(exception.message);
      }
    } finally {
      if (mounted && imageVersion == _selectedImageVersion) {
        setState(() => _isCapturingLocation = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
              '쓰레기 사진 인증',
              style: TextStyle(
                color: _PersonalPloggingScreenState._darkText,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '사진 인증을 먼저 남기고, 종류와 개수는 필요할 때만 입력하세요.',
              style: TextStyle(
                color: _PersonalPloggingScreenState._grayText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _PhotoCertificationCard(
              selectedImageBytes: _selectedTrashImageBytes,
              selectedImageName: _selectedTrashImageFile?.name,
              isPickingImage: _isPickingImage,
              isChoosingImageSource: _isChoosingImageSource,
              isUploadingImage: _isUploadingImage,
              uploadedImageUrl: _uploadedTrashImageUrl,
              uploadErrorMessage: _uploadErrorMessage,
              isCapturingLocation: _isCapturingLocation,
              hasLocation: _trashLatitude != null && _trashLongitude != null,
              locationErrorMessage: _locationErrorMessage,
              onPressed: _showImageSourceSheet,
              onRetryPressed: _uploadSelectedImage,
              onRetryLocationPressed: () =>
                  _captureCurrentLocation(_selectedImageVersion),
            ),
            const SizedBox(height: 22),
            const _OptionalSectionTitle(),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _trashType,
              decoration: _inputDecoration('쓰레기 종류'),
              hint: const Text('선택 안 함'),
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
              decoration: _inputDecoration('개수'),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('예상 무게'),
            ),
            const SizedBox(height: 12),
            TextField(maxLines: 3, decoration: _inputDecoration('메모')),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _registerCertification,
                style: FilledButton.styleFrom(
                  backgroundColor: _PersonalPloggingScreenState._green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '사진 인증 등록하기',
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
  const _PhotoCertificationCard({
    required this.selectedImageBytes,
    required this.selectedImageName,
    required this.isPickingImage,
    required this.isChoosingImageSource,
    required this.isUploadingImage,
    required this.uploadedImageUrl,
    required this.uploadErrorMessage,
    required this.isCapturingLocation,
    required this.hasLocation,
    required this.locationErrorMessage,
    required this.onPressed,
    required this.onRetryPressed,
    required this.onRetryLocationPressed,
  });

  final Uint8List? selectedImageBytes;
  final String? selectedImageName;
  final bool isPickingImage;
  final bool isChoosingImageSource;
  final bool isUploadingImage;
  final String? uploadedImageUrl;
  final String? uploadErrorMessage;
  final bool isCapturingLocation;
  final bool hasLocation;
  final String? locationErrorMessage;
  final VoidCallback onPressed;
  final VoidCallback onRetryPressed;
  final VoidCallback onRetryLocationPressed;

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
            clipBehavior: Clip.antiAlias,
            child: selectedImageBytes == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: _PersonalPloggingScreenState._green,
                        size: 42,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '사진으로 간단히 인증해 주세요.',
                        style: TextStyle(
                          color: _PersonalPloggingScreenState._darkText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(selectedImageBytes!, fit: BoxFit.cover),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 8,
                        child: Text(
                          selectedImageName ?? '선택한 사진',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 6),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 14),
          if (isUploadingImage)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('사진을 업로드하는 중입니다...'),
                ],
              ),
            )
          else if (uploadedImageUrl != null)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '사진 업로드가 완료되었습니다.',
                style: TextStyle(
                  color: _PersonalPloggingScreenState._green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else if (uploadErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Text(
                    uploadErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onRetryPressed,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('다시 업로드'),
                  ),
                ],
              ),
            ),
          if (uploadedImageUrl != null && isCapturingLocation)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('현재 위치를 확인하는 중입니다.'),
            )
          else if (uploadedImageUrl != null && hasLocation)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                '현재 위치가 확인되었습니다.',
                style: TextStyle(
                  color: _PersonalPloggingScreenState._green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else if (uploadedImageUrl != null && locationErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Text(
                    locationErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onRetryLocationPressed,
                    icon: const Icon(Icons.my_location_outlined),
                    label: const Text('위치 다시 확인'),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed:
                  isChoosingImageSource || isPickingImage || isUploadingImage
                  ? null
                  : onPressed,
              icon: Icon(
                isPickingImage
                    ? Icons.hourglass_top_outlined
                    : Icons.photo_camera_outlined,
              ),
              label: Text(
                isPickingImage
                    ? '사진 불러오는 중...'
                    : selectedImageBytes == null
                    ? '사진 추가'
                    : '사진 변경',
              ),
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
