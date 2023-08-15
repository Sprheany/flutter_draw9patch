// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: constant_identifier_names

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/action_provider.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/ui/preview/stretch_view_painter.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/widgets/two_directions_scroll_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewPanel extends ConsumerStatefulWidget {
  const PreviewPanel({super.key});

  @override
  ConsumerState<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends ConsumerState<PreviewPanel> {
  late ui.Image image;
  late PatchInfo patchInfo;

  final StretchInfo horizontal = StretchInfo();
  final StretchInfo vertical = StretchInfo();
  final StretchInfo both = StretchInfo();

  double horizontalPatchesSum = 0;
  double verticalPatchesSum = 0;

  void setScale(double scale) {
    int patchWidth = image.width - 2;
    int patchHeight = image.height - 2;

    double scaledWidth = patchWidth * scale;
    double scaledHeight = patchHeight * scale;

    vertical.scaledWidth = image.width.toDouble();
    vertical.scaledHeight = scaledHeight;
    horizontal.scaledWidth = scaledWidth;
    horizontal.scaledHeight = image.height.toDouble();
    both.scaledWidth = scaledWidth;
    both.scaledHeight = scaledHeight;

    computePatches();
  }

  void computePatches() {
    bool measuredWidth = false;
    bool endRow = true;

    double remainderHorizontal = 0;
    double remainderVertical = 0;

    if (patchInfo.fixed.isNotEmpty) {
      double start = patchInfo.fixed[0].top;
      for (Rect rect in patchInfo.fixed) {
        if (rect.top > start) {
          endRow = true;
          measuredWidth = true;
        }
        if (!measuredWidth) {
          remainderHorizontal += rect.width;
        }
        if (endRow) {
          remainderVertical += rect.height;
          endRow = false;
          start = rect.top;
        }
      }
    } else {
      /* fully stretched without fixed regions (often single pixel high or wide). Since
             * width of vertical patches (and height of horizontal patches) are fixed, use them to
             * determine fixed space
             */
      for (Rect rect in patchInfo.verticalPatches) {
        remainderHorizontal += rect.width;
      }
      for (Rect rect in patchInfo.horizontalPatches) {
        remainderVertical += rect.height;
      }
    }

    horizontal.remainderHorizontal = horizontal.scaledWidth - remainderHorizontal;
    vertical.remainderHorizontal = vertical.scaledWidth - remainderHorizontal;
    both.remainderHorizontal = both.scaledWidth - remainderHorizontal;

    horizontal.remainderVertical = horizontal.scaledHeight - remainderVertical;
    vertical.remainderVertical = vertical.scaledHeight - remainderVertical;
    both.remainderVertical = both.scaledHeight - remainderVertical;

    horizontalPatchesSum = 0;
    if (patchInfo.horizontalPatches.isNotEmpty) {
      double start = -1;
      for (Rect rect in patchInfo.horizontalPatches) {
        if (rect.left > start) {
          horizontalPatchesSum += rect.width;
          start = rect.left;
        }
      }
    } else {
      double start = -1;
      for (Rect rect in patchInfo.patches) {
        if (rect.left > start) {
          horizontalPatchesSum += rect.width;
          start = rect.left;
        }
      }
    }

    verticalPatchesSum = 0;
    if (patchInfo.verticalPatches.isNotEmpty) {
      double start = -1;
      for (Rect rect in patchInfo.verticalPatches) {
        if (rect.top > start) {
          verticalPatchesSum += rect.height;
          start = rect.top;
        }
      }
    } else {
      double start = -1;
      for (Rect rect in patchInfo.patches) {
        if (rect.top > start) {
          verticalPatchesSum += rect.height;
          start = rect.top;
        }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final imageData = ref.watch(createImageDataProvider).valueOrNull;
    if (imageData == null) {
      return const PreviewBackgroundWidget();
    }
    image = imageData.uiImage;
    patchInfo = imageData.patchInfo;

    setScale(ref.watch(patchScaleProvider));

    return LayoutBuilder(builder: (_, constraints) {
      return PreviewBackgroundWidget(
        child: TwoDirectionsScrollView(
          child: Padding(
            padding: const EdgeInsets.all(STRETCH_MARGIN),
            child: Column(
              children: [
                CustomPaint(
                  size: Size(vertical.scaledWidth, vertical.scaledHeight),
                  painter: StretchViewPainter(
                    image: image,
                    patchInfo: patchInfo,
                    stretchInfo: vertical,
                    horizontalPatchesSum: horizontalPatchesSum,
                    verticalPatchesSum: verticalPatchesSum,
                    showPadding: ref.watch(showContentProvider),
                  ),
                ),
                const SizedBox(height: STRETCH_MARGIN),
                CustomPaint(
                  size: Size(horizontal.scaledWidth, horizontal.scaledHeight),
                  painter: StretchViewPainter(
                    image: image,
                    patchInfo: patchInfo,
                    stretchInfo: horizontal,
                    horizontalPatchesSum: horizontalPatchesSum,
                    verticalPatchesSum: verticalPatchesSum,
                    showPadding: ref.watch(showContentProvider),
                  ),
                ),
                const SizedBox(height: STRETCH_MARGIN),
                CustomPaint(
                  size: Size(both.scaledWidth, both.scaledHeight),
                  painter: StretchViewPainter(
                    image: image,
                    patchInfo: patchInfo,
                    stretchInfo: both,
                    horizontalPatchesSum: horizontalPatchesSum,
                    verticalPatchesSum: verticalPatchesSum,
                    showPadding: ref.watch(showContentProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class PreviewBackgroundWidget extends StatelessWidget {
  final Widget? child;

  const PreviewBackgroundWidget({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/checker.png"),
          fit: BoxFit.none,
          repeat: ImageRepeat.repeat,
        ),
      ),
      child: child,
    );
  }
}
