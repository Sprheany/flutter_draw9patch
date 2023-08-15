import 'dart:ui' show Paint, PaintingStyle, StrokeCap, StrokeJoin;

extension PaintExt on Paint {
  Paint get fill => this..style = PaintingStyle.fill;

  Paint get stroke => this
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter
    ..strokeMiterLimit = 10;
}
