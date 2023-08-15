import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:image/image.dart' as img;

class OpenFileAction {
  static Future<XFile?> selectImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: "images",
      extensions: <String>["png"],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file == null) {
      return null;
    }

    return file;
  }
}

class SaveFileAction {
  static void saveImage(img.Image image) async {
    final String name = image.textData?["name"] ?? "${TimeOfDay.now()}$EXTENSION_9PATCH";
    bool is9Patch = name.endsWith(EXTENSION_9PATCH);
    final fileName = is9Patch ? name : name.replaceRange(name.lastIndexOf("."), null, EXTENSION_9PATCH);

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
