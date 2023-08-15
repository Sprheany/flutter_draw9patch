import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/file_actions.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/ui/main_panel.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/window_border.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScreen extends ConsumerWidget {
  const AppScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(APP_TITLE),
        centerTitle: (kIsWeb || Platform.isWindows) ? false : true,
        titleSpacing: 0,
        leading: (!kIsWeb && Platform.isMacOS) ? const WindowButtons() : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            iconSize: 24,
            onPressed: () async {
              final file = await OpenFileAction.selectImage();
              if (file != null) {
                ref.read(imageFileProvider.notifier).state = file;
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.save),
            iconSize: 24,
            onPressed: () => SaveFileAction.saveImage(
              ref.read(createImageDataProvider).value!.image,
            ),
          ),
          const SizedBox(width: 24),
          if (!kIsWeb && !Platform.isMacOS) const WindowButtons(),
        ],
        automaticallyImplyLeading: false,
        flexibleSpace: MoveWindow(),
      ),
      body: const MainPanel(),
    );
  }
}
