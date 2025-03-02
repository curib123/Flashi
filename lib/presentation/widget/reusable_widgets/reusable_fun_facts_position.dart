
import 'package:flashi/provider/fun_facts_provider.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/fun_facts_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReusableFunFactsPosition extends StatelessWidget {
  final ColorScheme colorScheme;
  const ReusableFunFactsPosition({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context) {

    final funFactsProvider = Provider.of<FunFactsProvider>(context);

    return Positioned(
      bottom: 210,
      right: 5, // Adjusted for balance (optional)
      child: GestureDetector(
        onTap: () {
           showFunFactDialog(context,facts: funFactsProvider.funFacts) ;
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            Icons.lightbulb_outline,
            size: 24,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
