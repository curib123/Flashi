import 'package:flashi/core/design/flashi_design.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  final Box _settingsBox = Hive.box('theme');

  FlexScheme _currentScheme = FlexScheme.deepBlue;
  ThemeMode _themeMode = ThemeMode.system;
  String _currentFont = 'Montserrat';
  double _fontScale = 1.0;

  ThemeProvider() {
    final schemeIndex = _settingsBox.get(
      'currentScheme',
      defaultValue: FlexScheme.deepBlue.index,
    );
    if (schemeIndex is int &&
        schemeIndex >= 0 &&
        schemeIndex < FlexScheme.values.length) {
      _currentScheme = FlexScheme.values[schemeIndex];
    }

    final modeIndex = _settingsBox.get(
      'themeMode',
      defaultValue: ThemeMode.system.index,
    );
    if (modeIndex is int &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }

    _currentFont =
        _settingsBox.get('currentFont', defaultValue: 'Montserrat') as String;
    final storedScale = _settingsBox.get('fontSize', defaultValue: 1.0);
    if (storedScale is num) {
      _fontScale = storedScale.toDouble().clamp(0.85, 1.25).toDouble();
    }
  }

  FlexScheme get currentScheme => _currentScheme;
  ThemeMode get themeMode => _themeMode;
  String get currentFont => _currentFont;
  double get fontScale => _fontScale;

  void setScheme(FlexScheme scheme) {
    _currentScheme = scheme;
    _settingsBox.put('currentScheme', scheme.index);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _settingsBox.put('themeMode', mode.index);
    notifyListeners();
  }

  void toggleThemeMode() {
    setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setFont(String font) {
    _currentFont = 'Montserrat';
    _settingsBox.put('currentFont', _currentFont);
    notifyListeners();
  }

  void updateFontSize(double value) {
    _fontScale = value.clamp(0.85, 1.25).toDouble();
    _settingsBox.put('fontSize', _fontScale);
    notifyListeners();
  }

  ThemeData getLightTheme() => FlashiDesign.light();
  ThemeData getDarkTheme() => FlashiDesign.dark();
}
