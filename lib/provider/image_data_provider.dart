import 'dart:async';
import 'dart:ui';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_draw9patch/helper/show_alert_dialog.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/utils/image_ext.dart';
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_data_provider.g.dart';

@riverpod
class ImageFile extends _$ImageFile {
  @override
  XFile? build() {
    return null;
  }

  void update(XFile file) => state = file;
}

@riverpod
class FileName extends _$FileName {
  @override
  String build() {
    return "";
  }

  void update(String name) => state = name;
}

class ImageData {
  final img.Image image;
  final Image uiImage;
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

    final bytes = await file.readAsBytes();

    img.Image? image = img.decodeNamedImage(file.name, bytes);
    if (image == null) {
      return showAlertDialog(message: "Please select a valid image (png, jpg, webp, etc.)");
    }
    String fileName = file.name;
    bool is9Patch = fileName.endsWith(EXTENSION_9PATCH);
    if (!is9Patch) {
      image = image.convertTo9Patch();
      fileName = fileName.replaceRange(fileName.lastIndexOf("."), null, "");
    } else {
      image.ensure9Patch();
      fileName = fileName.replaceRange(fileName.lastIndexOf(EXTENSION_9PATCH), null, "");
    }
    ref.read(fileNameProvider.notifier).update(fileName);
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
  Future<Image> build() async {
    return await loadImageByProvider(const AssetImage("images/checker.png"));
  }
}

Future<Image> loadImageByProvider(
  ImageProvider provider, {
  ImageConfiguration config = ImageConfiguration.empty,
}) async {
  final Completer<Image> completer = Completer();

  late ImageStreamListener listener;

  // 读取 ImageProvider 的字节数据
  final ImageStream stream = provider.resolve(ImageConfiguration.empty);

  listener = ImageStreamListener((ImageInfo frame, bool sync) {
    final Image image = frame.image;
    completer.complete(image);
    stream.removeListener(listener);
  });

  stream.addListener(listener);

  return completer.future;
}
