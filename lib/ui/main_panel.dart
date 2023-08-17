// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/file_actions.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/ui/action/action_panel.dart';
import 'package:flutter_draw9patch/ui/editor/editor_panel.dart';
import 'package:flutter_draw9patch/ui/preview/preview_panel.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/widgets/splitter_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPanel extends ConsumerStatefulWidget {
  const MainPanel({super.key});

  @override
  ConsumerState<MainPanel> createState() => _MainPanelState();
}

class _MainPanelState extends ConsumerState<MainPanel> {
  final double OPERATION_PANEL_WIDTH = 240;
  double editorWidthRatio = 0.55;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: OPERATION_PANEL_WIDTH, child: const OperationPanel()),
                  SizedBox(
                    width: (constraints.maxWidth - OPERATION_PANEL_WIDTH) * editorWidthRatio,
                    child: const EditorPanel(),
                  ),
                  SplitterWidget(
                    onSplitterChange: (value) {
                      value = min(
                          max(value, PANEL_MIN_WIDTH + OPERATION_PANEL_WIDTH), constraints.maxWidth - PANEL_MIN_WIDTH);
                      editorWidthRatio =
                          (value - OPERATION_PANEL_WIDTH) / (constraints.maxWidth - OPERATION_PANEL_WIDTH);
                      setState(() {});
                    },
                  ),
                  const Expanded(
                    child: PreviewPanel(),
                  ),
                ],
              ),
            ),
            const ActionPanel(),
          ],
        );
      },
    );
  }
}

class OperationPanel extends ConsumerStatefulWidget {
  const OperationPanel({super.key});

  @override
  ConsumerState<OperationPanel> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends ConsumerState<OperationPanel> {
  final _fileNameController = TextEditingController();

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(fileNameProvider, (previous, next) {
      if (_fileNameController.text != next) {
        _fileNameController.text = next;
      }
    });
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton(
            onPressed: () async {
              final file = await OpenFileAction.selectImage();
              if (file != null) {
                ref.read(imageFileProvider.notifier).state = file;
              }
            },
            child: const Text("选择图片"),
          ),
          const SizedBox(height: 48),
          const Text("图片文件名："),
          Text(
            "保存的图片命名为：[图片文件名].9.png",
            style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _fileNameController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => ref.read(fileNameProvider.notifier).state = value,
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () {
              final data = ref.read(createImageDataProvider).valueOrNull;
              if (data?.image != null) {
                SaveFileAction.saveImage(data!.image, _fileNameController.text);
              }
            },
            child: const Text("保存图片"),
          ),
        ],
      ),
    );
  }
}
