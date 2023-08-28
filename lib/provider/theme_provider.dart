import 'package:flutter_draw9patch/helper/theme_helper.dart'
    if (dart.library.js) 'package:flutter_draw9patch/helper/theme_helper_web.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateProvider((ref) => isDarkMode());
