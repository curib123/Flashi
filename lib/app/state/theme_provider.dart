import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flashi/core/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ThemeProvider extends ChangeNotifier {
  // Default theme settings
  FlexScheme _currentScheme = FlexScheme.tealM3; // Default to purpleM3
  ThemeMode _themeMode = ThemeMode.light;
  String _currentFont = 'Montserrat'; // Default font
  double _fontScale = 0.8; // Default system font scale

  final Box _settingsBox = Hive.box('theme');

  ThemeProvider() {
    // Load saved theme values from Hive or use defaults
    _currentScheme = FlexScheme.values[_settingsBox.get('currentScheme',
        defaultValue: FlexScheme.tealM3.index)];
    _themeMode = ThemeMode.values[
        _settingsBox.get('themeMode', defaultValue: ThemeMode.light.index)];
    _currentFont = _settingsBox.get('currentFont', defaultValue: 'Montserrat');
    _fontScale = _settingsBox.get('fontSize', defaultValue: 1.0);
  }

  // Getters for current theme properties
  FlexScheme get currentScheme => _currentScheme;

  ThemeMode get themeMode => _themeMode;

  String get currentFont => _currentFont;

  double get fontScale => _fontScale;

  Future<bool> isConnected() async {
    return InternetConnection().hasInternetAccess;
  }

  // Method to update the color scheme
  void setScheme(FlexScheme scheme) {
    if (_currentScheme == scheme) return;
    _currentScheme = scheme;
    _settingsBox.put('currentScheme', scheme.index); // Save to Hive
    notifyListeners();
  }
  // Method to update the color scheme

  void updateFontSize(double value) {
    if (_fontScale == value) return;
    _fontScale = value;
    _settingsBox.put('fontSize', _fontScale); // Save to Hive
    notifyListeners();
  }

  // Method to toggle between light and dark theme modes
  void toggleThemeMode() {
    _themeMode =
        (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put('themeMode', _themeMode.index); // Save to Hive
    notifyListeners();
  }

  // Method to set a new font and save it to Hive
  void setFont(String font) {
    if (_currentFont == font) return;
    _currentFont = font;
    _settingsBox.put('currentFont', font); // Save to Hive
    notifyListeners();
  }

  // Store the internet connection status synchronously
  bool _isConnected = false;

// Method to check the internet connection and set the value of _isConnected
  void checkConnectionStatus() {
    isConnected().then((connectionStatus) {
      if (_isConnected == connectionStatus) return;
      _isConnected = connectionStatus;
      notifyListeners();
    });
  }

// Method to get the light theme with the selected scheme and font
  ThemeData getLightTheme() {
    return AppTheme.light(
      _currentScheme,
      _currentFont,
      useBundledFont: !_isConnected,
    );
  }

// Method to get the dark theme with the selected scheme and font
  ThemeData getDarkTheme() {
    return AppTheme.dark(
      _currentScheme,
      _currentFont,
      useBundledFont: !_isConnected,
    );
  }
}
