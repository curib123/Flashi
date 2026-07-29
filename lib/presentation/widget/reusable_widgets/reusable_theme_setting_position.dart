import 'package:flashi/util/helpers/widget/modals/theme_modal.dart';
import 'package:flutter/material.dart';

class ReusableThemeSettingPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableThemeSettingPosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 68,
      right: 5,
      child: GestureDetector(
        onTap: () => {openThemeSelector(context)},
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(50)),
          child: Icon(
            Icons.color_lens,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
