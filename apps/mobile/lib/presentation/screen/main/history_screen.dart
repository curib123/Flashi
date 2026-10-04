import 'package:flashi/core/design/flashi_design.dart';
import 'package:flashi/presentation/widget/components/create_history_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_notes_summary_tile_core.dart';
import 'package:flashi/provider/history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final items = provider.filterHistory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generation history'),
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
              controller: provider.searchController,
              onChanged: provider.onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search generated quizzes',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                items.length == 1
                    ? '1 generated item'
                    : items.length.toString() + ' generated items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? const _EmptyHistory()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final title =
                            (item['title'] ?? 'Generated quiz').toString();
                        final content = (item['content'] ?? '').toString();
                        final date = item['created_at'] is DateTime
                            ? item['created_at'] as DateTime
                            : DateTime.now();
                        final favorite = item['favorite'] == true;

                        void open(bool readOnly) {
                          provider.titleController.text = title;
                          provider.contentController.text = content;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateHistoryScreen(
                                isCreate: false,
                                title: title,
                                isRead: readOnly,
                                date: date,
                              ),
                            ),
                          );
                        }

                        return ReusableNotesSummaryTileCore(
                          isNote: false,
                          title: title,
                          content: content,
                          timestamp: date,
                          isFavorite: favorite,
                          onTap: () => open(true),
                          onFavorite: () =>
                              provider.toggleFavoriteByTitle(title),
                          onEdit: () => open(false),
                          onDelete: () =>
                              provider.deleteHistoryByTitle(title),
                          isHistoryScreen: true,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 52, color: colors.primary),
            const SizedBox(height: 14),
            const Text(
              'Nothing generated yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'AI-generated quiz content will be saved here for quick reference.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
