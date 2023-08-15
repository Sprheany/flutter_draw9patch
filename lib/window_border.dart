import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

final buttonColors = WindowButtonColors();

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(),
        appWindow.isMaximized
            ? RestoreWindowButton(
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(),
      ],
    );
  }
}
