import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_block_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/presentation/widget/components/create_note_screen.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  AdManager adManager = AdManager();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    adManager.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notesProvider = Provider.of<NotesProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    var filteredNotes = notesProvider.filterNotes().toList();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Icon(
            Icons.notes_rounded,
            size: 30,
            color: colorScheme.primary,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(),
        ),
        backgroundColor: colorScheme.onPrimary,
        foregroundColor: colorScheme.primary,
        title: Text(
          "Notes",
          style: TextStyle(
              color: colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          sortProvider.dropdownValueNote == 'Tiles'
              ? _NoteBodyTile(
                  colorScheme, filteredNotes, adManager.bannerHeight)
              : _NoteBodyBlock(
                  colorScheme, filteredNotes, adManager.bannerHeight),
          Container(
            color: colorScheme.onPrimary,
            height: adManager.bannerHeight,
            child: Column(
              children: [
                ReusableSearchBarCore(
                    colorScheme: colorScheme,
                    hintText: 'search notes',
                    onChanged: (value) =>
                        {notesProvider.onSearchChanged(value)},
                    controller: notesProvider.searchController),
                ReusableSortAndSeeAll(
                    dropdownValue: sortProvider.dropdownValueNote,
                    sortOptions: sortProvider.sortOptionsNote,
                    onSortChanged: (value) =>
                        sortProvider.updateSortValueNote(value!),
                    onSeeAllPressed: () {},
                    isShowSeeAllLink: false,
                    isShowReviewLink: false,
                    onShowReviewLink: () {}),

                //ads here
                adManager.getThirdBannerAdWidget()
              ],
            ),
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(
              icon: Icons.add_circle_rounded,
              colorScheme: colorScheme,
              name: 'Add Notes',
              onTap: () {
                notesProvider.titleController.text = '';
                notesProvider.contentController.text = '';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext pageContext) {
                      return CreateNotesPage(
                        isCreate: true,
                        title: '',
                        isRead: false,
                        date: DateTime.now(),
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

Widget _NoteBodyTile(
    ColorScheme colorScheme, List filteredNotes, double bannerHeight) {
  return Consumer<NotesProvider>(
    builder: (context, notesProvider, child) {
      return _buildNoteListView(filteredNotes, colorScheme, notesProvider,
          'Tile', context, bannerHeight);
    },
  );
}

Widget _NoteBodyBlock(
    ColorScheme colorScheme, List filteredNotes, double bannerHeight) {
  return Consumer<NotesProvider>(
    builder: (context, notesProvider, child) {
      return _buildNoteGridView(filteredNotes, colorScheme, notesProvider,
          "Block", context, bannerHeight);
    },
  );
}

Widget _buildNoteListView(
    List filteredNotes,
    ColorScheme colorScheme,
    NotesProvider notesProvider,
    String layout,
    BuildContext context,
    double bannerHeight) {
  return filteredNotes.isEmpty
      ? noNotesWidget(context)
      : AnimationLimiter(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              vertical: bannerHeight, // Adjust padding as needed
              horizontal: 15,
            ),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              var note = filteredNotes[index];
              return _buildNoteLayout(
                  note, index, colorScheme, notesProvider, context, layout);
            },
          ),
        );
}

Widget _buildNoteGridView(
    List filteredNotes,
    ColorScheme colorScheme,
    NotesProvider notesProvider,
    String layout,
    BuildContext context,
    double bannerHeight) {
  return filteredNotes.isEmpty
      ? noNotesWidget(context)
      : AnimationLimiter(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(
              vertical: bannerHeight, // Adjust padding as needed
              horizontal: 15,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) {
              var note = filteredNotes[index];
              return _buildNoteLayout(
                  note, index, colorScheme, notesProvider, context, layout);
            },
          ),
        );
}

Widget _buildNoteLayout(
    Map<String, dynamic> note,
    int index,
    ColorScheme colorScheme,
    NotesProvider notesProvider,
    BuildContext context,
    String layout) {
  return AnimationConfiguration.staggeredList(
    position: index,
    duration: const Duration(seconds: 2),
    child: SlideAnimation(
      curve: Curves.fastEaseInToSlowEaseOut,
      verticalOffset: 100.0,
      child: FadeInAnimation(
        child: layout == 'Tile'
            ? ReusableNotesSummaryTileCore(
                isNote: true,
                title: note['title'],
                content: note['content'],
                timestamp: note['created_at'],
                isFavorite: note['favorite'],
                onTap: () {
                  notesProvider.titleController.text = note['title'];
                  notesProvider.contentController.text = note['content'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext pageContext) {
                        return CreateNotesPage(
                          isCreate: false,
                          title: note['title'],
                          isRead: true,
                          date: note['created_at'],
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
                        return CreateNotesPage(
                          isCreate: false,
                          title: note['title'],
                          isRead: false,
                          date: note['created_at'],
                        );
                      },
                    ),
                  );
                },
                onDelete: () {
                  notesProvider.deleteNoteByTitle(note['title']);
                },
                isHistoryPage: false,
              )
            : ReusableNotesSummaryBlockCore(
                isNote: true,
                title: note['title'],
                content: note['content'],
                timestamp: note['created_at'],
                isFavorite: note['favorite'],
                onTap: () {
                  notesProvider.titleController.text = note['title'];
                  notesProvider.contentController.text = note['content'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext pageContext) {
                        return CreateNotesPage(
                          isCreate: false,
                          title: note['title'],
                          isRead: true,
                          date: note['created_at'],
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
                        return CreateNotesPage(
                          isCreate: false,
                          title: note['title'],
                          isRead: false,
                          date: note['created_at'],
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
  );
}
