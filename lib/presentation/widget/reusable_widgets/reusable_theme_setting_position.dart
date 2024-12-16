import 'package:flashlearn/util/helpers/modal/theme_modal.dart';
import 'package:flutter/material.dart';

class ReusableThemeSettingPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableThemeSettingPosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return  Positioned(
      bottom: 80,
      right: 10,
      child: GestureDetector(
        onTap: () => {openThemeSelector(context)},
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(50)

          ),
          child: Icon(Icons.color_lens,color: colorScheme.onPrimary,),
        ),
      ),
    );
  }
}
