import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flashi/core/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({Box<dynamic>? box})
      : _box = box ?? Hive.box<dynamic>('theme') {
    _scheme = _readEnum(
      FlexScheme.values,
      'currentScheme',
      FlexScheme.tealM3,
    );
    _themeMode = _readEnum(
      ThemeMode.values,
      'themeMode',
      ThemeMode.light,
    );
    _font = _box.get('currentFont', defaultValue: 'Inter') as String;
    _fontScale = (_box.get('fontSize', defaultValue: 1.0) as num)
        .toDouble()
        .clamp(0.5, 1.0)
        .toDouble();
  }

  final Box<dynamic> _box;
  late FlexScheme _scheme;
  late ThemeMode _themeMode;
  late String _font;
  late double _fontScale;

  FlexScheme get currentScheme => _scheme;
  ThemeMode get themeMode => _themeMode;
  String get currentFont => _font;
  double get fontScale => _fontScale;
  ThemeData get lightTheme => AppTheme.light(_scheme, _font);
  ThemeData get darkTheme => AppTheme.dark(_scheme, _font);

  void setScheme(FlexScheme scheme) {
    if (_scheme == scheme) return;
    _scheme = scheme;
    _persist('currentScheme', scheme.index);
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _persist('themeMode', mode.index);
  }

  void toggleThemeMode() {
    setThemeMode(
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void setFont(String font) {
    final normalizedFont = font.trim();
    if (normalizedFont.isEmpty || _font == normalizedFont) return;
    _font = normalizedFont;
    _persist('currentFont', normalizedFont);
  }

  void updateFontSize(double value) {
    final normalizedValue = value.clamp(0.5, 1.0).toDouble();
    if (_fontScale == normalizedValue) return;
    _fontScale = normalizedValue;
    _persist('fontSize', normalizedValue);
  }

  T _readEnum<T>(List<T> values, String key, T fallback) {
    final index = _box.get(key, defaultValue: values.indexOf(fallback));
    if (index is! int || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  void _persist(String key, Object value) {
    _box.put(key, value);
    notifyListeners();
  }
}
