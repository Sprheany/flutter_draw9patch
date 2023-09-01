import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_draw9patch/helper/show_alert_dialog.dart';
import 'package:flutter_draw9patch/model/nine_patch.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_draw9patch/utils/image_ext.dart';
import 'package:image/image.dart' as img;
import 'package:png_chunks_encode/png_chunks_encode.dart' as png_encode;
import 'package:png_chunks_extract/png_chunks_extract.dart' as png_extract;

class OpenFileAction {
  static Future<XFile?> selectImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: "images",
      extensions: <String>["png", "jpg", "jpeg", "webp"],
      mimeTypes: ["image/png", "image/jpeg", "image/webp"],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      return null;
    }

    return file;
  }
}

class SaveFileAction {
  static void saveImage(img.Image image, String fileName) async {
    fileName += EXTENSION_9PATCH;

    final FileSaveLocation? result = await getSaveLocation(suggestedName: fileName);
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }

    final Uint8List fileData = img.encodePng(image);
    const String mimeType = 'image/png';
    final XFile savedFile = XFile.fromData(fileData, mimeType: mimeType, name: fileName);
    await savedFile.saveTo(result.path);
  }

  static void saveImageCompiled(img.Image image, String fileName) async {
    fileName += ".png";

    NinePatch? ninePatch;
    try {
      ninePatch = NinePatch(image, PatchInfo(image), image.width, image.height);
    } catch (e) {
      showAlertDialog(message: "Error: $e");
      return;
    }

    final npTcChunk = ninePatch.SerializeBase();
    final npTcMap = {"name": "npTc", "data": npTcChunk};

    final data = img.encodePng(image.removeNinePatchBorder());

    final trunk = png_extract.extractChunks(data);
    final names = trunk.map((e) => e["name"].toString()).toList(growable: false);

    final index = names.indexWhere((e) => e.toUpperCase() == "IDAT");

    trunk.insert(index, npTcMap);

    final buffer = png_encode.encodeChunks(trunk);

    final FileSaveLocation? result = await getSaveLocation(suggestedName: fileName);
    if (result == null) {
      // Operation was canceled by the user.
      return;
    }

    const String mimeType = 'image/png';
    final XFile savedFile = XFile.fromData(buffer, mimeType: mimeType, name: fileName);
    await savedFile.saveTo(result.path);
  }
}
