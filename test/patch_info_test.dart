import 'dart:ui';

import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  img.Image createImage(List<String> data) {
    int h = data.length;
    int w = data[0].length;

    final image = img.Image(width: w, height: h, numChannels: 4);

    for (var p in image) {
      var c = data[p.y][p.x];
      int color = 0;
      if (c == '*') {
        color = BLACK_TICK;
      } else if (c == 'R') {
        color = RED_TICK;
      }

      image.setPixelRgba(
        p.x,
        p.y,
        Color(color).red,
        Color(color).green,
        Color(color).blue,
        Color(color).alpha,
      );
    }

    return image;
  }

  test("PatchInfo", () async {
    img.Image image = createImage([
      "0123**6789",
      "1........*",
      "*........*",
      "3........*",
      "412*****89",
    ]);
    PatchInfo pi = PatchInfo(image);

    // The left and top patch markers don't begin from the first pixel
    expect(pi.horizontalStartWithPatch, false);
    expect(pi.verticalStartWithPatch, false);

    // There should be one patch in the middle where the left and top patch markers intersect
    expect(1, pi.patches.length);
    expect(const Rect.fromLTWH(4, 2, 2, 1), pi.patches[0]);

    // There should be 2 horizontal stretchable areas - area below the top marker but excluding
    // the main patch
    expect(2, pi.horizontalPatches.length);
    expect(const Rect.fromLTWH(4, 1, 2, 1), pi.horizontalPatches[0]);
    expect(const Rect.fromLTWH(4, 3, 2, 1), pi.horizontalPatches[1]);

    // Similarly, there should be 2 vertical stretchable areas
    expect(2, pi.verticalPatches.length);
    expect(const Rect.fromLTWH(1, 2, 3, 1), pi.verticalPatches[0]);
    expect(const Rect.fromLTWH(6, 2, 3, 1), pi.verticalPatches[1]);

    // The should be 4 fixed regions - the regions that don't fall under the patches
    expect(4, pi.fixed.length);

    // The horizontal padding is described by the bottom bar.
    // In this case, there is a 2 pixel (pixels 1 & 2) padding at start and 1 pixel (pixel 8)
    // padding at end
    expect(2, pi.horizontalPadding.first);
    expect(1, pi.horizontalPadding.second);

    // The vertical padding is described by the bar at the right.
    // In this case, there is no padding as the content area matches the image area
    expect(0, pi.verticalPadding.first);
    expect(0, pi.verticalPadding.second);
  });

  test("Padding", () {
    img.Image image = createImage([
      "0123**6789",
      "1.........",
      "2.........",
      "3........*",
      "4........*",
      "5***456789",
    ]);
    PatchInfo pi = PatchInfo(image);

    // 0 pixel padding at start and 5 pixel padding at the end (pixels 4 through 8 inclusive)
    expect(0, pi.horizontalPadding.first);
    expect(5, pi.horizontalPadding.second);

    // 2 pixel padding at the start and 0 at the end
    expect(2, pi.verticalPadding.first);
    expect(0, pi.verticalPadding.second);
  });

  // make sure that the presence of layout bound markers doesn't affect patch/padding info
  test("IgnoreLayoutBoundMarkers", () {
    img.Image image = createImage([
      "0RR3**6789",
      "R........R",
      "*.........",
      "*........*",
      "4........*",
      "5***456R89",
    ]);
    PatchInfo pi = PatchInfo(image);

    expect(pi.horizontalStartWithPatch, false);

    expect(1, pi.patches.length);
    expect(2, pi.verticalPatches.length);
    expect(2, pi.horizontalPatches.length);
  });
}
