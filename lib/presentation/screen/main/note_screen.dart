import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/create_note_screen.dart';
import 'package:flashi/presentation/widget/components/custom_drawer.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_block_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashi/provider/notes_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  void _createNote(BuildContext context) {
    final provider = context.read<NotesProvider>();
    provider.titleController.clear();
    provider.contentController.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNoteScreen(
          isCreate: true,
          title: '',
          isRead: false,
          date: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotesProvider>();
    final sort = context.watch<SortProvider>();
    final filtered = notes.filterNotes();
    final isList = sort.dropdownValueNote == 'Tiles';

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNote(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New note'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          FlashiDesign.pagePadding,
          4,
          FlashiDesign.pagePadding,
          0,
        ),
        child: Column(
          children: [
            TextField(
              controller: notes.searchController,
              onChanged: notes.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search notes',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    filtered.length == 1
                        ? '1 note'
                        : filtered.length.toString() + ' notes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                _ViewButton(
                  icon: Icons.view_agenda_outlined,
                  selected: isList,
                  tooltip: 'List view',
                  onTap: () => sort.updateSortValueNote('Tiles'),
                ),
                const SizedBox(width: 6),
                _ViewButton(
                  icon: Icons.grid_view_rounded,
                  selected: !isList,
                  tooltip: 'Grid view',
                  onTap: () => sort.updateSortValueNote('Blocks'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? const _EmptyNotes()
                  : isList
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _noteTile(
                            context,
                            notes,
                            filtered[index],
                            true,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.92,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _noteTile(
                            context,
                            notes,
                            filtered[index],
                            false,
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteTile(
    BuildContext context,
    NotesProvider provider,
    Map<String, dynamic> note,
    bool list,
  ) {
    final title = (note['title'] ?? 'Untitled').toString();
    final content = (note['content'] ?? '').toString();
    final date =
        note['created_at'] is DateTime ? note['created_at'] as DateTime : DateTime.now();
    final favorite = note['favorite'] == true;

    void open({required bool readOnly}) {
      provider.titleController.text = title;
      provider.contentController.text = content;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateNoteScreen(
            isCreate: false,
            title: title,
            isRead: readOnly,
            date: date,
          ),
        ),
      );
    }

    if (list) {
      return ReusableNotesSummaryTileCore(
        isNote: true,
        title: title,
        content: content,
        timestamp: date,
        isFavorite: favorite,
        onTap: () => open(readOnly: true),
        onFavorite: () => provider.toggleFavoriteByTitle(title),
        onEdit: () => open(readOnly: false),
        onDelete: () => provider.deleteNoteByTitle(title),
        isHistoryScreen: false,
      );
    }

    return ReusableNotesSummaryBlockCore(
      isNote: true,
      title: title,
      content: content,
      timestamp: date,
      isFavorite: favorite,
      onTap: () => open(readOnly: true),
      onFavorite: () => provider.toggleFavoriteByTitle(title),
      onEdit: () => open(readOnly: false),
      onDelete: () => provider.deleteNoteByTitle(title),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  const _ViewButton({
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: selected
                ? FlashiDesign.primarySoftOf(context)
                : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline.withOpacity(0.12)),
          ),
          child: Icon(
            icon,
            color: selected ? colors.primary : colors.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.note_alt_outlined, size: 52, color: colors.primary),
            const SizedBox(height: 14),
            const Text(
              'No notes yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Save study notes here, then turn the important parts into quizzes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
