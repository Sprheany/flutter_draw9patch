import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/theme/colors.dart';
import 'package:flutter_draw9patch/ui/appbar/desktop_appbar.dart';
import 'package:flutter_draw9patch/ui/main_panel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({super.key});

  @override
  ConsumerState createState() => _AppScreenState();
}

class _AppScreenState extends ConsumerState<AppScreen> {
  bool showDragMask = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !kIsWeb ? TopAppBar(ref: ref) : null,
      body: DropTarget(
        onDragEntered: (_) => setState(() {
          showDragMask = true;
        }),
        onDragExited: (_) => setState(() {
          showDragMask = false;
        }),
        onDragDone: (details) {
          if (details.files.isNotEmpty) {
            ref.read(imageFileProvider.notifier).update(details.files.first);
          }
        },
        child: Stack(
          children: [
            const MainPanel(),
            if (showDragMask)
              Container(
                color: HIGHLIGHT_REGION_COLOR,
              ),
          ],
        ),
      ),
    );
  }
}
