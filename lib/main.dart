import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'widgets/auth_wrapper.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ZynkChatApp(),
    ),
  );
}

class ZynkChatApp extends StatelessWidget {
  const ZynkChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZynkChat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}
