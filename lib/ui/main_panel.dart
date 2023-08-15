// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/ui/action/action_panel.dart';
import 'package:flutter_draw9patch/ui/editor/editor_panel.dart';
import 'package:flutter_draw9patch/ui/open_file_panel.dart';
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
  double editorWidth = WINDOW_WIDTH * 0.55;

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(createImageDataProvider).valueOrNull;
    if (data == null) {
      return const OpenFilePanel();
    }
    return LayoutBuilder(
      builder: (_, constraints) {
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: editorWidth,
                    child: const EditorPanel(),
                  ),
                  SplitterWidget(
                    onSplitterChange: (value) {
                      if (value > PANEL_MIN_WIDTH && value < constraints.maxWidth - PANEL_MIN_WIDTH) {
                        editorWidth = value;
                        setState(() {});
                      }
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
