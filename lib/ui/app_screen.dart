import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/main_panel.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/window_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({super.key});

  @override
  ConsumerState createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen> {
  bool showDragMask = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Text(APP_TITLE),
              centerTitle: (kIsWeb || Platform.isWindows) ? false : true,
              titleSpacing: 0,
              leading: (!kIsWeb && Platform.isMacOS) ? const WindowButtons() : null,
              actions: [
                if (!kIsWeb && !Platform.isMacOS) const WindowButtons(),
              ],
              automaticallyImplyLeading: false,
              flexibleSpace: MoveWindow(),
            ),
      body: DropTarget(
        onDragEntered: (_) => setState(() {
          showDragMask = true;
        }),
        onDragExited: (_) => setState(() {
          showDragMask = false;
        }),
        onDragDone: (details) {
          if (details.files.isNotEmpty) {
            ref.read(imageFileProvider.notifier).state = details.files.first;
          }
        },
        child: Stack(
          children: [
            const MainPanel(),
            if (showDragMask)
              Container(
                color: HIGHLIGHT_REGION_COLOR,
              ),
          ],
        ),
      ),
    );
  }
}
