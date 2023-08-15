import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/file_actions.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpenFilePanel extends ConsumerWidget {
  const OpenFilePanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropTarget(
      onDragDone: (details) {
        if (details.files.isNotEmpty) {
          ref.read(imageFileProvider.notifier).state = details.files.first;
        }
      },
      child: InkWell(
        onTap: () async {
          final file = await OpenFileAction.selectImage();
          if (file != null) {
            ref.read(imageFileProvider.notifier).state = file;
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: AlignmentDirectional.bottomCenter,
              colors: [DARK_BLUE, Colors.black],
              stops: [0.22, 0.9],
            ),
          ),
          child: Center(
            child: Image.asset("images/drop.png"),
          ),
        ),
      ),
    );
  }
}
