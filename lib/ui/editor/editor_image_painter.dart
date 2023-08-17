import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/editor/image_viewer.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/utils/corrupt_patch.dart';
import 'package:flutter_draw9patch/utils/paint_ext.dart';

class EditorImagePainter extends CustomPainter {
  final painter = Paint();

  final Image? texture;

  final Image image;
  final PatchInfo patchInfo;

  final double zoomFraction;

  final Size scaledSize;

  bool showPatches;

  bool showLock;
  bool locked;

  double lastPositionX;
  double lastPositionY;

  bool showCursor;

  bool showBadPatches;
  List<Rect> corruptedPatches;

  bool drawingLine;
  double lineFromX;
  double lineFromY;
  double lineToX;
  double lineToY;
  bool showDrawingLine;

  final List<Rect> hoverHighlightRegions;

  bool isEditMode;
  UpdateRegion? editRegion;
  final List<Rect> editHighlightRegions;
  Rect editPatchRegion;

  EditorImagePainter({
    required this.texture,
    required ImageData imageData,
    required this.zoomFraction,
    required this.showPatches,
    required this.showBadPatches,
    required this.showDrawingLine,
    required this.showCursor,
    required this.showLock,
    required this.locked,
    required this.lastPositionX,
    required this.lastPositionY,
    required this.isEditMode,
    required this.editRegion,
    required this.editHighlightRegions,
    required this.editPatchRegion,
    required this.drawingLine,
    required this.lineFromX,
    required this.lineFromY,
    required this.lineToX,
    required this.lineToY,
    required this.hoverHighlightRegions,
  })  : image = imageData.uiImage,
        patchInfo = imageData.patchInfo,
        corruptedPatches =
            showBadPatches ? CorruptPatch.findBadPatches(imageData.image, imageData.patchInfo) : List.empty(),
        scaledSize = Size(imageData.image.width * zoomFraction, imageData.image.height * zoomFraction);

  @override
  void paint(Canvas canvas, Size size) {
    double x = (size.width - scaledSize.width) / 2;
    double y = (size.height - scaledSize.height) / 2;

    // background & texture

    canvas.save();

    canvas.translate(x, y);

    if (texture != null) {
      double srcW = min(scaledSize.width, texture!.width.toDouble());
      double srcH = min(scaledSize.height, texture!.height.toDouble());

      canvas.drawImageRect(
        texture!,
        Rect.fromLTWH(0, 0, srcW, srcH),
        Offset.zero & scaledSize,
        Paint()..imageFilter = ImageFilter.blur(tileMode: TileMode.repeated),
      );
    }
    // image
    canvas.scale(zoomFraction, zoomFraction);
    canvas.drawImage(image, Offset.zero, Paint());

    // patches
    if (showPatches) {
      painter.fill.color = PATCH_COLOR;
      for (Rect patch in patchInfo.patches) {
        canvas.drawRect(patch, painter);
      }
      painter.fill.color = PATCH_ONEWAY_COLOR;
      for (Rect patch in patchInfo.horizontalPatches) {
        canvas.drawRect(patch, painter);
      }
      for (Rect patch in patchInfo.verticalPatches) {
        canvas.drawRect(patch, painter);
      }
    }

    // corrupted patches
    if (corruptedPatches.isNotEmpty) {
      painter.stroke
        ..color = CORRUPTED_COLOR
        ..strokeWidth = 3.0 / zoomFraction;
      for (Rect patch in corruptedPatches) {
        canvas.drawRRect(
          RRect.fromLTRBXY(
            patch.left - 2.0 / zoomFraction,
            patch.top - 2.0 / zoomFraction,
            patch.right + 2.0 / zoomFraction,
            patch.bottom + 2.0 / zoomFraction,
            6.0 / zoomFraction,
            6.0 / zoomFraction,
          ),
          painter,
        );
      }
    }

    // lock
    if (showLock && locked) {
      canvas.save();
      painter.color = LOCK_COLOR;
      canvas.drawRect(Rect.fromLTWH(1, 1, image.width - 2, image.height - 2), painter);

      painter.color = STRIPES_COLOR;
      canvas.translate(1, 1);
      paintStripes(canvas, painter, image.width - 2, image.height - 2);
      canvas.translate(-1, -1);
      canvas.restore();
    }
    canvas.restore();

    if (drawingLine && showDrawingLine) {
      canvas.save();
      painter.fill
        ..color = Color(BLACK_TICK)
        ..colorFilter = const ColorFilter.mode(WHITE_COLOR, BlendMode.xor);

      x = min(lineFromX, lineToX);
      y = min(lineFromY, lineToY);
      double w = (lineFromX - lineToX).abs() + 1;
      double h = (lineFromY - lineToY).abs() + 1;

      x = x * zoomFraction;
      y = y * zoomFraction;
      w = w * zoomFraction;
      h = h * zoomFraction;

      double left = (size.width - scaledSize.width) / 2;
      double top = (size.height - scaledSize.height) / 2;

      x += left;
      y += top;

      canvas.drawRect(Rect.fromLTWH(x, y, w, h), painter);
      canvas.restore();
    }

    if (showCursor) {
      canvas.save();
      painter
        ..color = BLUE_COLOR
        ..colorFilter = const ColorFilter.mode(
          WHITE_COLOR,
          BlendMode.xor,
        );
      canvas.drawRect(
          Rect.fromLTWH(
            lastPositionX - zoomFraction / 2,
            (lastPositionY - zoomFraction) / 2,
            zoomFraction,
            zoomFraction,
          ),
          painter);
      canvas.restore();
    }

    // hover highlight
    painter.fill.color = HIGHLIGHT_REGION_COLOR;
    for (Rect r in hoverHighlightRegions) {
      canvas.drawRect(r, painter);
    }

    if (isEditMode && editRegion != null) {
      painter.fill.color = HIGHLIGHT_REGION_COLOR;
      for (Rect r in editHighlightRegions) {
        canvas.drawRect(r, painter);
      }
      painter.fill.color = Color(BLACK_TICK);
      canvas.drawRect(editPatchRegion, painter);
    }
  }

  @override
  bool shouldRepaint(covariant EditorImagePainter oldDelegate) => true;

  void paintStripes(Canvas g, Paint painter, double width, double height) {
    //draws pinstripes at the angle specified in this class
    //and at the given distance apart
    Rect area = Rect.fromLTWH(0, 0, width, height);
    g.clipRect(area);

    painter.stroke
      ..color = STRIPES_COLOR
      ..strokeWidth = STRIPES_WIDTH;

    double hypLength = sqrt((width * width) + (height * height));

    double radians = STRIPES_ANGLE * pi / 180;
    g.rotate(radians);

    double spacing = STRIPES_SPACING;
    spacing += STRIPES_WIDTH;
    int numLines = hypLength ~/ spacing;

    for (int i = 0; i < numLines; i++) {
      double x = i * spacing;
      g.drawLine(Offset(x, -hypLength), Offset(x, hypLength), painter);
    }
  }
}
