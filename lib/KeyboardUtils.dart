import 'package:flutter/material.dart';

class KeyboardUtils {
  static bool isKeyboardShowing() {
    return WidgetsBinding.instance!.window.viewInsets.bottom > 0;
  }

  static void closeKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }
}