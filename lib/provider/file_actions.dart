import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:image/image.dart' as img;

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
}
