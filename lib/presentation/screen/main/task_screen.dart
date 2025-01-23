import 'package:flashlearn/presentation/screen/main/settings_screen.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_task_block_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_task_tile_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_favorate_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_sort_and_see_all.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_title_content.dart';
import 'package:flashlearn/provider/sort_provider.dart';
import 'package:flashlearn/provider/task_provider.dart';
import 'package:flashlearn/util/helpers/ads/ads_manager.dart';
import 'package:flashlearn/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashlearn/util/helpers/modal/create_task_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final AdManager adManager = AdManager();
    final sortProvider = Provider.of<SortProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

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
        title:  ReusableTitleContent(colorScheme: colorScheme, title: "My Task", onUpgradePro: () {},
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

          sortProvider.dropdownValueTask == 'Tiles' ?  _taskTile(colorScheme,adManager,taskProvider):  _taskBlock(colorScheme,adManager,taskProvider),

          Container(
            color: colorScheme.onPrimary,
            height: adManager.bannerHeight,
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
                    dropdownValue: sortProvider.dropdownValueTask,
                    sortOptions: sortProvider.sortOptionsTask,
                    onSortChanged:(value) => sortProvider.updateSortValueTask(value!),
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
          ReusableCreateSetButtonPosition(colorScheme: colorScheme, name: 'Add Task Today', onTap: () {
            CreateTaskModal(context: context, buttonName: 'Add Task', isCreate: true, taskName: '');
          })
        ],
      )
    );
  }
}
Widget _taskTile(ColorScheme colorScheme, AdManager adManager, TaskProvider taskProvider) {
  return ListView.builder(
    padding: EdgeInsets.symmetric(vertical: adManager.bannerHeight),
    itemCount: taskProvider.getAllTasks().isEmpty ? 1 : taskProvider.getAllTasks().length, // Check if tasks are empty
    itemBuilder: (context, index) {
      if (taskProvider.getAllTasks().isEmpty) {
        return _noTaskWidget(context); // Show No Task message if there are no tasks
      }

      final task = taskProvider.getAllTasks()[index];

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

Widget _taskBlock(ColorScheme colorScheme, AdManager adManager, TaskProvider taskProvider) {
  return GridView.builder(
    padding: EdgeInsets.symmetric(vertical: adManager.bannerHeight),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // Two columns
      crossAxisSpacing: 8.0, // Space between columns
      mainAxisSpacing: 8.0, // Space between rows
      childAspectRatio: 1.0, // Aspect ratio of each grid item
    ),
    itemCount: taskProvider.getAllTasks().isEmpty ? 1 : taskProvider.getAllTasks().length, // Check if tasks are empty
    itemBuilder: (context, index) {
      if (taskProvider.getAllTasks().isEmpty) {
        return _noTaskWidget(context); // Show No Task message if there are no tasks
      }

      final task = taskProvider.getAllTasks()[index];

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

Widget _noTaskWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.50,
    width: MediaQuery.of(context).size.width,
    child:   Center(
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.inbox, size: 100, color: Colors.grey),
      const SizedBox(height: 20),
      Text(
        "No Task available",
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        "Add some task to see them here.",
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
