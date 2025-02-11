import 'package:flashlearn/presentation/screen/main/export_import_screen.dart';
import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/components/see_all_quiz_card.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_set_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/quiz_provider.dart';
import 'package:flashlearn/util/helpers/ads/ad_helper.dart';
import 'package:flashlearn/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashlearn/util/helpers/alert_box/review_selection_alert_box.dart';
import 'package:flashlearn/util/helpers/import_export_helper_class.dart';
import 'package:flashlearn/util/helpers/modal/create_card_bottom_modal.dart';
import 'package:flashlearn/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  var startAppSdk = StartAppSdk();

  StartAppBannerAd? bannerAd;



  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    //  startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.MREC).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;

      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");

    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");

    });
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quizProvider = Provider.of<QuizProvider>(context);
    final quizSets = quizProvider.filteredQuizSetsFavorite;

    final ImportExportHelperClass helper = ImportExportHelperClass();  // Helper instance for export/import

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "Favorites", onUpgradePro: () {}, onSettings: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );

        }),
        centerTitle: false,
      ),
      body:  Stack(
        children: [

          quizSets.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
            itemCount: quizSets.length,
            itemBuilder: (context, index) {
              final set = quizSets[index];
              final String name = set['name'] ?? 'Unnamed Set';
              final String description = set['description'] ?? '';
              final List cards = set['cards'] ?? [];
              final bool favorite = set['favorite'] ?? false;
              final DateTime timestamp = set['timestamp'] ?? DateTime.now();

              return AnimationLimiter(
                child: AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(seconds: 1),
                  child: SlideAnimation(
                    curve: Curves.easeInOutCubicEmphasized,
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Slidable(
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) => showDeleteConfirmationDialog(
                                context: context,
                                setName: name,
                                onDelete: () => quizProvider.removeQuizSet(set),
                              ),
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
                              onPressed: (_) => _showEditSetModal(
                                  context, quizProvider, name, description),
                              foregroundColor: colorScheme.tertiary,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        child:  Column(
                          children: [

                            bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
                            ReusableSetCore(
                              name: name,
                              description: description,
                              numberOfQuiz: cards.length,
                              isFavorate: favorite,
                              timestamp: timestamp,
                              onTap: () => _navigateToQuizCards(context, name, set, index, cards),
                              onAddCard: () => _addCard(context, name, set, index, cards),
                              onReview: () => showReviewSelection(
                                context: context,
                                heading: name,
                                cards: cards,
                                setname: name,
                              ),
                              onDelete: () => showDeleteConfirmationDialog(
                                context: context,
                                setName: name,
                                onDelete: () => quizProvider.removeQuizSet(set),
                              ),
                              onEdit: () => _showEditSetModal(context, quizProvider, name, description),
                              onFavorate: () => quizProvider.toggleFavorite(set),
                              onViewAllCards: () => _navigateToQuizCards(context, name, set, index, cards),
                              onShare: () {  },
                              onExport: () {
                                helper.exportList(context, set);
                              },
                              onImport: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>  ExportImportScreen()),
                                );

                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          ReusableThemeSettingPosition(colorScheme: colorScheme)
        ],
      )
    );
  }

  /// Builds a placeholder widget when the quiz set list is empty.
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No favorite sets available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some sets to your favorites to see them here.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Combines navigation logic to avoid redundancy.
  void _navigateToQuizCards(BuildContext context, String name, Map<String, dynamic> set, int index, List<dynamic> cards) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeeAllQuizCard(
          name: name,
          colorScheme: Theme.of(context).colorScheme,
          card: set,
          index: index,
          cards: cards,
        ),
      ),
    );
  }

  /// Handles the "Edit Set" modal logic.
  void _showEditSetModal(BuildContext context, QuizProvider quizProvider, String name, String description) {
    quizProvider.nameController.text = name;
    quizProvider.descriptionController.text = description;

    CreateSetBottomModal(
      context: context,
      buttonName: 'Edit',
      isCreate: false,
      setName: name,
    );
  }

  /// Adds a card to the quiz set.
  Future<void> _addCard(BuildContext context, String name, Map<String, dynamic> set, int index, List<dynamic> cards) async {
    _navigateToQuizCards(context, name, set, index, cards);
    await Future.delayed(const Duration(seconds: 1));

    CreateCardBottomModal(
      context: context,
      buttonName: "Add Card",
      isCreate: true,
      cardName: '',
      name: name,
      card: set,
    );
  }
}
