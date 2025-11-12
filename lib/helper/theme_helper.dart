import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// -----------------------
// Theme state
// -----------------------
class ThemeNotifier extends ChangeNotifier {
  bool _dark;
  ThemeNotifier(this._dark);

  bool get isDark => _dark;

  void toggle() {
    _dark = !_dark;
    notifyListeners();
  }
}