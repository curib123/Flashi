import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_colors.dart';

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
    final foreground = isDark ? AppColors.darkText : AppColors.lightText;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final panel = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final muted = isDark ? AppColors.darkMutedText : AppColors.lightMutedText;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = Color.lerp(foreground, source ?? foreground, 0.05)!;
    final colors = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      primary: accent,
      surface: background,
    ).copyWith(
      primary: foreground,
      onPrimary: background,
      secondary: muted,
      onSecondary: background,
      tertiary: accent,
      onSurface: foreground,
      outline: outline,
      outlineVariant: outline,
      surfaceContainerLowest: background,
      surfaceContainerLow: panel,
      surfaceContainer: panel,
      surfaceContainerHigh: raised,
      surfaceContainerHighest: raised,
      inverseSurface: foreground,
      onInverseSurface: background,
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
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: useBundledFont ? 'Montserrat' : null,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      dividerTheme: DividerThemeData(color: outline),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: raised,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.large,
          side: BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: raised,
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
        backgroundColor: raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.large,
          side: BorderSide(color: outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: raised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.lg),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        elevation: 0,
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(side: BorderSide(color: outline)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: panel,
        surfaceTintColor: Colors.transparent,
        indicatorColor: foreground,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? background : muted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: panel,
        indicatorColor: foreground,
        selectedIconTheme: IconThemeData(color: background),
        unselectedIconTheme: IconThemeData(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: foreground,
          foregroundColor: background,
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
        contentTextStyle: TextStyle(color: background),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.medium,
        ),
      ),
    );
  }
}
