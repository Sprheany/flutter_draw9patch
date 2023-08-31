import 'package:flutter/material.dart';
import 'package:flutter_draw9patch/provider/file_actions.dart';
import 'package:flutter_draw9patch/provider/image_data_provider.dart';
import 'package:flutter_draw9patch/ui/patch_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperationPanel extends ConsumerStatefulWidget {
  const OperationPanel({super.key});

  @override
  ConsumerState<OperationPanel> createState() => _OperationPanelState();
}

class _OperationPanelState extends ConsumerState<OperationPanel> {
  final _fileNameController = TextEditingController();

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(fileNameProvider, (previous, next) {
      if (_fileNameController.text != next) {
        _fileNameController.text = next;
      }
    });
    PatchInfo? patchInfo = ref.watch(createImageDataProvider).valueOrNull?.patchInfo;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        FilledButton.icon(
          onPressed: () async {
            final file = await OpenFileAction.selectImage();
            if (file != null) {
              ref.read(imageFileProvider.notifier).state = file;
            }
          },
          icon: const Icon(Icons.image_outlined),
          label: const Text("Select image"),
        ),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () {
            final data = ref.read(createImageDataProvider).valueOrNull;
            if (data?.image != null) {
              SaveFileAction.saveImage(data!.image, _fileNameController.text);
            }
          },
          icon: const Icon(Icons.save_alt_outlined),
          label: const Text("Save image"),
        ),
        const SizedBox(height: 48),
        const Text(
          "Image name:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          "When image is saved, name will be [name].9.png",
          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _fileNameController,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            border: OutlineInputBorder(),
          ),
          style: Theme.of(context).textTheme.bodySmall,
          onChanged: (value) => ref.read(fileNameProvider.notifier).state = value,
        ),
        const SizedBox(height: 48),
        const Text(
          "Stretchable area:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
          child: SelectableText(
            patchInfo?.stretchableArea.join(",\n") ?? "",
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "Content padding:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(8),
          child: SelectableText(
            patchInfo?.contentPadding ?? "",
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
