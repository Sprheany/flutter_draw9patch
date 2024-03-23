import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/helper/theme_helper.dart'
    if (dart.library.js) 'package:flutter_draw9patch/helper/theme_helper_web.dart';
import 'package:flutter_draw9patch/provider/theme_provider.dart';
import 'package:flutter_draw9patch/theme/color_schemes.g.dart';
import 'package:flutter_draw9patch/ui/app_screen.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
  }

  runApp(const ProviderScope(child: AppScope(child: MyApp())));

  if (!kIsWeb) {
    // Add this code below
    const initialSize = Size(WINDOW_WIDTH, WINDOW_HEIGHT);
    windowManager.setMinimumSize(initialSize);
    windowManager.setSize(initialSize);
    if (!Platform.isMacOS) windowManager.setAsFrameless();

    doWhenWindowReady(() {
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = APP_TITLE;
      appWindow.show();
    });
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigatorProvider.navigatorKey,
      title: APP_TITLE,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ref.watch(themeProvider) ? darkColorScheme : lightColorScheme,
        sliderTheme: const SliderThemeData(
          trackHeight: 2,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
        ),
        listTileTheme: const ListTileThemeData(
          horizontalTitleGap: 8,
          dense: true,
          contentPadding: EdgeInsets.all(0),
          visualDensity: VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity,
          ),
        ),
        checkboxTheme: const CheckboxThemeData(
          splashRadius: 0,
        ),
      ),
      home: const AppScreen(),
    );
  }
}

/// 用于提供全局的 navigatorContext
class NavigatorProvider {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'Rex');

  static final NavigatorProvider _instance = NavigatorProvider._();

  NavigatorProvider._();

  /// 赋值给根布局的 materialApp 上
  /// navigatorKey.currentState.pushName('url') 可直接用于跳转
  static GlobalKey<NavigatorState> get navigatorKey => _instance._navigatorKey;

  /// 可用于 跳转，overlay-insert（toast，loading） 使用
  static BuildContext? get navigatorContext => _instance._navigatorKey.currentState?.context;
}
