
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/provider/notes_provider.dart';
import 'package:flashlearn/presentation/widget/components/create_note_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Icon(
            Icons.menu_rounded,
            color: colorScheme.onPrimary,
          ),
        ),

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
        centerTitle: false,
      ),
      body: Stack(
        children: [
          _NoteBody(colorScheme),
          ReusableSearchBarCore(
              colorScheme: colorScheme,
              hintText: 'search notes',
              onChanged: (value) => {
                notesProvider.onSearchChanged(value)
              },
              controller:notesProvider.searchController
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(colorScheme: colorScheme, name: 'Add Notes', onTap: () {
            notesProvider.titleController.text = '';
            notesProvider.contentController.text = '';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext pageContext) {
                  return CreateNoteScreen(
                    isCreate: true,
                    title: '',
                  );
                },
              ),
            );
          })
        ],
      ),
    );
  }
}

Widget _NoteBody(ColorScheme colorScheme) {
  return Consumer<NotesProvider>( // Using Consumer to listen to changes
    builder: (context, notesProvider, child) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 15),
        itemCount: notesProvider.filterNotesByTitle(notesProvider.searchQuery).length, // Number of notes in the provider
        itemBuilder: (context, index) {
          var note = notesProvider.filterNotesByTitle(notesProvider.searchQuery)[index]; // Get the current note
          return ReusableNotesSummaryTileCore(
            title: note['title'],
            content: note['content'],
            timestamp: note['created_at'],
            isFavorite: note['favorite'],
            onTap: () {
              // Handle tap
            },
            onFavorite: () {
              // Toggle favorite status
              notesProvider.toggleFavoriteByTitle(note['title']); // Assuming you have a method like this
            },
            onEdit: () {
              // Handle edit
              notesProvider.titleController.text = note['title'];
              notesProvider.contentController.text = note['content'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext pageContext) {
                    return CreateNoteScreen(
                      isCreate: false,
                      title: note['title'],
                    );
                  },
                ),
              );
            },
            onDelete: () {
              // Handle delete
              notesProvider.deleteNoteByTitle(note['title']); // Assuming you have a method like this
            },
          );
        },
      );
    },
  );
}
