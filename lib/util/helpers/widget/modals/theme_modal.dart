import 'package:flashi/presentation/widget/components/theme_selector_dropdown.dart';
import 'package:flutter/material.dart';

void openThemeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ThemeSelector(
            isShowCloseBtn: true,
          ),
        ], // Add the ThemeSelector here
      );
    },
  );
}
