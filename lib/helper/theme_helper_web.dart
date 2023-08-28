// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

bool isDarkMode() {
  return js.context.callMethod("isDarkMode");
}

void setDarkMode(bool value) {
  js.context.callMethod("setDarkMode", [value]);
}

bool toggleTheme() {
  bool mode = isDarkMode() ? false : true;
  setDarkMode(mode);
  return mode;
}
