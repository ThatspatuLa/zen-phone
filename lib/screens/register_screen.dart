/// Register screen — placeholder for future agent/persona registration.
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Register — not in v1.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
          ),
        ),
      ),
    );
  }
}
