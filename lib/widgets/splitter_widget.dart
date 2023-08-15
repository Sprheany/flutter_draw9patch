import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/theme/colors.dart';

typedef SplitterChangeCallback = void Function(double value);

class SplitterWidget extends StatelessWidget {
  final double size;
  final SplitterChangeCallback? onSplitterChange;
  const SplitterWidget({
    super.key,
    this.onSplitterChange,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: (event) {
        onSplitterChange?.call(event.position.dx);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: Container(
          color: BACKGROUND_COLOR,
          width: size,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(horizontal: BorderSide(width: 0.3, color: Colors.grey)),
              ),
              child: const Badge(
                backgroundColor: BACKGROUND_COLOR,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
