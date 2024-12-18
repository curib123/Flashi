import 'package:flashlearn/presentation/widget/components/theme_selector_dropdown.dart';
import 'package:flutter/material.dart';

void openThemeSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: ThemeSelector(isShowCloseBtn: true,), // Add the ThemeSelector here
      );
    },
  );
}