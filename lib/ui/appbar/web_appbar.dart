// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/helper/theme_helper_web.dart';
import 'package:flutter_draw9patch/provider/theme_provider.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopAppBar extends AppBar {
  TopAppBar({
    super.key,
    required WidgetRef ref,
  }) : super(
          title: const Text(APP_TITLE),
          centerTitle: true,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () {
              js.context.callMethod('close');
            },
            icon: const Icon(Icons.arrow_back_outlined),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: IconButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).state = toggleTheme();
                },
                icon: Icon(ref.watch(themeProvider) ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
              ),
            ),
          ],
        );
}
