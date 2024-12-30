
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_block_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/notes_provider.dart';
import 'package:flashlearn/presentation/widget/components/create_note_screen.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final notesProvider = Provider.of<NotesProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);

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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "Notes", onUpgradePro: () {}, onTapProfile: () {Scaffold.of(context).openDrawer();}),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          sortProvider.dropdownValueNote == 'Tiles' ? _NoteBodyTile(colorScheme) : _NoteBodyBlock(colorScheme),
          Container(
            color: colorScheme.onPrimary,
            height: 130,
            child: Column(
              children: [
                ReusableSearchBarCore(
                    colorScheme: colorScheme,
                    hintText: 'search notes',
                    onChanged: (value) => {
                      notesProvider.onSearchChanged(value)
                    },
                    controller:notesProvider.searchController
                ),
                ReusableSortAndSeeAll(
                    dropdownValue: sortProvider.dropdownValueNote,
                    sortOptions: sortProvider.sortOptionsNote,
                    onSortChanged:(value) => sortProvider.updateSortValueNote(value!),
                    onSeeAllPressed: () {},
                    isShowSeeAllLink: false,
                    isShowReviewLink: false,
                    onShowReviewLink: () {}
                ),
              ],
            ),
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
                    isRead: false,
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



Widget _NoteBodyTile(ColorScheme colorScheme) {
  return Consumer<NotesProvider>(
    builder: (context, notesProvider, child) {
      var filteredNotes = notesProvider.filterNotesByTitle(notesProvider.searchQuery);

      return  filteredNotes.isEmpty ? Container(
        height: MediaQuery.of(context).size.height,
          child: Center(child: Text('No Notes'),)) : AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 130, horizontal: 15),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            var note = filteredNotes[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(seconds: 2),
              child: SlideAnimation(
                curve: Curves.fastEaseInToSlowEaseOut,
                verticalOffset: 100.0,
                child: FadeInAnimation(
                  child: Slidable(
                    // Left swipe for delete action
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => notesProvider.deleteNoteByTitle( note['title']),
                          foregroundColor: Theme.of(context).colorScheme.error,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    // Right swipe for edit action
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            notesProvider.titleController.text = note['title'];
                            notesProvider.contentController.text = note['content'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext pageContext) {
                                  return CreateNoteScreen(
                                    isCreate: false,
                                    title: note['title'],
                                    isRead: false,
                                  );
                                },
                              ),
                            );
                          },
                          foregroundColor: Theme.of(context).colorScheme.tertiary,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child:  ReusableNotesSummaryTileCore(
                      title: note['title'],
                      content: note['content'],
                      timestamp: note['created_at'],
                      isFavorite: note['favorite'],
                      onTap: () {
                        notesProvider.titleController.text = note['title'];
                        notesProvider.contentController.text = note['content'];
                        // Handle tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext pageContext) {
                              return CreateNoteScreen(
                                isCreate: false,
                                title: note['title'],
                                isRead: true,
                              );
                            },
                          ),
                        );

                      },
                      onFavorite: () {
                        notesProvider.toggleFavoriteByTitle(note['title']);
                      },
                      onEdit: () {
                        notesProvider.titleController.text = note['title'];
                        notesProvider.contentController.text = note['content'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext pageContext) {
                              return CreateNoteScreen(
                                isCreate: false,
                                title: note['title'],
                                isRead: false,
                              );
                            },
                          ),
                        );
                      },
                      onDelete: () {
                        notesProvider.deleteNoteByTitle(note['title']);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _NoteBodyBlock(ColorScheme colorScheme) {
  return Consumer<NotesProvider>(
    builder: (context, notesProvider, child) {
      var filteredNotes = notesProvider.filterNotesByTitle(notesProvider.searchQuery);

      return filteredNotes.isEmpty ? Container(
          height: MediaQuery.of(context).size.height,
          child: Center(child: Text('No Notes'),)) : AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 130, horizontal: 15),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Adjust columns based on screen width
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1, // Maintain square aspect ratio
          ),
          itemCount: filteredNotes.length,
          itemBuilder: (context, index) {
            var note = filteredNotes[index];
            
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(seconds: 3),
              columnCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              child: SlideAnimation(
                curve: Curves.easeInOutCubicEmphasized,
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Slidable(
                    // Left swipe for delete action
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => notesProvider.deleteNoteByTitle(note['title']),
                          foregroundColor: colorScheme.error,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    // Right swipe for edit action
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            notesProvider.titleController.text = note['title'];
                            notesProvider.contentController.text = note['content'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext pageContext) {
                                  return CreateNoteScreen(
                                    isCreate: false,
                                    title: note['title'],
                                    isRead: false,
                                  );
                                },
                              ),
                            );
                          },
                          foregroundColor: colorScheme.tertiary,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: ReusableNotesSummaryBlockCore(
                      title: note['title'],
                      content: note['content'],
                      timestamp: note['created_at'],
                      isFavorite: note['favorite'],
                      onTap: () {
                        // Handle tap
                        notesProvider.titleController.text = note['title'];
                        notesProvider.contentController.text = note['content'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext pageContext) {
                              return CreateNoteScreen(
                                isCreate: false,
                                title: note['title'],
                                isRead: true,
                              );
                            },
                          ),
                        );
                      },
                      onFavorite: () {
                        notesProvider.toggleFavoriteByTitle(note['title']);
                      },
                      onEdit: () {
                        notesProvider.titleController.text = note['title'];
                        notesProvider.contentController.text = note['content'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext pageContext) {
                              return CreateNoteScreen(
                                isCreate: false,
                                title: note['title'],
                                isRead: false,
                              );
                            },
                          ),
                        );
                      },
                      onDelete: () {
                        notesProvider.deleteNoteByTitle(note['title']);
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
