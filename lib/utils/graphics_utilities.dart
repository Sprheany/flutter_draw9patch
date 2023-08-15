import 'package:image/image.dart' as img;

class GraphicsUtilities {
  static List<img.Pixel> getPixels(img.Image image, int x, int y, int w, int h) {
    if (w == 0 || h == 0) {
      return List.empty();
    }

    final pixels = <img.Pixel>[];
    for (var r = x; r < x + w; r++) {
      for (var c = y; c < y + h; c++) {
        pixels.add(image.getPixel(r, c));
      }
    }

    return pixels;
  }
}
