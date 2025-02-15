import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/components/see_all_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_favorate_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/ads/ad_helper.dart';
import 'package:flashi/util/helpers/ai_question_generator.dart';
import 'package:flashi/util/helpers/file_text_extractor.dart';
import 'package:flashi/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  var startAppSdk = StartAppSdk();
  double bannerHeight = 150.0;

  StartAppBannerAd? bannerAd;



  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
  //  startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
        bannerHeight = 150;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
      bannerHeight = 00;
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
      bannerHeight = 0;
    });
    // Access the QuizProvider and SortProvider from the context


  }

  void change(QuizProvider quizProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        quizProvider.updateDefaultMaxCard(
            quizProvider.searchQuery == "12/15/03" ? 99999 : 20);
      });
    });
  }


  String extractedText = "";
  bool isLoading = false;

  Future<void> pickFileAndGenerate(QuizProvider quizProvider) async {
    setState(() => isLoading = true);
    extractedText = await FileTextExtractor.pickAndExtractText();

    if (extractedText.isEmpty || extractedText == "No file selected") {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a valid file first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final questions = await AIQuestionGenerator.generateQuestions(extractedText);
    if (questions.isNotEmpty) {
      final quizSetName = 'AI Generated ${quizProvider.quizSets.length + 1}';

      quizProvider.addQuizSet({
        'name': quizSetName,
        'timestamp': DateTime.now(),
        'description': 'AI Generated Flashcard content using PDF/docs file',
        'cards': [],
        'numberOfQuiz': 0,
        'limitNumberOfQuiz': quizProvider.defaultMaxCards,
      });

      for (var questionData in questions) {
        quizProvider.addCardToQuizSet(
          quizSetName: quizSetName,
          card: {
            'isUpdating': false,
            'question': questionData['question'] ?? '',
            'answer': questionData['answer'] ?? '',
            'isIgnore': false,
            'keyword': '',
            'timestamp': DateTime.now(),
          },
        );
      }
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sucessfull Created Ai Generated Flashcard using pdf/docs"),
          backgroundColor: Colors.green,
        ),
      );

    }else{
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No internet/response error/Try Again"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => isLoading = false);


  }
  void _showFlashcardDialog(QuizProvider quizProvider, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // Rounded corners for a modern feel
              ),
              title: Center(
                child: Text(
                  "Choose Flashcard Type",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLoading
                        ? "Please wait while generating questions..."
                        : "Would you like to create a custom flashcard or generate one from a pdf/docs file using AI?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700], // Slightly dim text for a modern look
                    ),
                  ),
                  if (isLoading) // Show loading indicator when isLoading is true
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(
                        color: colorScheme.primary, // Match theme color
                        strokeWidth: 3, // Slim and sleek
                      ),
                    ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5), // Small spacing for better look
                      SizedBox(
                        width: double.infinity, // Full-width button
                        child: TextButton(
                          onPressed: () {
                            CreateSetBottomModal(
                              context: context,
                              buttonName: 'Save',
                              isCreate: true,
                              setName: '',
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary, // Modern secondary color
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Rounded button
                            ),
                          ),
                          child: Text(
                            "Custom Flashcard",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(height: 8), // Space between buttons
                      SizedBox(
                        width: double.infinity, // Full-width button
                        child: ElevatedButton(
                          onPressed: () async {
                            setDialogState(() => isLoading = true); // Update dialog state
                            await pickFileAndGenerate(quizProvider);
                            setDialogState(() => isLoading = false); // Hide loader after completion
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary, // Use theme primary color
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Rounded button
                            ),
                          ),
                          child: Text(
                            "AI Generated",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {


    // Retrieve the current theme's color scheme
    final colorScheme = Theme.of(context).colorScheme;

    // Access the QuizProvider and SortProvider from the context
    final quizProvider = Provider.of<QuizProvider>(context);
    final sortProvider = Provider.of<SortProvider>(context);

    // Reverse the filtered quiz sets for display
    final filteredQuizSets = quizProvider.filteredQuizSets.reversed.toList();

    // Navigate to the SeeAllQuizSetList screen
    void gotoSeeAllQuizSetList() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeeAllQuizSetList(
            name: 'All Subjects',
            colorScheme: colorScheme,
          ),
        ),
      );
    }


change(quizProvider);


    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content using CustomScrollView
          CustomScrollView(
            slivers: [
              // SliverAppBar for a custom collapsing header
              SliverAppBar(
               backgroundColor: colorScheme.primary,
                leading: GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Icon(
                    Icons.notes_rounded,
                    size: 30,
                    color: colorScheme.onPrimary,
                  ),
                ),
                pinned: true, // Keeps the header visible when scrolling
                floating: true, // Header doesn't float when scrolling
                expandedHeight: 210, // Height of the expanded header
                title:  ReusableTitleContent(colorScheme: colorScheme, title: "Flashi Ai", onUpgradePro: () {},
                    onSettings: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );

                    }),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                           " AI-Powered Flashcards: Smarter, Faster!",
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Search bar for filtering quiz sets
                        Container(
                          height: 85,
                          child: ReusableSearchBarCore(
                            colorScheme: colorScheme,
                            hintText: 'Search Subject',
                            onChanged: (value) =>
                                quizProvider.updateSearchQuery(value),
                            controller: quizProvider.searchController,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(35),
                    bottomLeft: Radius.circular(35),
                  ),
                ),
              ),

              // Content section below the header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 200,right: 2,left: 2),
                  child: Column(
                    children: [
                      // Sorting and "See All" button
                      ReusableSortAndSeeAll(
                        dropdownValue: sortProvider.dropdownValueSet,
                        sortOptions: sortProvider.sortOptionsSet,
                        onSortChanged: (newValue) {
                          sortProvider.updateSortValueSet(newValue!);
                          quizProvider.sortQuizSets(newValue);
                        },
                        onSeeAllPressed: ()  {
                          // Update search query and navigate to See All
                          quizProvider.searchController.text =
                              quizProvider.searchQuery;
                          gotoSeeAllQuizSetList();
                        },
                        isShowSeeAllLink: true,
                        isShowReviewLink: false,
                        onShowReviewLink: () {  },
                      ),
                      bannerAd != null ? StartAppBanner(bannerAd!) : Container(),

                      if (filteredQuizSets.isNotEmpty && quizProvider.searchQuery != "12/15/03")
                        ReusableQuizSetList(quizSets: filteredQuizSets)
                      else

                         quizProvider.searchQuery == "12/15/03"
                            ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Developer: John Paul Curib',
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        )
                            : _noSetWidget(context),


                    ],
                  ),
                ),
              ),
            ],
          ),

         // Floating "Create Set" button
          ReusableCreateSetButtonPosition(
            icon: Icons.add_circle,
            colorScheme: colorScheme,
            name: 'Create Subject',
            onTap: ()  {
              _showFlashcardDialog(quizProvider,colorScheme);
            },
          ),

          // Floating theme settings button
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableFavoratePosition(colorScheme: colorScheme),

        ],
      ),
    );
  }
}


Widget _noSetWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.30,
    width: MediaQuery.of(context).size.width,
    child:   Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Subject  Available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create Some Subject to See Them Here.",
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