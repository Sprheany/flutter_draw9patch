import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/app_screen.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  if (!kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
  }

  runApp(const ProviderScope(child: MyApp()));

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: APP_TITLE,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSwatch(backgroundColor: BACKGROUND_COLOR),
        appBarTheme: const AppBarTheme(backgroundColor: BACKGROUND_COLOR),
        sliderTheme: const SliderThemeData(
          trackHeight: 2,
          thumbColor: Colors.white,
          activeTrackColor: Colors.grey,
          inactiveTrackColor: Colors.grey,
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
