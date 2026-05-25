import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_icons.dart';
import '../features/community/presentation/message_screen.dart';
import '../features/group_plogging/presentation/group_plogging_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/map/presentation/map_screen.dart';
import '../features/plogging/presentation/personal_plogging_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const _tabs = <_NavigationTab>[
    _NavigationTab(
      label: '홈',
      assetPath: AppIcons.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      screen: HomeScreen(),
    ),
    _NavigationTab(
      label: '개인',
      assetPath: AppIcons.personal,
      icon: Icons.directions_walk_outlined,
      selectedIcon: Icons.directions_walk,
      screen: PersonalPloggingScreen(),
    ),
    _NavigationTab(
      label: '단체',
      assetPath: AppIcons.group,
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      screen: GroupPloggingScreen(),
    ),
    _NavigationTab(
      label: '지도',
      assetPath: AppIcons.map,
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
      screen: MapScreen(),
    ),
    _NavigationTab(
      label: '메시지',
      assetPath: AppIcons.message,
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      screen: MessageScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs.map((tab) => tab.screen).toList(),
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
          for (final tab in _tabs)
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
