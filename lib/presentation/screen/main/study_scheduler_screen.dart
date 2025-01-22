import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_study_scheduler_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_favorate_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/util/helpers/ads/ads_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudySchedulerScreen extends StatelessWidget {
  const StudySchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final AdManager adManager = AdManager();
    final sortProvider = Provider.of<SortProvider>(context);

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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "Study Scheduler", onUpgradePro: () {},
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
         _studySchedulerTile(colorScheme),
          Container(
            color: colorScheme.onPrimary,
            height: 180,
            child: Column(
              children: [
                ReusableSearchBarCore(
                    colorScheme: colorScheme,
                    hintText: 'search session',
                    onChanged: (value) => {

                    },
                    controller:TextEditingController()
                ),
                ReusableSortAndSeeAll(
                    dropdownValue: sortProvider.dropdownValueNote,
                    sortOptions: sortProvider.sortOptionsNote,
                    onSortChanged:(value) => sortProvider.updateSortValueNote(value!),
                    onSeeAllPressed: () {},
                    isShowSeeAllLink: false,
                    isShowReviewLink: false,
                    onShowReviewLink: () {}
                ),

                adManager.getThirdBannerAdWidget(),

              ],
            ),
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableFavoratePosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(colorScheme: colorScheme, name: 'Add Notes', onTap: () {

          })
        ],
      )
    );
  }
}

Widget _studySchedulerTile(ColorScheme colorScheme){

  return ListView(
    padding: EdgeInsets.symmetric(vertical: 200 ),
     children: [
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute1', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute2', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute3', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
       ReusableStudySchedulerCore(isChecked: false, setName: 'Motivation Qoute', dateTime: DateTime.now(), onEdit: (){}, onDelete: (){}, onTap: (){}),
     ],
  );

}
