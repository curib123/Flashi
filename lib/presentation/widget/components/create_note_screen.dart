import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/provider/notes_provider.dart';
import 'package:flashlearn/util/helpers/snackbar/reusable_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateNoteScreen extends StatelessWidget {
  final bool isCreate;
  final String title;

  const CreateNoteScreen({
    Key? key,
    required this.isCreate,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noteProvider = Provider.of<NotesProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(colorScheme, context),
      body: Stack(
        children: [
          _buildBody(size,noteProvider),
          _buildTitleInputField(noteProvider),
          ReusableCreateSetButtonPosition(
            colorScheme: colorScheme,
            name: isCreate ?  'Save' : 'Save Changes',
            onTap: () => {
              if(noteProvider.titleController.text.isNotEmpty || noteProvider.contentController.text.isNotEmpty){
                _onSaveTap(context, noteProvider)
              }
            },
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme, BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        isCreate ? "Create Note" : "Edit Note",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: colorScheme.onPrimary,
        ),
      ),
      backgroundColor: colorScheme.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildBody(Size size, NotesProvider noteProvider) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      children: [
        SizedBox(height: 50),
        _buildContentInputField(size,noteProvider),
      ],
    );
  }

  Widget _buildTitleInputField(NotesProvider noteProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15.0),
      child: TextField(
        controller: noteProvider.titleController,
        decoration: InputDecoration(
          hintText: 'Title Here',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildContentInputField(Size size, NotesProvider noteProvider) {
    return Container(
      width: size.width,
      child: TextField(
        controller: noteProvider.contentController,
        maxLines: 21,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: 'Type your content here...',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _onSaveTap(BuildContext context, NotesProvider noteProvider) {
    if (isCreate ) {
      noteProvider.addNote({
        'title': noteProvider.titleController.text,
        'content': noteProvider.contentController.text,
        'created_at': DateTime.now(),
        'favorite': false,
      });
      showCustomSnackbar(context: context, message: 'Note created successfully!');
      noteProvider.titleController.clear();
      noteProvider.contentController.clear();
      Navigator.pop(context);
    } else {
      noteProvider.editNoteByTitle(
          title,
          {
            'title': noteProvider.titleController.text,
            'content': noteProvider.contentController.text,
            'created_at': DateTime.now(),
            'favorite': false,
          });
      showCustomSnackbar(context: context, message: 'Note updated successfully!');
    }
  }
}
