import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/graphics_utilities.dart';
import 'package:image/image.dart' as img;

class CorruptPatch {
  static List<Rect> findBadPatches(img.Image image, PatchInfo patchInfo) {
    List<Rect> corruptedPatches = <Rect>[];

    for (Rect patch in patchInfo.patches) {
      if (corruptPatch(image, patch)) {
        corruptedPatches.add(patch);
      }
    }

    for (Rect patch in patchInfo.horizontalPatches) {
      if (corruptHorizontalPatch(image, patch)) {
        corruptedPatches.add(patch);
      }
    }

    for (Rect patch in patchInfo.verticalPatches) {
      if (corruptVerticalPatch(image, patch)) {
        corruptedPatches.add(patch);
      }
    }

    return corruptedPatches;
  }

  static bool corruptPatch(img.Image image, Rect patch) {
    List<img.Pixel> pixels = GraphicsUtilities.getPixels(
      image,
      patch.left.toInt(),
      patch.top.toInt(),
      patch.width.toInt(),
      patch.height.toInt(),
    );

    if (pixels.isNotEmpty) {
      img.Pixel reference = pixels[0];
      for (var pixel in pixels) {
        if (pixel != reference) {
          return true;
        }
      }
    }

    return false;
  }

  static bool corruptHorizontalPatch(img.Image image, Rect patch) {
    var reference = GraphicsUtilities.getPixels(
      image,
      patch.left.toInt(),
      patch.top.toInt(),
      1,
      patch.height.toInt(),
    );

    for (int i = 1; i < patch.width; i++) {
      var column = GraphicsUtilities.getPixels(
        image,
        patch.left.toInt() + i,
        patch.top.toInt(),
        1,
        patch.height.toInt(),
      );
      if (!listEquals(reference, column)) {
        return true;
      }
    }

    return false;
  }

  static bool corruptVerticalPatch(img.Image image, Rect patch) {
    var reference = GraphicsUtilities.getPixels(
      image,
      patch.left.toInt(),
      patch.top.toInt(),
      patch.width.toInt(),
      1,
    );

    for (int i = 1; i < patch.height; i++) {
      var row = GraphicsUtilities.getPixels(
        image,
        patch.left.toInt(),
        patch.top.toInt() + i,
        patch.width.toInt(),
        1,
      );
      if (!listEquals(reference, row)) {
        return true;
      }
    }

    return false;
  }
}
