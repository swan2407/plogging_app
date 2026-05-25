import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/auth/mock_auth_controller.dart';
import '../core/constants/app_icons.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/community/presentation/message_screen.dart';
import '../features/group_plogging/presentation/group_plogging_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/my_page/presentation/my_page_screen.dart';
import '../features/plogging/presentation/personal_plogging_screen.dart';
import 'app_drawer.dart';
import 'app_top_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openLoginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const LoginScreen(popAfterLogin: true),
      ),
    );
  }

  void _openProfileScreen() {
    if (!mockAuthController.isLoggedIn) {
      _openLoginScreen();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const MyPageScreen(popAfterLogout: true),
      ),
    );
  }

  List<_NavigationTab> get _tabs {
    return [
      _NavigationTab(
        label: '홈',
        assetPath: AppIcons.home,
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        screen: HomeScreen(onLoginPressed: _openLoginScreen),
      ),
      const _NavigationTab(
        label: '개인 플로깅',
        assetPath: AppIcons.personal,
        icon: Icons.directions_walk_outlined,
        selectedIcon: Icons.directions_walk,
        screen: PersonalPloggingScreen(),
      ),
      const _NavigationTab(
        label: '단체 플로깅',
        assetPath: AppIcons.group,
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
        screen: GroupPloggingScreen(),
      ),
      const _NavigationTab(
        label: '지도',
        assetPath: AppIcons.map,
        icon: Icons.map_outlined,
        selectedIcon: Icons.map,
        screen: MapScreen(),
      ),
      const _NavigationTab(
        label: '커뮤니티',
        assetPath: AppIcons.message,
        icon: Icons.chat_bubble_outline,
        selectedIcon: Icons.chat_bubble,
        screen: MessageScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _tabs;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTopBar(
        title: '플로깅',
        onMenuPressed: _openDrawer,
        onProfilePressed: _openProfileScreen,
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        top: false,
        child: IndexedStack(
          index: _currentIndex,
          children: tabs.map((tab) => tab.screen).toList(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: _SvgNavigationIcon(
                assetPath: tab.assetPath,
                fallbackIcon: tab.icon,
              ),
              selectedIcon: _SvgNavigationIcon(
                assetPath: tab.assetPath,
                fallbackIcon: tab.selectedIcon,
                selected: true,
              ),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _NavigationTab {
  const _NavigationTab({
    required this.label,
    required this.assetPath,
    required this.icon,
    required this.selectedIcon,
    required this.screen,
  });

  final String label;
  final String assetPath;
  final IconData icon;
  final IconData selectedIcon;
  final Widget screen;
}

class _SvgNavigationIcon extends StatelessWidget {
  const _SvgNavigationIcon({
    required this.assetPath,
    required this.fallbackIcon,
    this.selected = false,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      errorBuilder: (context, error, stackTrace) {
        return Icon(fallbackIcon, color: color);
      },
    );
  }
}
