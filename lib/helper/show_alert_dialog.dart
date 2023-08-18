import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/main.dart';

showAlertDialog({required String message, String? btnText}) {
  final context = NavigatorProvider.navigatorContext;
  if (context == null) {
    return;
  }
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Text(message),
          contentTextStyle: Theme.of(context).textTheme.bodyMedium,
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(btnText ?? "OK"),
            ),
          ],
        );
      });
}
