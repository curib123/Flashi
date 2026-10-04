import 'package:flutter/material.dart';

/// Flashi's visual system, aligned with Pocket Inventory's clean UI language.
///
/// The product keeps its own study-focused identity while sharing the same
/// restrained blue palette, surface hierarchy, spacing, and component shapes.
class FlashiDesign {
  FlashiDesign._();

  static const String name = 'Flashi AI';
  static const String tagline = 'Quiz Maker & Learner';

  static const Color brand = Color(0xFF2457D6);
  static const Color brandDark = Color(0xFF173B93);
  static const Color brandSoft = Color(0xFFEAF0FF);
  static const Color brandFaint = Color(0xFFF5F7FF);

  static const Color warning = Color(0xFFF79009);
  static const Color danger = Color(0xFFD92D20);

  static const Color ink = Color(0xFF111827);
  static const Color muted = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);

  static const double pagePadding = 18;
  static const double radius = 18;
  static const double smallRadius = 14;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scaffold = dark ? const Color(0xFF0F131B) : background;
    final panel = dark ? const Color(0xFF171C26) : surface;
    final onSurface = dark ? const Color(0xFFF3F5F8) : ink;
    final onSurfaceVariant = dark ? const Color(0xFFAAB2C0) : muted;
    final outline = dark ? const Color(0xFF303846) : border;

    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
    ).copyWith(
      primary: brand,
      onPrimary: Colors.white,
      secondary: brand,
      onSecondary: Colors.white,
      surface: panel,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outline,
      error: danger,
      onError: Colors.white,
    );

    final baseText = (dark ? ThemeData.dark() : ThemeData.light())
        .textTheme
        .apply(
          fontFamily: 'Montserrat',
          bodyColor: onSurface,
          displayColor: onSurface,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      canvasColor: scaffold,
      dialogBackgroundColor: panel,
      fontFamily: 'Montserrat',
      textTheme: baseText,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffold,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: baseText.titleLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: panel,
        indicatorColor: brand,
        labelTextStyle: WidgetStatePropertyAll(
          baseText.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panel,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: baseText.bodyMedium?.copyWith(color: onSurfaceVariant),
        labelStyle: baseText.bodyMedium?.copyWith(color: onSurfaceVariant),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(smallRadius),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(smallRadius),
          ),
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          textStyle: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: Colors.white,
        elevation: 1,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panel,
        selectedColor: brandSoftOf(brightness),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
        ),
        labelStyle: baseText.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? const Color(0xFFE8ECF4) : ink,
        contentTextStyle: baseText.bodyMedium?.copyWith(
          color: dark ? const Color(0xFF10141C) : Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color mutedOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color borderOf(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;

  static Color primarySoftOf(BuildContext context) => isDark(context)
      ? Color.alphaBlend(brand.withOpacity(.20), surfaceOf(context))
      : brandSoft;

  static Color primaryFaintOf(BuildContext context) => isDark(context)
      ? Color.alphaBlend(brand.withOpacity(.10), surfaceOf(context))
      : brandFaint;

  static Color brandSoftOf(Brightness brightness) =>
      brightness == Brightness.dark
          ? Color.alphaBlend(brand.withOpacity(.20), const Color(0xFF171C26))
          : brandSoft;
}

extension FlashiThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
}
