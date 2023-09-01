// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:flutter_draw9patch/utils/pair.dart';

class NinePatchChunk {
  // The 9 patch segment is not a solid color.
  static int NO_COLOR = 0x00000001;

  // The 9 patch segment is completely transparent.
  static int TRANSPARENT_COLOR = 0x00000000;

  bool wasDeserialized = true;
  int numXDivs = 0;
  int numYDivs = 0;
  int numColors = 0;

  // The offset (from the start of this structure) to the xDivs & yDivs
  // array for this 9patch. To get a pointer to this array, call
  // getXDivs or getYDivs. Note that the serialized form for 9patches places
  // the xDivs, yDivs and colors arrays immediately after the location
  // of the Res_png_9patch struct.
  int xDivsOffset = 0;
  int yDivsOffset = 0;

  int paddingLeft = 0;
  int paddingRight = 0;
  int paddingTop = 0;
  int paddingBottom = 0;

  // The offset (from the start of this structure) to the colors array
  // for this 9patch.
  int colorsOffset = 0;

  Uint8List serialize(List<Pair> xDivs, List<Pair> yDivs, List<int> colors) {
    BytesBuilder builder = BytesBuilder();
    builder.addByte(wasDeserialized ? 1 : 0);
    builder.addByte(numXDivs);
    builder.addByte(numYDivs);
    builder.addByte(numColors);

    builder.add(intToBytes(xDivsOffset, endian: Endian.little));
    builder.add(intToBytes(yDivsOffset, endian: Endian.little));

    builder.add(intToBytes(paddingLeft));
    builder.add(intToBytes(paddingRight));
    builder.add(intToBytes(paddingTop));
    builder.add(intToBytes(paddingBottom));

    builder.add(intToBytes(colorsOffset, endian: Endian.little));

    for (var element in xDivs) {
      builder.add(intToBytes(element.first));
      builder.add(intToBytes(element.second));
    }
    for (var element in yDivs) {
      builder.add(intToBytes(element.first));
      builder.add(intToBytes(element.second));
    }

    for (var element in colors) {
      builder.add(intToBytes(element));
    }

    return builder.toBytes();
  }

  Uint8List intToBytes(int value, {Endian endian = Endian.big}) {
    final byteData = ByteData(4);
    byteData.setInt32(0, value, endian);
    return byteData.buffer.asUint8List();
  }
}
