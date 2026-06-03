import 'package:flutter/material.dart';

import '../data/mock_community_post_store.dart';
import '../model/community_post.dart';

class CommunityPostCreateScreen extends StatefulWidget {
  const CommunityPostCreateScreen({
    super.key,
    this.initialCategory = '활동 후기',
    this.initialTitle = '',
    this.initialContent = '',
    this.initialRegion = '서울 마포구',
    this.linkedActivitySummary,
    this.returnToRootOnSubmit = false,
  });

  final String initialCategory;
  final String initialTitle;
  final String initialContent;
  final String initialRegion;
  final String? linkedActivitySummary;
  final bool returnToRootOnSubmit;

  @override
  State<CommunityPostCreateScreen> createState() =>
      _CommunityPostCreateScreenState();
}

class _CommunityPostCreateScreenState extends State<CommunityPostCreateScreen> {
  late String _category;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _regionController;

  static const _green = Color(0xFF2E7D32);
  static const _lightGreen = Color(0xFFE8F5E9);
  static const _background = Color(0xFFF6F7F5);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);
  static const _inactive = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _category = communityPostCategories.contains(widget.initialCategory)
        ? widget.initialCategory
        : communityPostCategories.first;
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _regionController = TextEditingController(text: widget.initialRegion);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final region = _regionController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해 주세요.')));
      return;
    }

    mockCommunityPostStore.addPost(
      CommunityPost(
        id: 'community-${DateTime.now().microsecondsSinceEpoch}',
        category: _category,
        title: title,
        content: content,
        region: region.isEmpty ? '지역 미입력' : region,
        authorNickname: '초록걸음',
        createdDate: _formatCreatedDate(DateTime.now()),
        likeCount: 0,
        commentCount: 0,
        sourceType: widget.linkedActivitySummary == null
            ? 'community'
            : 'plogging_result',
        linkedActivitySummary: widget.linkedActivitySummary,
      ),
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시글 등록'),
          content: const Text('게시글이 등록되었습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (widget.returnToRootOnSubmit) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pop();
    }
  }

  String _formatCreatedDate(DateTime date) {
    return '${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('게시글 작성'),
        backgroundColor: _background,
        foregroundColor: _darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _CreateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.category_outlined,
                    title: '카테고리',
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final category in communityPostCategories)
                        _CategoryChip(
                          label: category,
                          selected: _category == category,
                          onPressed: () {
                            setState(() {
                              _category = category;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (widget.linkedActivitySummary != null) ...[
              _LinkedActivityCard(summary: widget.linkedActivitySummary!),
              const SizedBox(height: 18),
            ],
            _CreateCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle(
                    icon: Icons.edit_outlined,
                    title: '게시글 내용',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    decoration: _inputDecoration('제목'),
                    maxLength: 40,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    decoration: _inputDecoration('내용'),
                    minLines: 6,
                    maxLines: 10,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _regionController,
                    decoration: _inputDecoration('활동 지역'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send_outlined),
                label: const Text(
                  '게시글 등록',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _LinkedActivityCard extends StatelessWidget {
  const _LinkedActivityCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _CreateCard(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _CommunityPostCreateScreenState._lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.directions_walk_outlined,
              color: _CommunityPostCreateScreenState._green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '연결된 플로깅 기록',
                  style: TextStyle(
                    color: _CommunityPostCreateScreenState._darkText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  summary,
                  style: const TextStyle(
                    color: _CommunityPostCreateScreenState._grayText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _CommunityPostCreateScreenState._green, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _CommunityPostCreateScreenState._darkText,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? _CommunityPostCreateScreenState._green
              : _CommunityPostCreateScreenState._inactive,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : _CommunityPostCreateScreenState._grayText,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
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
