// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';

class TopAppBar extends AppBar {
  TopAppBar({
    super.key,
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
        );
}
