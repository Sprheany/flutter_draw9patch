import 'package:flutter_draw9patch/utils/constaints.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final zoomProvider = StateProvider((ref) => DEFAULT_ZOOM);

final patchScaleProvider = StateProvider((ref) => MIN_PATCH_SCALE);

final showLockProvider = StateProvider((ref) => false);

final showPatchesProvider = StateProvider((ref) => false);

final showContentProvider = StateProvider((ref) => false);

final showBadPatchesProvider = StateProvider((ref) => false);

final compiledImageProvider = StateProvider((ref) => false);

final pointXProvider = StateProvider((ref) => 0);
final pointYProvider = StateProvider((ref) => 0);
