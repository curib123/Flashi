import 'package:flashi/app/app_shell.dart';
import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/app_surface.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/core/state/sort_provider.dart';
import 'package:flashi/features/notes/application/notes_provider.dart';
import 'package:flashi/shared/dialogs/app_modal.dart';
import 'package:flashi/shared/widgets/content_summary_card.dart';
import 'package:flashi/shared/widgets/content_summary_tile.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flashi/shared/widgets/app_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final AdManager _adManager = AdManager();
  _NoteFilter _filter = _NoteFilter.all;

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    final sort = context.watch<SortProvider>();
    final searchedNotes = notes.filterNotes();
    final filteredNotes = _filter == _NoteFilter.favorites
        ? searchedNotes.where((note) => note['favorite'] == true).toList()
        : searchedNotes;
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
                  tooltip: 'Create note',
                  onPressed: () => _openEditor(notes),
                  icon: const Icon(Icons.note_add_outlined),
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
                    AppSurface(
                      emphasized: true,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.edit_note_rounded),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${notes.notes.length} ${notes.notes.length == 1 ? 'note' : 'notes'} saved offline',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  '${notes.filterFavorite().length} favorites · Search titles and content',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSearchField(
                      colorScheme: Theme.of(context).colorScheme,
                      controller: notes.searchController,
                      onChanged: notes.onSearchChanged,
                      hintText: 'Search your notes',
                      prominent: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SegmentedButton<_NoteFilter>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: _NoteFilter.all,
                                  icon: Icon(Icons.notes_rounded),
                                  label: Text('All'),
                                ),
                                ButtonSegment(
                                  value: _NoteFilter.favorites,
                                  icon: Icon(Icons.star_outline_rounded),
                                  label: Text('Favorites'),
                                ),
                              ],
                              selected: {_filter},
                              onSelectionChanged: (selection) =>
                                  setState(() => _filter = selection.first),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment(
                              value: 'Tiles',
                              icon: Icon(Icons.view_agenda_outlined),
                            ),
                            ButtonSegment(
                              value: 'Blocks',
                              icon: Icon(Icons.grid_view_outlined),
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
                          ? AppEmptyState(
                              icon: _filter == _NoteFilter.favorites
                                  ? Icons.star_outline_rounded
                                  : Icons.search_off_rounded,
                              title: notes.searchQuery.isNotEmpty
                                  ? 'No matching notes'
                                  : _filter == _NoteFilter.favorites
                                      ? 'No favorite notes'
                                      : 'No notes yet',
                              description: notes.searchQuery.isNotEmpty
                                  ? 'Try a different title or phrase.'
                                  : 'Create a note to capture your first idea.',
                            )
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

enum _NoteFilter { all, favorites }

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
    void onDelete() => _confirmDelete(context);

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

  void _confirmDelete(BuildContext context) {
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AppDialog(
          icon: Icons.delete_outline_rounded,
          title: 'Delete note?',
          description: 'This action cannot be undone.',
          body: Text(
            '“${note['title']}” will be permanently removed from this device.',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                provider.deleteNoteByTitle(note['title']);
              },
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
