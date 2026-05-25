import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    required this.onMenuPressed,
    required this.onProfilePressed,
  });

  final String title;
  final VoidCallback onMenuPressed;
  final VoidCallback onProfilePressed;

  static const _green = Color(0xFF2E7D32);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _green,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        tooltip: '메뉴 열기',
        onPressed: onMenuPressed,
        icon: const Icon(Icons.menu),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      actions: [
        IconButton(
          tooltip: '프로필',
          onPressed: onProfilePressed,
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }
}
