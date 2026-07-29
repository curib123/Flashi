import 'package:flashi/app/navigation/app_router.dart';
import 'package:flashi/core/design_system/app_breakpoints.dart';
import 'package:flashi/core/design_system/app_spacing.dart';
import 'package:flashi/core/design_system/responsive_content.dart';
import 'package:flashi/features/history/application/history_provider.dart';
import 'package:flashi/shared/widgets/content_summary_tile.dart';
import 'package:flashi/core/ads/ad_manager.dart';
import 'package:flashi/shared/widgets/empty_state_widgets.dart';
import 'package:flashi/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AdManager _adManager = AdManager();

  @override
  void dispose() {
    _adManager.showInterstitialAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final results = history.filterHistory();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppPageHeader(
              title: 'Generation history',
              description: 'Revisit content created with the assistant.',
              leading: BackButton(),
            ),
            Expanded(
              child: ResponsiveContent(
                maxWidth: AppBreakpoints.readingMaxWidth,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: history.searchController,
                      onChanged: history.onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search generation history',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    _adManager.getSevenBannerAdWidget(),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: results.isEmpty
                          ? noHistoryWidget(context)
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.xxl),
                              itemCount: results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) => _HistoryCard(
                                item: results[index],
                                provider: history,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item, required this.provider});

  final Map<String, dynamic> item;
  final HistoryProvider provider;

  @override
  Widget build(BuildContext context) {
    return ContentSummaryTile(
      isNote: true,
      title: item['title'],
      content: item['content'],
      timestamp: item['created_at'],
      isFavorite: item['favorite'],
      onTap: () => _open(context, isRead: true),
      onFavorite: () => provider.toggleFavoriteByTitle(item['title']),
      onEdit: () => _open(context, isRead: false),
      onDelete: () => provider.deleteHistoryByTitle(item['title']),
      isHistoryPage: true,
    );
  }

  void _open(BuildContext context, {required bool isRead}) {
    provider.titleController.text = item['title'];
    provider.contentController.text = item['content'];
    Navigator.pushNamed(
      context,
      AppRoutes.historyEditor,
      arguments: HistoryEditorArguments(
        isCreate: false,
        title: item['title'],
        isRead: isRead,
        date: item['created_at'],
      ),
    );
  }
}
