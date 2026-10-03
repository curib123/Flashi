import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_btn_core.dart';
import 'package:flutter/material.dart';

class CreateSetButtons extends StatelessWidget {

  final Function()? createBtn;
  final String buttonName;

  const CreateSetButtons({super.key,required this.createBtn, required this.buttonName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ReusableBtnCore(name: buttonName, color:colorScheme.primary , icon: Icons.save,onTap:createBtn ,),
        const SizedBox(width: 10,),
        ReusableBtnCore(name: "Cancel", color:colorScheme.secondary , icon: Icons.cancel, onTap: () => {Navigator.pop(context)},),
      ],
    );
  }
}
