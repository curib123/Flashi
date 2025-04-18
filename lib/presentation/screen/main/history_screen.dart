import 'package:flashi/presentation/widget/components/create_history_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_block_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  AdManager adManager = AdManager();

  @override
  void dispose() {
    super.dispose();
    adManager.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyProvider = Provider.of<HistoryProvider>(context);
    var filteredHistory = historyProvider.filterHistory().toList();

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.primary,
          ),
        ),
        backgroundColor: colorScheme.onPrimary,
        foregroundColor: colorScheme.primary,
        title: Text("History",style: TextStyle(color: colorScheme.primary),),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  ReusableSearchBarCore(
                    colorScheme: colorScheme,
                    hintText: 'Search Generated Quiz Set History',
                    onChanged: (value) => historyProvider.onSearchChanged(value),
                    controller: historyProvider.searchController,
                  ),
                  adManager.getSevenBannerAdWidget(),
                ],
              ),
            ),
            Expanded(
              child: _NoteBodyTile(
                colorScheme,
                filteredHistory,
                adManager.bannerHeight,
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _NoteBodyTile(ColorScheme colorScheme, List filteredNotes, double bannerHeight) {
  return Consumer<HistoryProvider>(
    builder: (context, historyProvider, child) {
      return _buildNoteListView(
        filteredNotes,
        colorScheme,
        historyProvider,
        'Tile',
        context,
        bannerHeight,
      );
    },
  );
}

Widget _buildNoteListView(List filteredNotes, ColorScheme colorScheme, HistoryProvider historyProvider, String layout, BuildContext context, double bannerHeight) {
  return filteredNotes.isEmpty
      ? noHistoryWidget(context)
      : AnimationLimiter(
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        var note = filteredNotes[index];
        return _buildNoteLayout(note, index, colorScheme, historyProvider, context, layout);
      },
    ),
  );
}

Widget _buildNoteLayout(Map<String, dynamic> note, int index, ColorScheme colorScheme, HistoryProvider historyProvider, BuildContext context, String layout) {
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
            historyProvider.titleController.text = note['title'];
            historyProvider.contentController.text = note['content'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateHistoryScreen(
                  isCreate: false,
                  title: note['title'],
                  isRead: true,
                  date: note['created_at'],
                ),
              ),
            );
          },
          onFavorite: () => historyProvider.toggleFavoriteByTitle(note['title']),
          onEdit: () {
            historyProvider.titleController.text = note['title'];
            historyProvider.contentController.text = note['content'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateHistoryScreen(
                  isCreate: false,
                  title: note['title'],
                  isRead: false,
                  date: note['created_at'],
                ),
              ),
            );
          },
          onDelete: () => historyProvider.deleteHistoryByTitle(note['title']),
          isHistoryScreen: true,
        )
            : ReusableNotesSummaryBlockCore(
          isNote: true,
          title: note['title'],
          content: note['content'],
          timestamp: note['created_at'],
          isFavorite: note['favorite'],
          onTap: () {
            historyProvider.titleController.text = note['title'];
            historyProvider.contentController.text = note['content'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateHistoryScreen(
                  isCreate: false,
                  title: note['title'],
                  isRead: true,
                  date: note['created_at'],
                ),
              ),
            );
          },
          onFavorite: () => historyProvider.toggleFavoriteByTitle(note['title']),
          onEdit: () {
            historyProvider.titleController.text = note['title'];
            historyProvider.contentController.text = note['content'];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreateHistoryScreen(
                  isCreate: false,
                  title: note['title'],
                  isRead: false,
                  date: note['created_at'],
                ),
              ),
            );
          },
          onDelete: () => historyProvider.deleteHistoryByTitle(note['title']),
        ),
      ),
    ),
  );
}
