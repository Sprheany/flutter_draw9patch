import 'package:flutter/material.dart';

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
        child: SizedBox(
          width: size,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                border: Border.symmetric(
                  horizontal: BorderSide(
                    width: 0.3,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              child: Badge(
                largeSize: 4,
                smallSize: 4,
                backgroundColor: Theme.of(context).colorScheme.background,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
