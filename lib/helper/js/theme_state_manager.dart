import 'dart:js_interop';

import 'package:flutter_draw9patch/provider/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@JSExport()
class ThemeStateManager {
  ThemeStateManager({required this.ref});

  final WidgetRef ref;

  void switchTheme(bool isDark) {
    ref.read(themeProvider.notifier).state = isDark;
  }
}
