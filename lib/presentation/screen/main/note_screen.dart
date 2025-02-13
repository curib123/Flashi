
import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
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
import 'package:flashlearn/util/helpers/ads/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {


  double bannerHeight = 160.0;



  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final notesProvider = Provider.of<NotesProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    var filteredNotes = notesProvider.filterNotesByTitle().reversed.toList();



    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: Icon(
            Icons.notes_rounded,
            size: 30,
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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "My Notes", onUpgradePro: () {},
            onSettings: () {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );

            }),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          sortProvider.dropdownValueNote == 'Tiles' ? _NoteBodyTile(colorScheme,filteredNotes,bannerHeight) : _NoteBodyBlock(colorScheme,filteredNotes,bannerHeight),
          Container(
            color: colorScheme.onPrimary,
            height:bannerHeight ,
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

                PersistentBannerAd(placement: 'note',),
              ],
            ),
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(
              icon: Icons.add_circle_rounded,
              colorScheme: colorScheme, name: 'Add Notes', onTap: () {
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

Widget _NoteBodyTile(ColorScheme colorScheme ,List filteredNotes,double bannerHeight ) {
  return Consumer<NotesProvider>(
    builder: (context, notesProvider, child) {

      return _buildNoteListView(filteredNotes, colorScheme, notesProvider,'Tile',context,bannerHeight);
    },
  );
}

Widget _NoteBodyBlock(ColorScheme colorScheme,List filteredNotes,double bannerHeight) {

  return Consumer<NotesProvider>(
    builder: (context, notesProvider, child) {

      return _buildNoteGridView(filteredNotes, colorScheme, notesProvider,"Block",context,bannerHeight);
    },
  );
}

Widget _buildNoteListView(List filteredNotes, ColorScheme colorScheme, NotesProvider notesProvider, String layout,BuildContext context,double bannerHeight) {

  return filteredNotes.isEmpty
      ? _noNotesWidget(context)
      : AnimationLimiter(
    child: ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical:bannerHeight , // Adjust padding as needed
        horizontal: 15,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        var note = filteredNotes[index];
        return _buildNoteLayout(note, index, colorScheme, notesProvider, context, layout);
      },
    ),
  );
}

Widget _buildNoteGridView(List filteredNotes, ColorScheme colorScheme, NotesProvider notesProvider, String layout,BuildContext context,double bannerHeight) {

  return filteredNotes.isEmpty
      ? _noNotesWidget(context)
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
        return _buildNoteLayout(note, index, colorScheme, notesProvider, context, layout);
      },
    ),
  );
}


Widget _buildNoteLayout(Map<String, dynamic> note, int index, ColorScheme colorScheme, NotesProvider notesProvider,BuildContext context,String layout) {
  return AnimationConfiguration.staggeredList(
    position: index,
    duration: const Duration(seconds: 2),
    child: SlideAnimation(
      curve: Curves.fastEaseInToSlowEaseOut,
      verticalOffset: 100.0,
      child: FadeInAnimation(
        child: Slidable(
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
                          date: note['created_at'],
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
                    return CreateNoteScreen(
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
                    return CreateNoteScreen(
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
                    return CreateNoteScreen(
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
                    return CreateNoteScreen(
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
    ),
  );
}
Widget _noNotesWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child:   Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Notes available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some Notes to see them here.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}