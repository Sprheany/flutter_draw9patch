import 'dart:async';
import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/utils/image_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_data_provider.g.dart';

final imageFileProvider = StateProvider<XFile?>((ref) {
  return null;
});

class ImageData {
  final img.Image image;
  final ui.Image uiImage;
  final PatchInfo patchInfo;
  ImageData({
    required this.image,
    required this.uiImage,
    required this.patchInfo,
  });
}

@riverpod
class CreateImageData extends _$CreateImageData {
  @override
  FutureOr<ImageData?> build() async {
    final file = ref.watch(imageFileProvider);
    if (file == null) {
      return null;
    }

    img.Image? image = img.decodePng(await file.readAsBytes());
    if (image == null) {
      return null;
    }
    bool is9Patch = file.name.endsWith(EXTENSION_9PATCH);
    if (!is9Patch) {
      image = image.convertTo9Patch();
    } else {
      image.ensure9Patch();
    }
    image.addTextData({"name": file.name});
    final uiImage = await image.convertToFlutterUi();
    return ImageData(
      image: image,
      uiImage: uiImage,
      patchInfo: PatchInfo(image),
    );
  }

  void change(img.Image image) async {
    final uiImage = await image.convertToFlutterUi();
    state = AsyncValue.data(
      ImageData(image: image, uiImage: uiImage, patchInfo: PatchInfo(image)),
    );
  }
}

@riverpod
class CreateTexture extends _$CreateTexture {
  @override
  Future<ui.Image> build() async {
    return await loadImageByProvider(const AssetImage("images/checker.png"));
  }
}

Future<ui.Image> loadImageByProvider(
  ImageProvider provider, {
  ImageConfiguration config = ImageConfiguration.empty,
}) async {
  final Completer<ui.Image> completer = Completer();

  late ImageStreamListener listener;

  // 读取 ImageProvider 的字节数据
  final ImageStream stream = provider.resolve(ImageConfiguration.empty);

  listener = ImageStreamListener((ImageInfo frame, bool sync) {
    final ui.Image image = frame.image;
    completer.complete(image);
    stream.removeListener(listener);
  });

  stream.addListener(listener);

  return completer.future;
}
