import 'package:flutter/material.dart';

bool isDarkMode() {
  return ThemeMode.system == ThemeMode.dark;
}

class AppScope extends StatelessWidget {
  final Widget child;
  const AppScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
