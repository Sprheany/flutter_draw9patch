// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/action_provider.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/editor/editor_image_painter.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/utils/pair.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;

class ImageViewer extends ConsumerStatefulWidget {
  const ImageViewer({super.key});

  @override
  ConsumerState<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  double zoomFraction = DEFAULT_ZOOM * 0.01;

  bool locked = false;

  double lastPositionX = 0;
  double lastPositionY = 0;

  bool showCursor = false;
  MouseCursor cursor = MouseCursor.defer;

  bool drawingLine = false;
  double lineFromX = 0;
  double lineFromY = 0;
  double lineToX = 0;
  double lineToY = 0;
  bool showDrawingLine = false;

  final List<Rect> hoverHighlightRegions = <Rect>[];
  String? toolTipText;

  /// Indicates whether we are currently in edit mode.
  /// All fields with the prefix 'edit' are valid only when in edit mode.
  bool isEditMode = false;

  /// Region being edited.
  UpdateRegion? editRegion;

  /// The start and end points corresponding to the region being edited.
  /// During an edit sequence, the start point is constant and the end varies based on the
  /// mouse location.
  final Pair editSegment = Pair(0, 0);

  /// Regions to highlight based on the current edit.
  final List<Rect> editHighlightRegions = [];

  /// The actual patch location in the image being edited.
  Rect editPatchRegion = Rect.zero;

  late img.Image image;
  late PatchInfo patchInfo;

  double width = 0;
  double height = 0;

  @override
  Widget build(BuildContext context) {
    final imageData = ref.watch(createImageDataProvider).valueOrNull;
    if (imageData == null) {
      return Container(color: EDITOR_BACKGROUND_COLOR);
    }

    image = imageData.image;
    patchInfo = imageData.patchInfo;

    zoomFraction = ref.watch(zoomProvider) * 0.01;

    return LayoutBuilder(builder: (context, constraints) {
      width = max(constraints.minWidth, image.width * zoomFraction + STRETCH_MARGIN);
      height = max(constraints.minHeight, image.height * zoomFraction + STRETCH_MARGIN);

      return Listener(
        onPointerDown: onPointerDown,
        onPointerHover: onPointerHover,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        child: MouseRegion(
          cursor: cursor,
          onExit: (e) {
            hoverHighlightRegions.clear();
          },
          child: Stack(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: EditorImagePainter(
                  texture: ref.watch(createTextureProvider).valueOrNull,
                  zoomFraction: zoomFraction,
                  imageData: imageData,
                  showBadPatches: ref.watch(showBadPatchesProvider),
                  showPatches: ref.watch(showPatchesProvider),
                  showCursor: showCursor,
                  showLock: ref.watch(showLockProvider),
                  locked: locked,
                  hoverHighlightRegions: hoverHighlightRegions,
                  drawingLine: drawingLine,
                  lineFromX: lineFromX,
                  lineFromY: lineFromY,
                  lineToX: lineToX,
                  lineToY: lineToY,
                  showDrawingLine: showDrawingLine,
                  isEditMode: isEditMode,
                  editRegion: editRegion,
                  editHighlightRegions: editHighlightRegions,
                  editPatchRegion: editPatchRegion,
                  lastPositionX: lastPositionX,
                  lastPositionY: lastPositionY,
                ),
              ),
              Center(
                child: Text(
                  toolTipText ?? "",
                  style: const TextStyle(color: Colors.red),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  void onPointerUp(event) {
    double x = imageXCoordinate(event.localPosition.dx);
    double y = imageYCoordinate(event.localPosition.dy);

    endDrawingLine();
    endEditingRegion(x.toInt(), y.toInt());

    currentMode = DrawMode.PATCH;
    setState(() {});
  }

  void onPointerMove(event) {
    double x = imageXCoordinate(event.localPosition.dx);
    double y = imageYCoordinate(event.localPosition.dy);

    ref.read(pointXProvider.notifier).state = max(0, min(x.toInt(), image.width - 1));
    ref.read(pointYProvider.notifier).state = max(0, min(y.toInt(), image.height - 1));

    if (!checkLockedRegion(x, y)) {
      // use the stored button, see note above
      moveLine(x, y);
    }

    updateEditRegion(x.toInt(), y.toInt());

    setState(() {});
  }

  void onPointerHover(event) {
    double x = imageXCoordinate(event.localPosition.dx);
    double y = imageYCoordinate(event.localPosition.dy);

    ref.read(pointXProvider.notifier).state = max(0, min(x.toInt(), image.width - 1));
    ref.read(pointYProvider.notifier).state = max(0, min(y.toInt(), image.height - 1));

    checkLockedRegion(x, y);

    updateHoverRegion(x, y);

    setState(() {});
  }

  void onPointerDown(event) {
    // Update the drawing mode looking at the current state of modifier (shift/ctrl)
    // keys. This is done here instead of retrieving it again in MouseDragged
    // below, because on linux, calling MouseEvent.getButton() for the drag
    // event returns 0, which appears to be technically correct (no button
    // changed state).
    // updateDrawMode(event);

    double x = imageXCoordinate(event.localPosition.dx);
    double y = imageYCoordinate(event.localPosition.dy);

    startDrawingLine(x, y);

    if (currentMode == DrawMode.PATCH) {
      startEditingRegion(x, y);
    } else {
      hoverHighlightRegions.clear();
      cursor = MouseCursor.defer;
    }
    setState(() {});
  }

  void updateDrawMode(RawKeyEvent event) {
    if (event.isShiftPressed) {
      currentMode = DrawMode.ERASE;
    } else if (event.isControlPressed) {
      currentMode = DrawMode.LAYOUT_BOUND;
    } else {
      currentMode = DrawMode.PATCH;
    }
  }

  UpdateRegionInfo findVerticalPatch(double x, double y) {
    List<Pair> markers;
    UpdateRegion region;

    // Given the mouse x location, we need to determine if we need to map this edit to
    // the patch info at the left, or the padding info at the right. We make this decision
    // based on whichever is closer, so if the mouse x is in the left half of the image,
    // we are editing the left patch, else the right padding.
    if (x < image.width / 2) {
      markers = patchInfo.verticalPatchMarkers;
      region = UpdateRegion.LEFT_PATCH;
    } else {
      markers = patchInfo.verticalPaddingMarkers;
      region = UpdateRegion.RIGHT_PADDING;
    }

    return getContainingPatch(markers, y, region);
  }

  UpdateRegionInfo findHorizontalPatch(double x, double y) {
    List<Pair> markers;
    UpdateRegion region;

    if (y < image.height / 2) {
      markers = patchInfo.horizontalPatchMarkers;
      region = UpdateRegion.TOP_PATCH;
    } else {
      markers = patchInfo.horizontalPaddingMarkers;
      region = UpdateRegion.BOTTOM_PADDING;
    }

    return getContainingPatch(markers, x, region);
  }

  UpdateRegionInfo getContainingPatch(List<Pair> patches, double a, UpdateRegion region) {
    for (Pair p in patches) {
      if (p.first <= a && p.second > a) {
        return UpdateRegionInfo(region, p);
      }

      if (p.first > a) {
        break;
      }
    }

    return UpdateRegionInfo(region, null);
  }

  void updateHoverRegion(double x, double y) {
    // find regions to highlight based on the horizontal and vertical patches that
    // cover this (x, y)
    UpdateRegionInfo vertical = findVerticalPatch(x, y);
    UpdateRegionInfo horizontal = findHorizontalPatch(x, y);
    computeHoverHighlightRegions(vertical, horizontal);
    computeHoverRegionTooltip(vertical, horizontal);

    // change cursor if (x,y) is at the edge of either of the regions
    UpdateRegionInfo? updateRegion = pickUpdateRegion(x, y, vertical, horizontal);
    setCursorForRegion(x, y, updateRegion);
  }

  void startEditingRegion(double x, double y) {
    hoverHighlightRegions.clear();
    isEditMode = false;
    editRegion = null;

    UpdateRegionInfo vertical = findVerticalPatch(x, y);
    UpdateRegionInfo horizontal = findHorizontalPatch(x, y);
    UpdateRegionInfo? updateRegion = pickUpdateRegion(x, y, vertical, horizontal);
    setCursorForRegion(x, y, updateRegion);

    if (updateRegion != null) {
      // edit an existing patch
      editRegion = updateRegion.region;
      isEditMode = true;

      Edge? e;
      switch (editRegion) {
        case UpdateRegion.LEFT_PATCH:
        case UpdateRegion.RIGHT_PADDING:
          e = getClosestEdge(y, updateRegion.segment!);
          break;
        case UpdateRegion.TOP_PATCH:
        case UpdateRegion.BOTTOM_PADDING:
          e = getClosestEdge(x, updateRegion.segment!);
          break;
        default:
        // assert false : this.editRegion;
      }

      int first = updateRegion.segment!.first;
      int second = updateRegion.segment!.second;

      // The edge being edited should always be the end point in editSegment.
      bool start = e == Edge.START;
      editSegment.first = start ? second : first;
      editSegment.second = start ? first : second;

      // clear the current patch data
      flushEditPatchData(Colors.transparent);
    } else if ((editRegion = findNewPatchRegion(x, y)) != null) {
      // create a new patch
      isEditMode = true;

      bool verticalPatch = editRegion == UpdateRegion.LEFT_PATCH || editRegion == UpdateRegion.RIGHT_PADDING;

      x = clamp(x.toInt(), 1, image.width - 1).toDouble();
      y = clamp(y.toInt(), 1, image.height - 1).toDouble();

      editSegment.first = editSegment.second = verticalPatch ? y.toInt() : x.toInt();
    }

    if (isEditMode) {
      computeEditHighlightRegions();
    }
  }

  void endEditingRegion(int x, int y) {
    if (!isEditMode) {
      return;
    }

    x = clamp(x, 1, image.width - 1);
    y = clamp(y, 1, image.height - 1);

    switch (editRegion) {
      case UpdateRegion.LEFT_PATCH:
      case UpdateRegion.RIGHT_PADDING:
        editSegment.second = y;
        break;
      case UpdateRegion.TOP_PATCH:
      case UpdateRegion.BOTTOM_PADDING:
        editSegment.second = x;
        break;
      default:
      // assert false : editRegion;
    }

    flushEditPatchData(Colors.black);

    hoverHighlightRegions.clear();
    cursor = MouseCursor.defer;
    patchesChanged();

    isEditMode = false;
    editRegion = null;
  }

  void updateEditRegion(int x, int y) {
    if (!isEditMode) {
      return;
    }

    x = clamp(x, 1, image.width - 1);
    y = clamp(y, 1, image.height - 1);

    switch (editRegion) {
      case UpdateRegion.LEFT_PATCH:
      case UpdateRegion.RIGHT_PADDING:
        editSegment.second = y;
        break;
      case UpdateRegion.TOP_PATCH:
      case UpdateRegion.BOTTOM_PADDING:
        editSegment.second = x;
        break;
      default:
    }

    computeEditHighlightRegions();
  }

  /// Returns the type of patch that should be created given the initial mouse location.
  UpdateRegion? findNewPatchRegion(double x, double y) {
    bool verticalPatch = y >= 0 && y <= image.height;
    bool horizontalPatch = x >= 0 && x <= image.width;

    // Heuristic: If the pointer is within the vertical bounds of the image,
    // then we create a patch on the left or right depending on which side of the image
    // the pointer is on
    if (verticalPatch) {
      if (x < 0) {
        return UpdateRegion.LEFT_PATCH;
      } else if (x > image.width) {
        return UpdateRegion.RIGHT_PADDING;
      }
    }

    // Similarly, if it is within the horizontal bounds of the image,
    // then create a patch at the top or bottom depending on its location relative to the image
    if (horizontalPatch) {
      if (y < 0) {
        return UpdateRegion.TOP_PATCH;
      } else if (y > image.height) {
        return UpdateRegion.BOTTOM_PADDING;
      }
    }

    return null;
  }

  void computeHoverHighlightRegions(UpdateRegionInfo vertical, UpdateRegionInfo horizontal) {
    hoverHighlightRegions.clear();
    if (vertical.segment != null) {
      hoverHighlightRegions.addAll(
        getHorizontalHighlightRegions(
          0,
          vertical.segment!.first,
          image.width,
          vertical.segment!.second - vertical.segment!.first,
        ),
      );
    }
    if (horizontal.segment != null) {
      hoverHighlightRegions.addAll(
        getVerticalHighlightRegions(
          horizontal.segment!.first,
          0,
          horizontal.segment!.second - horizontal.segment!.first,
          image.height,
        ),
      );
    }
  }

  void computeHoverRegionTooltip(UpdateRegionInfo vertical, UpdateRegionInfo horizontal) {
    String sb = "";

    if (vertical.segment != null) {
      if (vertical.region == UpdateRegion.LEFT_PATCH) {
        sb += ("Vertical Patch: ");
      } else {
        sb += ("Vertical Padding: ");
      }
      sb += "${vertical.segment!.first} - ${vertical.segment!.second} px";
    }

    if (horizontal.segment != null) {
      if (sb.isNotEmpty) {
        sb += (", ");
      }
      if (horizontal.region == UpdateRegion.TOP_PATCH) {
        sb += ("Horizontal Patch: ");
      } else {
        sb += ("Horizontal Padding: ");
      }
      sb += "${horizontal.segment!.first} - ${horizontal.segment!.second} px";
    }

    toolTipText = sb.isNotEmpty ? sb.toString() : null;
  }

  void computeEditHighlightRegions() {
    editHighlightRegions.clear();

    int f = editSegment.first;
    int s = editSegment.second;
    int mini = min(f, s);
    int diff = (f - s).abs();

    int imageWidth = image.width;
    int imageHeight = image.height;

    switch (editRegion) {
      case UpdateRegion.LEFT_PATCH:
        editPatchRegion = displayCoordinates(Rect.fromLTWH(0, mini.toDouble(), 1, diff.toDouble()));
        editHighlightRegions.addAll(getHorizontalHighlightRegions(0, mini, imageWidth, diff));
        break;
      case UpdateRegion.RIGHT_PADDING:
        editPatchRegion = displayCoordinates(Rect.fromLTWH(imageWidth - 1, mini.toDouble(), 1, diff.toDouble()));
        editHighlightRegions.addAll(getHorizontalHighlightRegions(0, mini, imageWidth, diff));
        break;
      case UpdateRegion.TOP_PATCH:
        editPatchRegion = displayCoordinates(Rect.fromLTWH(mini.toDouble(), 0, diff.toDouble(), 1));
        editHighlightRegions.addAll(getVerticalHighlightRegions(mini, 0, diff, imageHeight));
        break;
      case UpdateRegion.BOTTOM_PADDING:
        editPatchRegion = displayCoordinates(Rect.fromLTWH(mini.toDouble(), imageHeight - 1, diff.toDouble(), 1));
        editHighlightRegions.addAll(getVerticalHighlightRegions(mini, 0, diff, imageHeight));
        break;
      default:
      // assert false : editRegion;
    }
  }

  List<Rect> getHorizontalHighlightRegions(int x, int y, int w, int h) {
    List<Rect> l = [];

    // highlight the region within the image
    Rect r = displayCoordinates(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()));
    l.add(r);

    // add a 1 pixel line at the top and bottom that extends outside the image
    l.add(Rect.fromLTWH(0, r.top, width, 1));
    l.add(Rect.fromLTWH(0, r.top + r.height, width, 1));
    return l;
  }

  List<Rect> getVerticalHighlightRegions(int x, int y, int w, int h) {
    List<Rect> l = [];

    // highlight the region within the image
    Rect r = displayCoordinates(Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()));
    l.add(r);

    // add a 1 pixel line at the top and bottom that extends outside the image
    l.add(Rect.fromLTWH(r.left, 0, 1, height));
    l.add(Rect.fromLTWH(r.left + r.width, 0, 1, height));

    return l;
  }

  void setCursorForRegion(double x, double y, UpdateRegionInfo? region) {
    if (region != null) {
      cursor = getCursor(x, y, region);
    } else {
      cursor = MouseCursor.defer;
    }
  }

  MouseCursor getCursor(double x, double y, UpdateRegionInfo editRegion) {
    // Edge e;
    MouseCursor cursor = MouseCursor.defer;
    switch (editRegion.region) {
      case UpdateRegion.LEFT_PATCH:
      case UpdateRegion.RIGHT_PADDING:
        // e = getClosestEdge(y, editRegion.segment!);
        // cursor = (e == Edge.START) ? SystemMouseCursors.resizeUp : SystemMouseCursors.resizeDown;
        cursor = SystemMouseCursors.resizeUpDown;
        break;
      case UpdateRegion.TOP_PATCH:
      case UpdateRegion.BOTTOM_PADDING:
        // e = getClosestEdge(x, editRegion.segment!);
        // cursor = (e == Edge.START) ? SystemMouseCursors.resizeLeft : SystemMouseCursors.resizeRight;
        cursor = SystemMouseCursors.resizeLeftRight;
        break;
      default:
      // assert false : this.editRegion;
    }

    return cursor;
  }

  /// Returns whether the horizontal or the vertical region should be updated based on the
  /// mouse pointer's location relative to the edges of either region. If no edge is close to
  /// the mouse pointer, then it returns null.
  UpdateRegionInfo? pickUpdateRegion(double x, double y, UpdateRegionInfo? vertical, UpdateRegionInfo? horizontal) {
    if (vertical != null && vertical.segment != null) {
      Edge e = getClosestEdge(y, vertical.segment!);
      if (e != Edge.NONE) {
        return vertical;
      }
    }

    if (horizontal != null && horizontal.segment != null) {
      Edge e = getClosestEdge(x, horizontal.segment!);
      if (e != Edge.NONE) {
        return horizontal;
      }
    }

    return null;
  }

  double imageYCoordinate(double y) {
    double top = (height - image.height * zoomFraction) / 2;
    return (y - top).round() / zoomFraction;
  }

  double imageXCoordinate(double x) {
    double left = (width - image.width * zoomFraction) / 2;
    return (x - left).round() / zoomFraction;
  }

  Point getImageOrigin() {
    double left = (width - image.width * zoomFraction) / 2;
    double top = (height - image.height * zoomFraction) / 2;
    return Point(left, top);
  }

  Rect displayCoordinates(Rect r) {
    Point imageOrigin = getImageOrigin();

    double x = r.left * zoomFraction + imageOrigin.x;
    double y = r.top * zoomFraction + imageOrigin.y;
    double w = r.width * zoomFraction;
    double h = r.height * zoomFraction;

    return Rect.fromLTWH(x, y, w, h);
  }

  void startDrawingLine(double x, double y) {
    double width = image.width.toDouble();
    double height = image.height.toDouble();
    if (((x == 0 || x == width - 1) && (y > 0 && y < height - 1)) ||
        ((x > 0 && x < width - 1) && (y == 0 || y == height - 1))) {
      drawingLine = true;
      lineFromX = x;
      lineFromY = y;
      lineToX = x;
      lineToY = y;

      showDrawingLine = true;

      showCursor = false;

      // setState(() {});
    }
  }

  void moveLine(double x, double y) {
    if (!drawingLine) {
      return;
    }

    int width = image.width;
    int height = image.height;

    showDrawingLine = false;

    if (((x == lineFromX) && (y > 0 && y < height - 1)) || ((x > 0 && x < width - 1) && (y == lineFromY))) {
      lineToX = x;
      lineToY = y;

      showDrawingLine = true;
    }
  }

  void endDrawingLine() {
    if (!drawingLine) {
      return;
    }

    drawingLine = false;

    if (!showDrawingLine) {
      return;
    }

    Color color;
    switch (currentMode) {
      case DrawMode.PATCH:
        color = Colors.black;
        break;
      case DrawMode.LAYOUT_BOUND:
        color = Colors.red;
        break;
      case DrawMode.ERASE:
        color = Colors.transparent;
        break;
      default:
        return;
    }

    setPatchData(
      color,
      lineFromX.toInt(),
      lineFromY.toInt(),
      lineToX.toInt(),
      lineToY.toInt(),
      true,
    );

    patchesChanged();
  }

  /// Set the color of pixels on the line from (x1, y1) to (x2, y2) to given color.
  ///
  /// @param inclusive indicates whether the range is inclusive. If true, the last pixel (x2, y2)
  ///                  will be set to the given color as well.
  void setPatchData(Color color, int x1, int y1, int x2, int y2, bool inclusive) {
    int x = x1;
    int y = y1;

    int dx = 0;
    int dy = 0;

    if (x2 != x1) {
      dx = x2 > x1 ? 1 : -1;
    } else if (y2 != y1) {
      dy = y2 > y1 ? 1 : -1;
    }

    var r = color.red;
    var g = color.green;
    var b = color.blue;
    var a = color.alpha;

    while (x != x2 || y != y2) {
      image.setPixelRgba(x, y, r, g, b, a);
      x += dx;
      y += dy;
    }

    if (inclusive) {
      image.setPixelRgba(x, y, r, g, b, a);
    }
    patchesChanged();
  }

  /// Flushes current edit data to the image.
  void flushEditPatchData(Color color) {
    int x1, y1, x2, y2;
    x1 = x2 = y1 = y2 = 0;
    int mini = min(editSegment.first, editSegment.second);
    int maxi = max(editSegment.first, editSegment.second);
    switch (editRegion) {
      case UpdateRegion.LEFT_PATCH:
        x1 = x2 = 0;
        y1 = mini;
        y2 = maxi;
        break;
      case UpdateRegion.RIGHT_PADDING:
        x1 = x2 = image.width - 1;
        y1 = mini;
        y2 = maxi;
        break;
      case UpdateRegion.TOP_PATCH:
        x1 = mini;
        x2 = maxi;
        y1 = y2 = 0;
        break;
      case UpdateRegion.BOTTOM_PADDING:
        x1 = mini;
        x2 = maxi;
        y1 = y2 = image.height - 1;
        break;
      default:
      // assert false : editRegion;
    }

    setPatchData(color, x1, y1, x2, y2, false);
  }

  void patchesChanged() {
    ref.read(createImageDataProvider.notifier).change(image);
  }

  bool checkLockedRegion(double x, double y) {
    // double oldX = lastPositionX;
    // double oldY = lastPositionY;
    lastPositionX = x;
    lastPositionY = y;

    int width = image.width;
    int height = image.height;

    bool previousLock = locked;
    locked = x > 0 && x < width - 1 && y > 0 && y < height - 1;

    bool previousCursor = showCursor;
    showCursor = !drawingLine &&
        (((x == 0 || x == width - 1) && (y > 0 && y < height - 1)) ||
            ((x > 0 && x < width - 1) && (y == 0 || y == height - 1)));

    if (locked != previousLock) {
      // repaint();
    } else if (showCursor || previousCursor) {
      // Rect clip = Rect.fromLTWH(lastPositionX - 1 - zoomFraction / 2, lastPositionY - 1 - zoomFraction / 2,
      //     zoomFraction + 2, zoomFraction + 2);
      // clip = clip.union(
      //     Rect.fromLTWH(oldX - 1 - zoomFraction / 2, oldY - 1 - zoomFraction / 2, zoomFraction + 2, zoomFraction + 2));
      // repaint(clip);
    }

    return locked;
  }
}

int clamp(int i, int min, int max) {
  if (i < min) {
    return min;
  }

  if (i > max) {
    return max;
  }

  return i;
}

enum UpdateRegion {
  LEFT_PATCH,
  TOP_PATCH,
  RIGHT_PADDING,
  BOTTOM_PADDING,
}

class UpdateRegionInfo {
  final UpdateRegion region;
  final Pair? segment;

  UpdateRegionInfo(this.region, this.segment);
}

enum Edge {
  START,
  END,
  NONE,
}

const int EDGE_DELTA = 1;

Edge getClosestEdge(double x, Pair range) {
  if ((x - range.first).abs() <= EDGE_DELTA) {
    return Edge.START;
  } else if ((range.second - x).abs() <= EDGE_DELTA) {
    return Edge.END;
  } else {
    return Edge.NONE;
  }
}

/// The types of edit actions that can be performed on the image.
enum DrawMode {
  PATCH, // drawing a patch or a padding
  LAYOUT_BOUND, // drawing layout bounds
  ERASE, // erasing whatever has been drawn
}

/// Current drawing mode. The mode is changed by using either the Shift or Ctrl keys while
/// drawing.
DrawMode currentMode = DrawMode.PATCH;
