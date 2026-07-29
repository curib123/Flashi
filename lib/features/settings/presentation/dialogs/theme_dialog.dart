import 'package:flashi/features/settings/presentation/widgets/theme_selector.dart';
import 'package:flutter/material.dart';

void openThemeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ThemeSelector(
            isShowCloseBtn: true,
          ),
        ], // Add the ThemeSelector here
      );
    },
  );
}
