import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/ui/editor/image_viewer.dart';
import 'package:flutter_draw9patch/widgets/two_directions_scroll_view.dart';

class EditorPanel extends StatelessWidget {
  const EditorPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TwoDirectionsScrollView(
      child: LayoutBuilder(
        builder: (_, constraints) {
          return ConstrainedBox(
            constraints: constraints,
            child: const ImageViewer(),
          );
        },
      ),
    );
  }
}
