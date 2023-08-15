import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';

class StretchInfo {
  double scaledWidth = 0;
  double scaledHeight = 0;

  double remainderHorizontal = 0;
  double remainderVertical = 0;

  @override
  String toString() {
    return "{$scaledWidth, $scaledHeight, $remainderHorizontal, $remainderVertical}";
  }
}

class StretchViewPainter extends CustomPainter {
  final Image image;
  final PatchInfo patchInfo;

  final double scaledWidth;
  final double scaledHeight;

  final double remainderHorizontal;
  final double remainderVertical;

  final double horizontalPatchesSum;
  final double verticalPatchesSum;

  final bool showPadding;

  StretchViewPainter({
    required StretchInfo stretchInfo,
    required this.image,
    required this.patchInfo,
    required this.horizontalPatchesSum,
    required this.verticalPatchesSum,
    required this.showPadding,
  })  : scaledWidth = stretchInfo.scaledWidth,
        scaledHeight = stretchInfo.scaledHeight,
        remainderHorizontal = stretchInfo.remainderHorizontal,
        remainderVertical = stretchInfo.remainderVertical;

  @override
  void paint(Canvas canvas, Size size) {
    if (patchInfo.patches.isEmpty) {
      canvas.drawImage(image, Offset.zero, Paint());
      return;
    }
    double x = 0;
    double y = 0;

    int fixedIndex = 0;
    int horizontalIndex = 0;
    int verticalIndex = 0;
    int patchIndex = 0;

    bool hStretch = false;
    bool vStretch = false;

    double vWeightSum = 1.0;
    double vRemainder = remainderVertical;

    vStretch = patchInfo.verticalStartWithPatch;

    while (y < scaledHeight - 1) {
      hStretch = patchInfo.horizontalStartWithPatch;

      double height = 0;
      double vExtra = 0.0;

      double hWeightSum = 1.0;
      double hRemainder = remainderHorizontal;

      while (x < scaledWidth - 1) {
        Rect r;
        if (!vStretch) {
          if (hStretch) {
            r = patchInfo.horizontalPatches[horizontalIndex++];
            double extra = r.width / horizontalPatchesSum;
            int width = extra * hRemainder ~/ hWeightSum;
            hWeightSum -= extra;
            hRemainder -= width;
            Rect dst = Rect.fromLTRB(x, y, x + width, y + r.height);
            canvas.drawImageRect(image, r, dst, Paint());
            x += width;
          } else {
            r = patchInfo.fixed[fixedIndex++];
            Rect dst = Rect.fromLTRB(x, y, x + r.width, y + r.height);
            canvas.drawImageRect(image, r, dst, Paint());
            x += r.width;
          }
          height = r.height;
        } else {
          if (hStretch) {
            r = patchInfo.patches[patchIndex++];
            vExtra = r.height / verticalPatchesSum;
            height = vExtra * vRemainder / vWeightSum;
            double extra = r.width / horizontalPatchesSum;
            int width = extra * hRemainder ~/ hWeightSum;
            hWeightSum -= extra;
            hRemainder -= width;
            Rect dst = Rect.fromLTRB(x, y, x + width, y + height);
            canvas.drawImageRect(image, r, dst, Paint());
            x += width;
          } else {
            r = patchInfo.verticalPatches[verticalIndex++];
            vExtra = r.height / verticalPatchesSum;
            height = vExtra * vRemainder / vWeightSum;
            Rect dst = Rect.fromLTRB(x, y, x + r.width, y + height);
            canvas.drawImageRect(image, r, dst, Paint());
            x += r.width;
          }
        }
        hStretch = !hStretch;
      }
      x = 0;
      y += height;
      if (vStretch) {
        vWeightSum -= vExtra;
        vRemainder -= height;
      }
      vStretch = !vStretch;
    }

    if (showPadding) {
      canvas.drawRect(
        Rect.fromLTWH(
          patchInfo.horizontalPadding.first.toDouble(),
          patchInfo.verticalPadding.first.toDouble(),
          scaledWidth - patchInfo.horizontalPadding.first - patchInfo.horizontalPadding.second,
          scaledHeight - patchInfo.verticalPadding.first - patchInfo.verticalPadding.second,
        ),
        Paint()..color = PADDING_COLOR,
      );
    }
  }

  @override
  bool shouldRepaint(StretchViewPainter oldDelegate) => oldDelegate.toString() != toString();

  @override
  String toString() {
    return "{image: $image, patchInfo: $patchInfo, scaledWidth: $scaledWidth, scaledHeight: $scaledHeight, remainderHorizontal: $remainderHorizontal, remainderVertical: $remainderVertical, horizontalPatchesSum: $horizontalPatchesSum, verticalPatchesSum: $verticalPatchesSum, showPadding: $showPadding}";
  }
}
