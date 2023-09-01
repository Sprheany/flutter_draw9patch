// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_draw9patch/model/nine_patch_chunk.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/image_ext.dart';
import 'package:flutter_draw9patch/utils/pair.dart';
import 'package:image/image.dart' as img;

/// Inset lengths from all edges of a rectangle. `left` and `top` are measured
/// from the left and top
/// edges, while `right` and `bottom` are measured from the right and bottom
/// edges, respectively.
class Bounds {
  int left = 0;
  int top = 0;
  int right = 0;
  int bottom = 0;

  bool nonZero() {
    return left != 0 || top != 0 || right != 0 || bottom != 0;
  }

  @override
  bool operator ==(other) {
    return other is Bounds && left == other.left && top == other.top && right == other.right && bottom == other.bottom;
  }

  @override
  int get hashCode => left.hashCode + top.hashCode + right.hashCode + bottom.hashCode;
}

class NinePatch {
  NinePatch(img.Image data, PatchInfo patchInfo, int width, int height) {
    if (width < 3 || height < 3) {
      throw "image must be at least 3x3 (1x1 image with 1 pixel border)";
    }

    horizontal_stretch_regions = patchInfo.horizontalPatchMarkers.map((e) => Pair(e.first - 1, e.second - 1)).toList();
    vertical_stretch_regions = patchInfo.verticalPatchMarkers.map((e) => Pair(e.first - 1, e.second - 1)).toList();
    padding = Rect.fromLTRB(
      patchInfo.horizontalPadding.first.toDouble(),
      patchInfo.verticalPadding.first.toDouble(),
      patchInfo.horizontalPadding.second.toDouble(),
      patchInfo.verticalPadding.second.toDouble(),
    );

    // Fill the region colors of the 9-patch.
    final int num_rows = CalculateSegmentCount(horizontal_stretch_regions, width - 2);
    final int num_cols = CalculateSegmentCount(vertical_stretch_regions, height - 2);
    if (num_rows * num_cols > 0x7f) {
      throw "too many regions in 9-patch";
    }

    CalculateRegionColors(data, width - 2, height - 2);
  }

  // Fills out_colors with each 9-patch section's color. If the whole section is
  // transparent,
  // it gets the special TRANSPARENT color. If the whole section is the same
  // color, it is assigned
  // that color. Otherwise it gets the special NO_COLOR color.
  //
  // Note that the rows contain the 9-patch 1px border, and the indices in the
  // stretch regions are
  // already offset to exclude the border. This means that each time the rows are
  // accessed,
  // the indices must be offset by 1.
  //
  // width and height also include the 9-patch 1px border.
  void CalculateRegionColors(img.Image rows, int width, int height) {
    int next_top = 0;
    Bounds bounds = Bounds();
    int row_index = 0;
    while (next_top != height) {
      if (row_index != vertical_stretch_regions.length) {
        Pair row_iter = vertical_stretch_regions[row_index];
        if (next_top != row_iter.first) {
          // This is a fixed segment.
          // Offset the bounds by 1 to accommodate the border.
          bounds.top = next_top + 1;
          bounds.bottom = row_iter.first + 1;
          next_top = row_iter.first;
        } else {
          // This is a stretchy segment.
          // Offset the bounds by 1 to accommodate the border.
          bounds.top = row_iter.first + 1;
          bounds.bottom = row_iter.second + 1;
          next_top = row_iter.second;
          ++row_index;
        }
      } else {
        // This is the end, fixed section.
        // Offset the bounds by 1 to accommodate the border.
        bounds.top = next_top + 1;
        bounds.bottom = height + 1;
        next_top = height;
      }

      int next_left = 0;
      int col_index = 0;
      while (next_left != width) {
        if (col_index != horizontal_stretch_regions.length) {
          Pair col_iter = horizontal_stretch_regions[col_index];
          if (next_left != col_iter.first) {
            // This is a fixed segment.
            // Offset the bounds by 1 to accommodate the border.
            bounds.left = next_left + 1;
            bounds.right = col_iter.first + 1;
            next_left = col_iter.first;
          } else {
            // This is a stretchy segment.
            // Offset the bounds by 1 to accommodate the border.
            bounds.left = col_iter.first + 1;
            bounds.right = col_iter.second + 1;
            next_left = col_iter.second;
            ++col_index;
          }
        } else {
          // This is the end, fixed section.
          // Offset the bounds by 1 to accommodate the border.
          bounds.left = next_left + 1;
          bounds.right = width + 1;
          next_left = width;
        }
        region_colors.add(GetRegionColor(rows, bounds));
      }
    }
  }

  int GetRegionColor(img.Image rows, Bounds region) {
    // Sample the first pixel to compare against.
    int expected_color = rows.getPixel(region.left, region.top).color;
    for (int y = region.top; y < region.bottom; y++) {
      for (int x = region.left; x < region.right; x++) {
        int color = rows.getPixel(x, y).color;
        if (get_alpha(color) == 0) {
          // The color is transparent.
          // If the expectedColor is not transparent, NO_COLOR.
          if (get_alpha(expected_color) != 0) {
            return NinePatchChunk.NO_COLOR;
          }
        } else if (color != expected_color) {
          return NinePatchChunk.NO_COLOR;
        }
      }
    }

    if (get_alpha(expected_color) == 0) {
      return NinePatchChunk.TRANSPARENT_COLOR;
    }
    return expected_color;
  }

  int get_alpha(int color) {
    return (color & 0xff000000) >> 24;
  }

  int CalculateSegmentCount(List<Pair> stretch_regions, int length) {
    if (stretch_regions.isEmpty) {
      return 0;
    }

    final bool start_is_fixed = stretch_regions.first.first != 0;
    final bool end_is_fixed = stretch_regions.last.second != length;
    int modifier = 0;
    if (start_is_fixed && end_is_fixed) {
      modifier = 1;
    } else if (!start_is_fixed && !end_is_fixed) {
      modifier = -1;
    }
    return stretch_regions.length * 2 + modifier;
  }

  /// 9-patch content padding/insets. All positions are relative to the 9-patch
  /// NOT including the 1px thick source border.
  Rect padding = Rect.zero;

  /// Optical layout bounds/insets. This overrides the padding for
  /// layout purposes. All positions are relative to the 9-patch
  /// NOT including the 1px thick source border.
  /// See
  /// https://developer.android.com/about/versions/android-4.3.html#OpticalBounds
  Rect layout_bounds = Rect.zero;

  /// Outline of the image, calculated based on opacity.
  Rect outline = Rect.zero;

  /// The computed radius of the outline. If non-zero, the outline is a
  /// rounded-rect.
  double outline_radius = 0.0;

  /// The largest alpha value within the outline.
  int outline_alpha = 0x000000ff;

  /// Horizontal regions of the image that are stretchable.
  /// All positions are relative to the 9-patch
  /// NOT including the 1px thick source border.
  List<Pair> horizontal_stretch_regions = [];

  /// Vertical regions of the image that are stretchable.
  /// All positions are relative to the 9-patch
  /// NOT including the 1px thick source border.
  List<Pair> vertical_stretch_regions = [];

  /// The colors within each region, fixed or stretchable.
  /// For w*h regions, the color of region (x,y) is addressable
  /// via index y*w + x.
  List<int> region_colors = [];

  /// Returns serialized data containing the original basic 9-patch meta data.
  /// Optical layout bounds and round rect outline data must be serialized
  /// separately using SerializeOpticalLayoutBounds() and
  /// SerializeRoundedRectOutline().
  Uint8List SerializeBase() {
    NinePatchChunk data = NinePatchChunk();
    data.numXDivs = horizontal_stretch_regions.length * 2;
    data.numYDivs = vertical_stretch_regions.length * 2;
    data.numColors = region_colors.length;
    data.paddingLeft = padding.left.toInt();
    data.paddingRight = padding.right.toInt();
    data.paddingTop = padding.top.toInt();
    data.paddingBottom = padding.bottom.toInt();

    data.xDivsOffset = 32;
    data.yDivsOffset = data.xDivsOffset + (data.numXDivs * 4);
    data.colorsOffset = data.yDivsOffset + (data.numYDivs * 4);

    return data.serialize(horizontal_stretch_regions, vertical_stretch_regions, region_colors);
  }

  /// Serializes the layout bounds.
  Uint8List SerializeLayoutBounds(int outLen) {
    return Uint8List(0);
  }

  /// Serializes the rounded-rect outline.
  Uint8List SerializeRoundedRectOutline(int outLen) {
    return Uint8List(0);
  }

  @override
  String toString() {
    return """NinePatch{
    horizontalStretch: ${horizontal_stretch_regions.join(" ")}
    verticalStretch: ${vertical_stretch_regions.join(" ")}
    padding: $padding
    bounds: $layout_bounds
    outline: $outline rad=$outline_radius alpha=$outline_alpha
    regionColors: $region_colors
}""";
  }
}
