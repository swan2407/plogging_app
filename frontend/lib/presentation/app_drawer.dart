import 'package:flutter/material.dart';

import '../core/auth/mock_auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const _green = Color(0xFF2E7D32);
  static const _darkText = Color(0xFF1F2937);
  static const _grayText = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '플로깅',
                    style: TextStyle(
                      color: _green,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '부가 메뉴',
                    style: TextStyle(
                      color: _grayText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.history,
              title: '내 활동 기록',
              onTap: () => _closeWithMessage(context, '내 활동 기록'),
            ),
            _DrawerItem(
              icon: Icons.bar_chart,
              title: '내 통계',
              onTap: () => _closeWithMessage(context, '내 통계'),
            ),
            _DrawerItem(
              icon: Icons.campaign_outlined,
              title: '공지사항',
              onTap: () => _closeWithMessage(context, '공지사항'),
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              title: '설정',
              onTap: () => _closeWithMessage(context, '설정'),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              title: '로그아웃',
              onTap: () async {
                await mockAuthController.logout();
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('로그아웃되었습니다.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _closeWithMessage(BuildContext context, String title) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title 화면은 준비 중입니다.')));
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppDrawer._green),
      title: Text(
        title,
        style: const TextStyle(
          color: AppDrawer._darkText,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: onTap,
    );
  }
}
