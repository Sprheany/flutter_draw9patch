import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/action_provider.dart';
import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActionPanel extends ConsumerWidget {
  const ActionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
      child: Row(
        children: [
          Expanded(
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                7: FlexColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    Text(
                      "Zoom:",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "${MIN_ZOOM.toInt()}%",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Slider(
                        min: MIN_ZOOM,
                        max: MAX_ZOOM,
                        value: ref.watch(zoomProvider),
                        onChanged: (value) {
                          ref.read(zoomProvider.notifier).state = value;
                        },
                      ),
                    ),
                    Text(
                      "${MAX_ZOOM.toInt()}%",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(width: 30),
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      value: ref.watch(showLockProvider),
                      onChanged: (value) {
                        ref.read(showLockProvider.notifier).state = value!;
                      },
                      title: Text(
                        "Show lock",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      value: ref.watch(showContentProvider),
                      onChanged: (value) {
                        ref.read(showContentProvider.notifier).state = value!;
                      },
                      title: Text(
                        "Show content",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Text(
                      "X: ",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "${ref.watch(pointXProvider)} px",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    Text(
                      "Patch scale:",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "${MIN_PATCH_SCALE.toInt()}x",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Slider(
                        min: MIN_PATCH_SCALE,
                        max: MAX_PATCH_SCALE,
                        value: ref.watch(patchScaleProvider).toDouble(),
                        onChanged: (value) => ref.read(patchScaleProvider.notifier).state = value,
                      ),
                    ),
                    Text(
                      "${MAX_PATCH_SCALE.toInt()}x",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(),
                    CheckboxListTile(
                      value: ref.watch(showPatchesProvider),
                      onChanged: (value) => ref.read(showPatchesProvider.notifier).state = value!,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        "Show Patches",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    CheckboxListTile(
                      value: ref.watch(showBadPatchesProvider),
                      onChanged: (value) => ref.read(showBadPatchesProvider.notifier).state = value!,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        "Show bad patches",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    Text(
                      "Y: ",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      "${ref.watch(pointYProvider)} px",
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
