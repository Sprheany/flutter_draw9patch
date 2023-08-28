// ignore_for_file: non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/ui/action/action_panel.dart';
import 'package:flutter_draw9patch/ui/action/operation_panel.dart';
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
  final double OPERATION_PANEL_WIDTH = 280;
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
                        max(value, PANEL_MIN_WIDTH + OPERATION_PANEL_WIDTH),
                        constraints.maxWidth - PANEL_MIN_WIDTH,
                      );
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
