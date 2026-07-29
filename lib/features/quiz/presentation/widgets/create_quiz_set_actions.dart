import 'package:flashi/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';

class CreateQuizSetActions extends StatelessWidget {
  final Function()? createBtn;
  final String buttonName;

  const CreateQuizSetActions(
      {super.key, required this.createBtn, required this.buttonName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          name: buttonName,
          color: colorScheme.primary,
          icon: Icons.save,
          onTap: createBtn,
        ),
        const SizedBox(
          width: 10,
        ),
        AppButton(
          name: "Cancel",
          color: colorScheme.secondary,
          icon: Icons.cancel,
          onTap: () => {Navigator.pop(context)},
        ),
      ],
    );
  }
}
