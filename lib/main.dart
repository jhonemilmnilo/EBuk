import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EBukApp(),
    ),
  );
}

class EBukApp extends StatelessWidget {
  const EBukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EBuk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShellScreen(),
    );
  }
}
