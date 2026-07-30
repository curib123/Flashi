import 'package:flashi/features/settings/presentation/widgets/theme_selector.dart';
import 'package:flutter/material.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';

void openThemeSelector(BuildContext context) {
  showAppBottomSheet<void>(
    context: context,
    builder: (context) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: 'Appearance',
            description: 'Choose how Flashi looks on this device.',
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ThemeSelector(isShowCloseBtn: true),
            ),
          ),
        ],
      );
    },
  );
}
