import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/window_border.dart';

class TopAppBar extends AppBar {
  TopAppBar({super.key})
      : super(
          title: const Text(APP_TITLE),
          centerTitle: Platform.isWindows ? false : true,
          titleSpacing: 0,
          leading: Platform.isMacOS ? const WindowButtons() : null,
          actions: [
            if (!Platform.isMacOS) const WindowButtons(),
          ],
          automaticallyImplyLeading: false,
          flexibleSpace: MoveWindow(),
        );
}
