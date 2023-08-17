import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/file_actions.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/editor/image_viewer.dart';
import 'package:flutter_draw9patch/widgets/two_directions_scroll_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorPanel extends ConsumerWidget {
  const EditorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(createImageDataProvider).valueOrNull;
    return Container(
      color: EDITOR_BACKGROUND_COLOR,
      constraints: const BoxConstraints.expand(),
      child: data != null
          ? TwoDirectionsScrollView(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  return ConstrainedBox(
                    constraints: constraints,
                    child: const ImageViewer(),
                  );
                },
              ),
            )
          : const OpenFileWidget(),
    );
  }
}

class OpenFileWidget extends ConsumerWidget {
  const OpenFileWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: InkWell(
        onTap: () async {
          final file = await OpenFileAction.selectImage();
          if (file != null) {
            ref.read(imageFileProvider.notifier).state = file;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightForFinite(),
            child: const Text("请选择图片或拖拽图片到这里"),
          ),
        ),
      ),
    );
  }
}
