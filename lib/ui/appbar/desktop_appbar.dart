import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/theme_provider.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/window_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopAppBar extends AppBar {
  TopAppBar({
    super.key,
    required WidgetRef ref,
  }) : super(
          title: const Text(APP_TITLE),
          centerTitle: Platform.isWindows ? false : true,
          titleSpacing: 0,
          leading: Platform.isMacOS ? const WindowButtons() : null,
          actions: [
            if (!Platform.isMacOS) const WindowButtons(),
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: IconButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).state = !ref.watch(themeProvider);
                },
                icon: Icon(ref.watch(themeProvider) ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
              ),
            ),
          ],
          automaticallyImplyLeading: false,
          flexibleSpace: MoveWindow(),
        );
}
