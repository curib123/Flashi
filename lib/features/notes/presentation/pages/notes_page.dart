import 'package:flashi/app/app_shell.dart';
import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/shared/widgets/content_summary_card.dart';
import 'package:flashi/shared/widgets/content_summary_tile.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/features/settings/presentation/dialogs/theme_dialog.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final AdManager _adManager = AdManager();

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    final sort = context.watch<SortProvider>();
    final filteredNotes = notes.filterNotes();
    final useList = sort.dropdownValueNote == 'Tiles';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Notes',
              description: 'Capture, organize, and revisit what matters.',
              leading: MediaQuery.sizeOf(context).width < AppBreakpoints.medium
                  ? const IconButton(
                      tooltip: 'Open navigation',
                      onPressed: AppShell.openNavigation,
                      icon: Icon(Icons.menu),
                    )
                  : null,
              actions: [
                IconButton(
                  tooltip: 'Appearance',
                  onPressed: () => openThemeSelector(context),
                  icon: const Icon(Icons.contrast_outlined),
                ),
              ],
            ),
            Expanded(
              child: ResponsiveContent(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: notes.searchController,
                      onChanged: notes.onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search notes',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            filteredNotes.isEmpty
                                ? 'Your notes'
                                : '${filteredNotes.length} notes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: 'Tiles',
                              icon: Icon(Icons.view_agenda_outlined),
                              label: Text('List'),
                            ),
                            ButtonSegment(
                              value: 'Blocks',
                              icon: Icon(Icons.grid_view_outlined),
                              label: Text('Grid'),
                            ),
                          ],
                          selected: {sort.dropdownValueNote},
                          onSelectionChanged: (selection) =>
                              sort.updateSortValueNote(selection.first),
                        ),
                      ],
                    ),
                    if (filteredNotes.isNotEmpty)
                      _adManager.getThirdBannerAdWidget(),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: filteredNotes.isEmpty
                          ? noNotesWidget(context)
                          : _NotesCollection(
                              notes: filteredNotes,
                              useList: useList,
                              provider: notes,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Create note',
        onPressed: () => _openEditor(notes),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }

  void _openEditor(NotesProvider notes) {
    notes.titleController.clear();
    notes.contentController.clear();
    Navigator.pushNamed(
      context,
      AppRoutes.noteEditor,
      arguments: NoteEditorArguments(
        isCreate: true,
        title: '',
        isRead: false,
        date: DateTime.now(),
      ),
    );
  }
}

class _NotesCollection extends StatelessWidget {
  const _NotesCollection({
    required this.notes,
    required this.useList,
    required this.provider,
  });

  final List<Map<String, dynamic>> notes;
  final bool useList;
  final NotesProvider provider;

  @override
  Widget build(BuildContext context) {
    if (useList) {
      return ListView.separated(
        padding: const EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.xxl * 2,
        ),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) => _NoteCard(
          note: notes[index],
          provider: provider,
          useList: true,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        return GridView.builder(
          padding: const EdgeInsets.only(
            top: AppSpacing.xs,
            bottom: AppSpacing.xxl * 2,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: columns == 1 ? 2.1 : 1,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) => _NoteCard(
            note: notes[index],
            provider: provider,
            useList: false,
          ),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.provider,
    required this.useList,
  });

  final Map<String, dynamic> note;
  final NotesProvider provider;
  final bool useList;

  @override
  Widget build(BuildContext context) {
    void onRead() => _openNote(context, isRead: true);
    void onEdit() => _openNote(context, isRead: false);
    void onFavorite() => provider.toggleFavoriteByTitle(note['title']);
    void onDelete() => provider.deleteNoteByTitle(note['title']);

    if (useList) {
      return ContentSummaryTile(
        isNote: true,
        title: note['title'],
        content: note['content'],
        timestamp: note['created_at'],
        isFavorite: note['favorite'],
        onTap: onRead,
        onFavorite: onFavorite,
        onEdit: onEdit,
        onDelete: onDelete,
        isHistoryPage: false,
      );
    }

    return ContentSummaryCard(
      isNote: true,
      title: note['title'],
      content: note['content'],
      timestamp: note['created_at'],
      isFavorite: note['favorite'],
      onTap: onRead,
      onFavorite: onFavorite,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }

  void _openNote(BuildContext context, {required bool isRead}) {
    provider.titleController.text = note['title'];
    provider.contentController.text = note['content'];
    Navigator.pushNamed(
      context,
      AppRoutes.noteEditor,
      arguments: NoteEditorArguments(
        isCreate: false,
        title: note['title'],
        isRead: isRead,
        date: note['created_at'],
      ),
    );
  }
}
