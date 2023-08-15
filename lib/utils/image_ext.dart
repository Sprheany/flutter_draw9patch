import 'dart:ui';

import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:image/image.dart' as img;

extension PixelExt on img.Pixel {
  int get color => Color.fromARGB(
        a.toInt(),
        r.toInt(),
        g.toInt(),
        b.toInt(),
      ).value;
}

extension ImageExt on img.Image {
  Future<Image> convertToFlutterUi() => decodeImageFromList(img.encodePng(this));

  img.Image convertTo9Patch() {
    img.Image buffer = img.Image(
      width: width + 2,
      height: height + 2,
      numChannels: 4,
    );

    for (var p in buffer) {
      if (p.x == 0 || p.y == 0 || p.x == buffer.width - 1 || p.y == buffer.height - 1) {
        buffer.setPixelRgba(p.x, p.y, 0, 0, 0, 0);
      } else {
        final color = getPixel(p.x - 1, p.y - 1);
        buffer.setPixel(p.x, p.y, color);
      }
    }

    return buffer;
  }

  void ensure9Patch() {
    for (int i = 0; i < width; i++) {
      int color = getPixel(i, 0).color;
      if (color != 0 && color != BLACK_TICK && color != RED_TICK) {
        setPixelRgb(i, 0, 0, 0, 0);
      }
      color = getPixel(i, height - 1).color;
      if (color != 0 && color != BLACK_TICK && color != RED_TICK) {
        setPixelRgb(i, height - 1, 0, 0, 0);
      }
    }
    for (int i = 0; i < height; i++) {
      int color = getPixel(0, i).color;
      if (color != 0 && color != BLACK_TICK && color != RED_TICK) {
        setPixelRgb(0, i, 0, 0, 0);
      }
      color = getPixel(width - 1, i).color;
      if (color != 0 && color != BLACK_TICK && color != RED_TICK) {
        setPixelRgb(width - 1, i, 0, 0, 0);
      }
    }
  }
}
