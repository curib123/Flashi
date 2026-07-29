import 'package:flutter/material.dart';

import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final foreground = isDark ? AppColors.darkText : AppColors.lightText;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final panel = isDark ? AppColors.darkPanel : AppColors.lightPanel;
    final raised = isDark ? AppColors.darkRaised : AppColors.lightRaised;
    final muted = isDark ? AppColors.darkMutedText : AppColors.lightMutedText;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = foreground;
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
    const baseText = TextTheme();
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
      fontFamily: 'Montserrat',
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        toolbarHeight: 72,
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
      listTileTheme: ListTileThemeData(
        minTileHeight: 48,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
        selectedColor: foreground,
        selectedTileColor: raised,
        iconColor: muted,
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
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 1,
        highlightElevation: 0,
        backgroundColor: foreground,
        foregroundColor: background,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.medium),
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
      chipTheme: ChipThemeData(
        backgroundColor: raised,
        selectedColor: foreground,
        secondarySelectedColor: foreground,
        disabledColor: panel,
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: background),
        side: BorderSide(color: outline),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.pill)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? background : foreground,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected) ? foreground : raised,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: outline)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadii.medium),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        elevation: 0,
        color: raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.medium,
          side: BorderSide(color: outline),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: foreground,
          borderRadius: AppRadii.small,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: background),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: foreground,
        linearTrackColor: panel,
        circularTrackColor: panel,
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
