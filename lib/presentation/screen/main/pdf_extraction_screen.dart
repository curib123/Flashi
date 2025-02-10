
import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/components/create_pdf_screen.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_block_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/pdf_provider.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/util/helpers/pdf_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class PdfExtractionScreen extends StatefulWidget {
  const PdfExtractionScreen({super.key});

  @override
  State<PdfExtractionScreen> createState() => _PdfExtractionScreenState();
}

class _PdfExtractionScreenState extends State<PdfExtractionScreen> {

  var startAppSdk = StartAppSdk();
  double bannerHeight = 150.0;

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
 //   startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(false);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
        bannerHeight = 150;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
      bannerHeight = 100;
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
      bannerHeight = 100;
    });
  }

  @override
  Widget build(BuildContext context) {

    final colorScheme = Theme.of(context).colorScheme;
    final pdfProvider = Provider.of<PdfProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);
    var filteredNotes = pdfProvider.filterPdfByTitle().reversed.toList();
    PdfService pdfService = PdfService();


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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "My Pdf", onUpgradePro: () {},
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
          sortProvider.dropdownValuePdf == 'Tiles' ? _NoteBodyTile(colorScheme,bannerHeight,filteredNotes) : _NoteBodyBlock(colorScheme,bannerHeight,filteredNotes),
          Container(
            color: colorScheme.onPrimary,
            height: bannerHeight,
            child: Column(
              children: [
                ReusableSearchBarCore(
                    colorScheme: colorScheme,
                    hintText: 'search pdf',
                    onChanged: (value) => {
                     pdfProvider.onSearchChanged(value)
                    },
                    controller:pdfProvider.searchController
                ),
                ReusableSortAndSeeAll(
                    dropdownValue: sortProvider.dropdownValuePdf,
                    sortOptions: sortProvider.sortOptionsPdf,
                    onSortChanged:(value) => sortProvider.updateSortValuePdf(value!),
                    onSeeAllPressed: () {},
                    isShowSeeAllLink: false,
                    isShowReviewLink: false,
                    onShowReviewLink: () {}
                ),
                bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
              ],
            ),
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(
              icon: Icons.unarchive_rounded,
              colorScheme: colorScheme, name: 'Extract Pdf', onTap: () {
            pdfProvider.titleController.text = '';
            pdfProvider.contentController.text = '';

            pdfService.showChoiceDialog(colorScheme, context,pdfProvider);

          })
        ],
      ),
    );
  }
}

Widget _NoteBodyTile(ColorScheme colorScheme,double bannerHeight,List filteredNotes ) {
  return Consumer<PdfProvider>(
    builder: (context, pdfProvider, child) {

      return _buildNoteListView(filteredNotes, colorScheme, pdfProvider,'Tile',context,bannerHeight);
    },
  );
}

Widget _NoteBodyBlock(ColorScheme colorScheme,double bannerHeight,List filteredNotes) {

  return Consumer<PdfProvider>(
    builder: (context, pdfProvider, child) {

      return _buildNoteGridView(filteredNotes, colorScheme, pdfProvider,"Block",context,bannerHeight);
    },
  );
}

Widget _buildNoteListView(List filteredNotes, ColorScheme colorScheme, PdfProvider pdfProvider, String layout,BuildContext context,double bannerHeight) {

  return filteredNotes.isEmpty
      ? _noNotesWidget(context)
      : AnimationLimiter(
    child: ListView.builder(
      padding: EdgeInsets.symmetric(
        vertical: bannerHeight, // Adjust padding as needed
        horizontal: 15,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        var note = filteredNotes[index];
        return _buildNoteLayout(note, index, colorScheme, pdfProvider, context, layout);
      },
    ),
  );
}

Widget _buildNoteGridView(List filteredNotes, ColorScheme colorScheme, PdfProvider pdfProvider, String layout,BuildContext context,double bannerHeight) {

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
        return _buildNoteLayout(note, index, colorScheme, pdfProvider, context, layout);
      },
    ),
  );
}


Widget _buildNoteLayout(Map<String, dynamic> note, int index, ColorScheme colorScheme, PdfProvider pdfProvider,BuildContext context,String layout) {
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
                onPressed: (_) => pdfProvider.deletePdf(note['title']),
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
                  pdfProvider.titleController.text = note['title'];
                  pdfProvider.contentController.text = note['content'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext pageContext) {
                        return CreatePdfScreen(

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
            isNote: false,
            title: note['title'],
            content: note['content'],
            timestamp: note['created_at'],
            isFavorite: note['favorite'],
            onTap: () {
              pdfProvider.titleController.text = note['title'];
              pdfProvider.contentController.text = note['content'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext pageContext) {
                    return CreatePdfScreen(

                      title: note['title'],
                      isRead: true,
                      date: note['created_at'],
                    );
                  },
                ),
              );
            },
            onFavorite: () {
              pdfProvider.toggleFavoriteByTitle(note['title']);
            },
            onEdit: () {
              pdfProvider.titleController.text = note['title'];
              pdfProvider.contentController.text = note['content'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext pageContext) {
                    return CreatePdfScreen(

                      title: note['title'],
                      isRead: false,
                      date: note['created_at'],
                    );
                  },
                ),
              );
            },
            onDelete: () {
              pdfProvider.deletePdf(note['title']);
            },
          )
              : ReusableNotesSummaryBlockCore(
            isNote: false,
            title: note['title'],
            content: note['content'],
            timestamp: note['created_at'],
            isFavorite: note['favorite'],
            onTap: () {
              pdfProvider.titleController.text = note['title'];
              pdfProvider.contentController.text = note['content'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext pageContext) {
                    return CreatePdfScreen(

                      title: note['title'],
                      isRead: true,
                      date: note['created_at'],
                    );
                  },
                ),
              );
            },
            onFavorite: () {
              pdfProvider.toggleFavoriteByTitle(note['title']);
            },
            onEdit: () {
              pdfProvider.titleController.text = note['title'];
              pdfProvider.contentController.text = note['content'];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext pageContext) {
                    return CreatePdfScreen(

                      title: note['title'],
                      isRead: false,
                      date: note['created_at'],
                    );
                  },
                ),
              );
            },
            onDelete: () {
              pdfProvider.deletePdf(note['title']);
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
            "No Pdf Extracted",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Extract some Pdf to see them here.",
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