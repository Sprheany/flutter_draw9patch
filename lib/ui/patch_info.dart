import 'package:flutter/rendering.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/utils/graphics_utilities.dart';
import 'package:flutter_draw9patch/utils/image_ext.dart';
import 'package:flutter_draw9patch/utils/pair.dart';
import 'package:image/image.dart';

class PatchInfo {
  /// Areas of the image that are stretchable in both directions.
  late final List<Rect> patches;

  /// Areas of the image that are not stretchable in either direction.
  late final List<Rect> fixed;

  /// Areas of image stretchable horizontally.
  late final List<Rect> horizontalPatches;

  /// Areas of image stretchable vertically.
  late final List<Rect> verticalPatches;

  /// Bounds of horizontal patch markers.
  late final List<Pair> horizontalPatchMarkers;

  /// Bounds of horizontal padding markers.
  late final List<Pair> horizontalPaddingMarkers;

  /// Bounds of vertical patch markers.
  late final List<Pair> verticalPatchMarkers;

  /// Bounds of vertical padding markers.
  late final List<Pair> verticalPaddingMarkers;

  late final bool verticalStartWithPatch;
  late final bool horizontalStartWithPatch;

  /// Beginning and end padding in the horizontal direction
  late final Pair horizontalPadding;

  /// Beginning and end padding in the vertical direction
  late final Pair verticalPadding;

  final Image image;

  PatchInfo(this.image) {
    int width = image.width;
    int height = image.height;

    var row = GraphicsUtilities.getPixels(image, 0, 0, width, 1);
    var column = GraphicsUtilities.getPixels(image, 0, 0, 1, height);

    P left = getPatches(column);
    verticalStartWithPatch = left.startsWithPatch;
    verticalPatchMarkers = left.patches;

    P top = getPatches(row);
    horizontalStartWithPatch = top.startsWithPatch;
    horizontalPatchMarkers = top.patches;

    fixed = getRectangles(left.fixed, top.fixed);
    patches = getRectangles(left.patches, top.patches);

    if (fixed.isNotEmpty) {
      horizontalPatches = getRectangles(left.fixed, top.patches);
      verticalPatches = getRectangles(left.patches, top.fixed);
    } else {
      if (top.fixed.isNotEmpty) {
        horizontalPatches = [];
        verticalPatches = getVerticalRectangles(top.fixed);
      } else if (left.fixed.isNotEmpty) {
        horizontalPatches = getHorizontalRectangles(left.fixed);
        verticalPatches = [];
      } else {
        horizontalPatches = verticalPatches = [];
      }
    }

    row = GraphicsUtilities.getPixels(image, 0, height - 1, width, 1);
    column = GraphicsUtilities.getPixels(image, width - 1, 0, 1, height);

    top = getPatches(row);
    horizontalPaddingMarkers = top.patches;
    horizontalPadding = getPadding(top.fixed);

    left = getPatches(column);
    verticalPaddingMarkers = left.patches;
    verticalPadding = getPadding(left.fixed);
  }

  List<Rect> getVerticalRectangles(List<Pair> topPairs) {
    List<Rect> rectangles = [];
    for (Pair top in topPairs) {
      int x = top.first;
      int width = top.second - top.first;

      rectangles.add(Rect.fromLTWH(x.toDouble(), 1, width.toDouble(), image.height - 2));
    }
    return rectangles;
  }

  List<Rect> getHorizontalRectangles(List<Pair> leftPairs) {
    List<Rect> rectangles = [];
    for (Pair left in leftPairs) {
      int y = left.first;
      int height = left.second - left.first;

      rectangles.add(Rect.fromLTWH(1, y.toDouble(), image.width - 2, height.toDouble()));
    }
    return rectangles;
  }

  Pair getPadding(List<Pair> pairs) {
    if (pairs.isEmpty) {
      return Pair(0, 0);
    } else if (pairs.length == 1) {
      if (pairs[0].first == 1) {
        return Pair(pairs[0].second - pairs[0].first, 0);
      } else {
        return Pair(0, pairs[0].second - pairs[0].first);
      }
    } else {
      int index = pairs.length - 1;
      return Pair(pairs[0].second - pairs[0].first, pairs[index].second - pairs[index].first);
    }
  }

  List<Rect> getRectangles(List<Pair> leftPairs, List<Pair> topPairs) {
    List<Rect> rectangles = [];
    for (Pair left in leftPairs) {
      int y = left.first;
      int height = left.second - left.first;
      for (Pair top in topPairs) {
        int x = top.first;
        int width = top.second - top.first;

        rectangles.add(Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()));
      }
    }
    return rectangles;
  }

  P getPatches(List<Pixel> pixels) {
    int lastIndex = 1;
    int lastPixel;
    bool first = true;
    bool startWithPatch = false;

    List<Pair> fixed = [];
    List<Pair> patches = [];
    if (pixels.length < 3) throw "Invalid 9-patch, cannot be less than 3 pixels in a dimension";

    // ignore layout bound markers for the purpose of patch calculation
    lastPixel = pixels[1].color != RED_TICK ? pixels[1].color : 0;

    for (int i = 1; i < pixels.length - 1; i++) {
      // ignore layout bound markers for the purpose of patch calculation
      int pixel = pixels[i].color != RED_TICK ? pixels[i].color : 0;

      if (pixel != lastPixel) {
        if (lastPixel == BLACK_TICK) {
          if (first) startWithPatch = true;
          patches.add(Pair(lastIndex, i));
        } else {
          fixed.add(Pair(lastIndex, i));
        }
        first = false;

        lastIndex = i;
        lastPixel = pixel;
      }
    }
    if (lastPixel == BLACK_TICK) {
      if (first) startWithPatch = true;
      patches.add(Pair(lastIndex, (pixels.length - 1)));
    } else {
      fixed.add(Pair(lastIndex, (pixels.length - 1)));
    }

    if (patches.isEmpty) {
      patches.add(Pair(1, (pixels.length - 1)));
      startWithPatch = true;
      fixed.clear();
    }

    return P(fixed, patches, startWithPatch);
  }

  List<Rect> get stretchableArea => patches.map((e) => e.translate(-1, -1)).toList();

  String get contentPadding =>
      "left: ${horizontalPadding.first}, top: ${verticalPadding.first}, right: ${horizontalPadding.second}, bottom: ${verticalPadding.second}";

  @override
  String toString() {
    return """PatchInfo{
    patches=$patches,
    fixed=$fixed,
    horizontalPatches=$horizontalPatches,
    verticalPatches=$verticalPatches,
    horizontalPatchMarkers=$horizontalPatchMarkers,
    horizontalPaddingMarkers=$horizontalPaddingMarkers,
    verticalPatchMarkers=$verticalPatchMarkers,
    verticalPaddingMarkers=$verticalPaddingMarkers,
    verticalStartWithPatch=$verticalStartWithPatch,
    horizontalStartWithPatch=$horizontalStartWithPatch,
    horizontalPadding=$horizontalPadding,
    verticalPadding=$verticalPadding
}""";
  }
}

class P {
  final List<Pair> fixed;
  final List<Pair> patches;
  final bool startsWithPatch;

  P(
    this.fixed,
    this.patches,
    this.startsWithPatch,
  );

  @override
  String toString() {
    return """P{
    fixed=$fixed,
    patches=$patches,
    startsWithPatch=$startsWithPatch
}""";
  }
}
