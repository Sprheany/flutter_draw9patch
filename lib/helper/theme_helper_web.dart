import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:js/js.dart';

// Calls invoke JavaScript `isDarkMode()`
@JS("isDarkMode")
external bool isDarkMode();

// JavaScript code may now call `functionName()` or `window.functionName()`
@JS('switchThemeDart')
external set _switchThemeFromJs(void Function(bool value) f);

class AppScope extends ConsumerStatefulWidget {
  final Widget child;
  const AppScope({super.key, required this.child});

  @override
  ConsumerState<AppScope> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<AppScope> {
  @override
  void initState() {
    super.initState();
    _switchThemeFromJs = allowInterop((bool value) {
      ref.read(themeProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
