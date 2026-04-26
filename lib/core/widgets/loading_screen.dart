import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 24),
            Text(
              'Initializing ZynkChat...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
