import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text(
          'Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ReusableSearchBarCore(colorScheme: colorScheme, hintText: 'search notes', onChanged: (value) => {}, controller: TextEditingController()),
          _NoteBody(colorScheme),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(colorScheme: colorScheme, name: 'Add Notes', onTap: () {})
        ],
      ),
    );
  }
}

Widget _NoteBody(ColorScheme colorScheme){
  return ListView(
    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 15),
    children: [

    ],
  );
}
