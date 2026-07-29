import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_radii.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light(
    FlexScheme scheme,
    String font, {
    bool useBundledFont = false,
  }) =>
      _build(Brightness.light, scheme, font, useBundledFont);

  static ThemeData dark(
    FlexScheme scheme,
    String font, {
    bool useBundledFont = false,
  }) =>
      _build(Brightness.dark, scheme, font, useBundledFont);

  static ThemeData _build(
    Brightness brightness,
    FlexScheme scheme,
    String font,
    bool useBundledFont,
  ) {
    final isDark = brightness == Brightness.dark;
    final source = isDark
        ? FlexColor.schemes[scheme]?.dark.primary
        : FlexColor.schemes[scheme]?.light.primary;
    final foreground =
        isDark ? const Color(0xFFF2F2F2) : const Color(0xFF171717);
    final surface = isDark ? const Color(0xFF171717) : Colors.white;
    final canvas = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF7F7F7);
    final elevated = isDark ? const Color(0xFF212121) : Colors.white;
    final muted = isDark ? const Color(0xFFA6A6A6) : const Color(0xFF666666);
    final outline = isDark ? const Color(0xFF353535) : const Color(0xFFE3E3E3);
    final accent = Color.lerp(foreground, source ?? foreground, 0.08)!;
    final colors = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      surface: surface,
    ).copyWith(
      secondary: muted,
      outline: outline,
      outlineVariant: outline,
      surfaceContainerHighest: elevated,
    );
    final baseText = GoogleFonts.getTextTheme(font);
    final textTheme = baseText.copyWith(
      headlineLarge: baseText.headlineLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineMedium: baseText.headlineMedium?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        color: foreground,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        color: foreground,
        height: 1.5,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        color: foreground,
        height: 1.45,
      ),
      bodySmall: baseText.bodySmall?.copyWith(color: muted),
    );
    final border = OutlineInputBorder(
      borderRadius: AppRadii.medium,
      borderSide: BorderSide(color: outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      fontFamily: useBundledFont ? 'Montserrat' : null,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: canvas,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(color: outline),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: elevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.large,
          side: BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: muted),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.large,
          side: BorderSide(color: outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide(color: outline)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: foreground,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? surface : muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: canvas,
        indicatorColor: foreground,
        selectedIconTheme: IconThemeData(color: canvas),
        unselectedIconTheme: IconThemeData(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.medium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: foreground,
          side: BorderSide(color: outline),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.medium,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.medium,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: foreground,
        contentTextStyle: TextStyle(color: surface),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.medium,
        ),
      ),
    );
  }
}
