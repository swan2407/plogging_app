import 'package:flutter/material.dart';

import 'presentation/main_navigation_screen.dart';

class PloggingApp extends StatelessWidget {
  const PloggingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plogging',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
