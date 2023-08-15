import 'package:flutter/material.dart';

class TwoDirectionsScrollView extends StatelessWidget {
  final Widget child;

  TwoDirectionsScrollView({
    super.key,
    required this.child,
  });

  final _verticalController = ScrollController();
  final _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          controller: _verticalController,
          child: Scrollbar(
            thumbVisibility: true,
            controller: _horizontalController,
            notificationPredicate: (notification) => notification.depth == 1,
            child: SingleChildScrollView(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                    minHeight: constraints.maxHeight,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
