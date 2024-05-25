import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/helper/js/helper.dart';
import 'package:flutter_draw9patch/helper/js/theme_state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScope extends ConsumerStatefulWidget {
  final Widget child;
  const AppScope({super.key, required this.child});

  @override
  ConsumerState<AppScope> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<AppScope> {
  late final ThemeStateManager _state;
  @override
  void initState() {
    super.initState();
    _state = ThemeStateManager(ref: ref);
    final export = createJSInteropWrapper(_state);
    broadcastAppEvent("flutter-initialized", export);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
