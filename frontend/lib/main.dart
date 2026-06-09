import 'package:flutter/material.dart';

import 'app.dart';
import 'core/auth/mock_auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await mockAuthController.restoreSession();
  runApp(const PloggingApp());
}

class MyApp extends PloggingApp {
  const MyApp({super.key});
}
