import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateNotesPage extends StatelessWidget {
  final bool isCreate;
  final bool isRead;
  final String title;
  final DateTime date;

  const CreateNotesPage({
    Key? key,
    required this.isCreate,
    required this.title,
    required this.isRead,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noteProvider = Provider.of<NotesProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Use background from the theme instead of a hard-coded white.
      backgroundColor: colorScheme.onPrimary,
      appBar: _buildAppBar(colorScheme, context, title),
      body: Stack(
        children: [
          _buildBody(size, noteProvider, colorScheme),
          _buildTitleInputField(noteProvider, colorScheme),
          if (!isRead)
            ReusableCreateSetButtonPosition(
              icon: Icons.add_circle,
              colorScheme: colorScheme,
              name: isCreate ? 'Save' : 'Save Changes',
              onTap: () {
                if (noteProvider.titleController.text.isNotEmpty) {
                  _onSaveTap(context, noteProvider);
                } else {
                  ElegantNotification.info(
                    width: 300,
                    notificationMargin: 0,
                    stackedOptions: StackedOptions(
                      type: StackedType.same,
                      key: '',
                    ),
                    position: Alignment.topCenter,
                    animation: AnimationType.fromTop,
                    title: const Text('ALERT'),
                    description: const Text('REQUIRED TITLE'),
                    onDismiss: () {},
                  ).show(context);
                }
              },
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(
      ColorScheme colorScheme, BuildContext context, String title) {
    return AppBar(
      leading: IconButton(
        icon:
            Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: !isRead
          ? Text(
              isCreate ? "Create Note" : "Edit Note",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.primary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View Note',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateNotesPage(
                        isCreate: false,
                        title: title,
                        isRead: false,
                        date: date,
                      ),
                    ));
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildBody(
      Size size, NotesProvider noteProvider, ColorScheme colorScheme) {
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        const SizedBox(height: 80),
        // Instead of a fixed Colors.grey, use onSurface with some opacity.
        Text(
          'Content',
          style: TextStyle(color: colorScheme.primary),
        ),
        _buildContentInputField(size, noteProvider, colorScheme),
        Center(
            child: Text(formattedDate,
                style: TextStyle(color: colorScheme.primary))),
      ],
    );
  }

  Widget _buildTitleInputField(
      NotesProvider noteProvider, ColorScheme colorScheme) {
    return Container(
      // Use the surface color for a card-
      color: colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: TextField(
        readOnly: isRead,
        controller: noteProvider.titleController,
        decoration: InputDecoration(
          hintText: 'Title Here',
          hintStyle: TextStyle(color: colorScheme.primary),
          border: InputBorder.none,
        ),
        // Use onSurface so the text contrasts with the surface color.
        style: TextStyle(fontSize: 18, color: null),
      ),
    );
  }

  Widget _buildContentInputField(
      Size size, NotesProvider noteProvider, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.onPrimary,
      width: size.width,
      child: TextField(
        readOnly: isRead,
        scrollPadding: EdgeInsets.symmetric(vertical: 0),
        controller: noteProvider.contentController,
        maxLines: !isRead ? 18 : 21,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: 'Type your content here...',
          border: InputBorder.none,
          // Fill with the surface color.
          filled: true,
          fillColor: colorScheme.onPrimary,
        ),
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
    );
  }

  void _onSaveTap(BuildContext context, NotesProvider noteProvider) {
    if (isCreate) {
      noteProvider.addNote({
        'title': noteProvider.titleController.text,
        'content': noteProvider.contentController.text,
        'created_at': DateTime.now(),
        'favorite': false,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully Added'),
          backgroundColor: Colors.green,
        ),
      );
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
        },
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully Updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
