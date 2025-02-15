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
import 'package:flashi/util/helpers/ads/ad_helper.dart';
import 'package:flashi/util/helpers/alert_box/delete_confirmation_alert_box.dart';
import 'package:flashi/util/helpers/modal/create_task_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:startapp_sdk/startapp.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {

  var startAppSdk = StartAppSdk();
  double bannerHeight = 150.0;

  StartAppBannerAd? bannerAd;

  @override
  void initState() {
    super.initState();

    // TODO make sure to comment out this line before release
    //startAppSdk.setTestAdsEnabled(true);
    startAppSdk.setTestAdsEnabled(AdHelper.isTestEnabled);

    // TODO use one of the following types: BANNER, MREC, COVER
    startAppSdk.loadBannerAd(StartAppBannerType.BANNER).then((bannerAd) {
      setState(() {
        this.bannerAd = bannerAd;
        bannerHeight = 150;
      });
    }).onError<StartAppException>((ex, stackTrace) {
      debugPrint("Error loading Banner ad: ${ex.message}");
      bannerHeight = 100;
    }).onError((error, stackTrace) {
      debugPrint("Error loading Banner ad: $error");
      bannerHeight = 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sortProvider = Provider.of<SortProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTask = taskProvider.searchTasksByName().reversed.toList();


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

          sortProvider.dropdownValueTask == 'Tiles' ?  _taskTile(colorScheme,bannerHeight,taskProvider,filteredTask,context):  _taskBlock(colorScheme,bannerHeight,taskProvider,filteredTask,context),

          Container(
            color: colorScheme.onPrimary,
            height: bannerHeight,
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

                bannerAd != null ? StartAppBanner(bannerAd!) : Container(),

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
    return _noTaskWidget(context); // Show No Task message if there are no tasks
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
    return _noTaskWidget(context); // Show No Task message if there are no tasks
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

Widget _noTaskWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
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
