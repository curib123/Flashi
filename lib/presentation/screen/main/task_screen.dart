import 'package:flashi/presentation/screen/main/settings_screen.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_task_block_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_task_tile_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashi/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashi/provider/sort_provider.dart';
import 'package:flashi/provider/task_provider.dart';
import 'package:flashi/util/helpers/classes/ads/ad_manager.dart';
import 'package:flashi/util/helpers/widget/alert_dialog/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/widget/other/empty_widgets.dart';
import 'package:flashi/util/helpers/widget/modals/create_task_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sortProvider = Provider.of<SortProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTask = taskProvider.searchTasksByName().reversed.toList();
    AdManager adManager = AdManager();


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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "My Checklist", onUpgradePro: () {},
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

          sortProvider.dropdownValueTask == 'Tiles' ?  _taskTile(colorScheme,adManager.bannerHeight,taskProvider,filteredTask,context):  _taskBlock(colorScheme,adManager.bannerHeight,taskProvider,filteredTask,context),

          Container(
            color: colorScheme.onPrimary,
            height: adManager.bannerHeight,
            child: Column(
              children: [
                ReusableSearchBarCore(
                    colorScheme: colorScheme,
                    hintText: 'search  task',
                    onChanged: (value) => {
                    taskProvider.onSearchQuery(value)
                    },
                    controller:taskProvider.searchController
                ),
                ReusableSortAndSeeAll(
                    dropdownValue: sortProvider.dropdownValueTask,
                    sortOptions: sortProvider.sortOptionsTask,
                    onSortChanged:(value) => sortProvider.updateSortValueTask(value!),
                    onSeeAllPressed: () {},
                    isShowSeeAllLink: false,
                    isShowReviewLink: false,
                    onShowReviewLink: () {}
                ),

                //ads here
                adManager.getFourthBannerAdWidget()


                ],
            ),
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateSetButtonPosition(
              icon: Icons.add_rounded,
              colorScheme: colorScheme, name: 'Add Task Today', onTap: () {
            CreateTaskModal(context: context, buttonName: 'Add Task', isCreate: true, taskName: '');
          })
        ],
      )
    );
  }
}

Widget _taskTile(ColorScheme colorScheme,  double bannerHeight, TaskProvider taskProvider,List filteredTask,BuildContext context) {

  if (filteredTask.isEmpty) {
    return noTaskWidget(context); // Show No Task message if there are no tasks
  }

  return ListView.builder(
    padding: EdgeInsets.symmetric(vertical: bannerHeight),
    itemCount: filteredTask.isEmpty ? 1 :filteredTask.length, // Check if tasks are empty
    itemBuilder: (context, index) {



      final task = filteredTask[index];

      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(seconds: 2),
        child: SlideAnimation(
          curve: Curves.fastEaseInToSlowEaseOut,
          verticalOffset: 150.0,
          child: FadeInAnimation(
            child: ReusableTaskTileCore(
              isChecked: task['isChecked'],
              taskName: task['taskName'],
              dateTime: task['dateTime'],
              isUpdated: task['isUpdated'],
              onEdit: () {
                taskProvider.taskNameController.text = task['taskName'];
                CreateTaskModal(context: context, buttonName: 'Save Changes', isCreate: false, taskName: task['taskName']);
              },
              onDelete: () {
                showDeleteConfirmationDialog(context: context, setName: task['taskName'], onDelete: () {
                  taskProvider.deleteTask(task['taskName']);
                });
              },
              onTap: () {
                taskProvider.toggleCheckedTask(task['taskName'], !task['isChecked']);
              },
            ),
          ),
        ),
      );
    },
  );
}

Widget _taskBlock(ColorScheme colorScheme, double bannerHeight, TaskProvider taskProvider,List filteredTask,BuildContext context) {

  if (filteredTask.isEmpty) {
    return noTaskWidget(context); // Show No Task message if there are no tasks
  }

  return GridView.builder(
    padding: EdgeInsets.symmetric(vertical: bannerHeight),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Two columns
      crossAxisSpacing: 8.0, // Space between columns
      mainAxisSpacing: 8.0, // Space between rows
      childAspectRatio: 1.0, // Aspect ratio of each grid item
    ),
    itemCount: filteredTask.isEmpty ? 1 : filteredTask.length, // Check if tasks are empty
    itemBuilder: (context, index) {


      final task = filteredTask[index];

      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(seconds: 2),
        child: SlideAnimation(
          curve: Curves.fastEaseInToSlowEaseOut,
          verticalOffset: 150.0,
          child: FadeInAnimation(
            child: ReusableTaskBlockCore(
              isChecked: task['isChecked'],
              taskName: task['taskName'],
              dateTime: task['dateTime'],
              isUpdated: task['isUpdated'],
              onEdit: () {
                taskProvider.taskNameController.text = task['taskName'];
                CreateTaskModal(context: context, buttonName: 'Save Changes', isCreate: false, taskName: task['taskName']);
              },
              onDelete: () {
                showDeleteConfirmationDialog(
                  context: context,
                  setName: task['taskName'],
                  onDelete: () {
                    taskProvider.deleteTask(task['taskName']);
                  },
                );
              },
              onTap: () {
                taskProvider.toggleCheckedTask(task['taskName'], !task['isChecked']);
              },
            ),
          ),
        ),
      );
    },
  );
}
