import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_quiz_set_list.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/provider/ai_model_provider.dart';
import 'package:flashi/provider/quiz_provider.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/util/helpers/ads/ad_helper.dart';
import 'package:flashi/util/helpers/alert_box/model_dialog.dart';
import 'package:flashi/util/helpers/widget/ai_model/ai_question_generator.dart';
import 'package:flashi/util/helpers/file_text_extractor.dart';
import 'package:flashi/util/helpers/modal/create_set_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class SeeAllQuizSetList extends StatefulWidget {
  final String name;
  final ColorScheme colorScheme;

  const SeeAllQuizSetList({
    super.key,
    required this.name,
    required this.colorScheme,
  });

  @override
  State<SeeAllQuizSetList> createState() => _SeeAllQuizSetListState();
}

class _SeeAllQuizSetListState extends State<SeeAllQuizSetList> {


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

  String extractedText = "";
  bool isLoading = false;

  Future<void> pickFileAndGenerate(QuizProvider quizProvider,AiModelProvider aiModelProvider) async {
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

    final questions = await AIQuestionGenerator.generateQuestions(extractedText,aiModelProvider.model,aiModelProvider.quiz_question_type,aiModelProvider.maxLength);
    if (questions.isNotEmpty) {
      final quizSetName = 'AI Generated ${quizProvider.quizSets.length + 1}';

      quizProvider.addQuizSet({
        'name': quizSetName,
        'timestamp': DateTime.now(),
        'description': 'AI Generated Flashcard content using PDF/docs file',
        'cards': [],
        'numberOfQuiz': 0,
        'limitNumberOfQuiz': aiModelProvider.maxLength,
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
          duration: Duration(seconds: 10),
          content: Text("No internet/response error/Try Again/Choice Another Model"),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => isLoading = false);


  }
  void _showFlashcardDialog(QuizProvider quizProvider, ColorScheme colorScheme,AiModelProvider aiModelProvider) {
    showDialog(
      barrierDismissible: false, // Prevents closing when tapping outside
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
                            Navigator.pop(context);
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
                      SizedBox(
                        width: double.infinity, // Full-width button
                        child: ElevatedButton(
                          onPressed: ()  {
                            ModelSelectionDialog.show(
                              context,
                              onTap: ()  async {
                                print("AI Model selection changed!");
                                setDialogState(() => isLoading = true); // Update dialog state
                                await pickFileAndGenerate(quizProvider,aiModelProvider);
                                setDialogState(() => isLoading = false); // Hide loader after completion
                                // Perform any additional actions
                              },
                            );


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
                      SizedBox(
                        width: double.infinity, // Full-width button
                        child: ElevatedButton(
                          onPressed: ()  {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error, // Use theme primary color
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Rounded button
                            ),
                          ),
                          child: Text(
                            "Cancel",
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

    // Access both providers directly
    final quizProvider = Provider.of<QuizProvider>(context);


    return Scaffold(
      appBar: AppBar(
        foregroundColor: widget.colorScheme.onPrimary, // For text and icons color
        backgroundColor: widget.colorScheme.primary, // Background color of the app bar
        title: Text(widget.name),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        // Custom Back Arrow Icon
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new, // Custom Icon (back arrow)
            color: widget.colorScheme.onPrimary, // Custom color for the icon
          ),
          onPressed: () {

            Navigator.pop(context); // Go back to the previous screen
            quizProvider.searchController.text = quizProvider.searchQuery;
            print(quizProvider.searchQuery);
          },
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Consumer3<QuizProvider, SortProvider,AiModelProvider>(
      builder: (context, quizProvider, sortProvider,aiModelProvider, child) {
        final filteredQuizSets = quizProvider.filteredQuizSets.reversed.toList();

        return Stack(
          children: [
            ListView(
              children: [
                ReusableSearchBarCore(
                  colorScheme: widget.colorScheme,
                  hintText: 'search subject name ',
                  onChanged: (value) {
                    quizProvider.updateSearchQuery(value);
                  }, controller: quizProvider.searchController,
                ),
                ReusableSortAndSeeAll(
                  dropdownValue: sortProvider.dropdownValueSet,
                  sortOptions: sortProvider.sortOptionsSet,
                  onSortChanged: (newValue) {
                    if (newValue != null) {
                      sortProvider.updateSortValueSet(newValue);
                      quizProvider.sortQuizSets(newValue); // Trigger sorting in the provider
                    }
                  },
                  onSeeAllPressed: () {
                    // Optional functionality if required
                  },
                  isShowSeeAllLink: false,
                  isShowReviewLink: false,
                  onShowReviewLink: () {  },
                ),
                bannerAd != null ? StartAppBanner(bannerAd!) : Container(),
                filteredQuizSets.isEmpty
                    ? _noSetWidget(context)
                    : SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height * 0.60,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ReusableQuizSetList(
                      quizSets: filteredQuizSets,
                    ),
                  ),
                ),

              ],

            ),
            // Create Button Position
            ReusableCreateSetButtonPosition(
              icon: Icons.add_circle,
              colorScheme: widget.colorScheme,
              name: 'Create Subject',
              onTap: () {
                _showFlashcardDialog(quizProvider,Theme.of(context).colorScheme,aiModelProvider);
              },
            ),
            ReusableThemeSettingPosition(colorScheme: widget.colorScheme),
          ],
        );
      },
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
            "No Set available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create some Set to see them here.",
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