import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_alarm_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_alarm_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/util/helpers/modal/create_alarm_bottom_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashlearn/provider/alarm_provider.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text(
          'Study Time Alarm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _alarmBody(alarmProvider), // Pass the alarmProvider here
          ReusableSearchBarCore(
            colorScheme: colorScheme,
            hintText: 'search here',
            onChanged: (value) => alarmProvider.updateSearchQuery(value),
            controller: alarmProvider.searchController,
          ),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          ReusableCreateAlarmButtonPosition(
            colorScheme: colorScheme,
            name: "Add Alarm",
            onTap: () {
              CreateAlarmBottomModal(context: context, buttonName: 'Add', isCreate: true, title: 'Add Study Alarm');
            },
          ),
        ],
      ),
    );
  }
}

Widget _alarmBody(AlarmProvider alarmProvider) {
  // Get the list of alarms, reversed
  final filteredAlarms = alarmProvider.filterAlarms().reversed.toList();

  // Filter the alarms with status "Today"
  final todayAlarms = filteredAlarms.where((alarm) => alarm['status'] == 'Today').toList();
  final upcomingAlarms = filteredAlarms.where((alarm) => alarm['status'] == 'Upcoming').toList();
  final completedAlarms = filteredAlarms.where((alarm) => alarm['status'] == 'Completed').toList();
  print(filteredAlarms);

  // Check if today's alarms are empty
  if (todayAlarms.isEmpty) {
    return Center(
      child: Text('No alarms for today', style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }

  // Use ListView.builder directly, since it already provides scrollable behavior
  return ListView.builder(
    scrollDirection: Axis.vertical,
    padding: const EdgeInsets.symmetric(vertical: 60),
    itemCount: filteredAlarms.length,
    itemBuilder: (context, index) {
      final alarm = filteredAlarms[index];
      return ReusableAlarmCore(
        dateCreated: alarm['dateCreated'],
        goalTime: alarm['goalTime'],
        setName: alarm['setName'],
        statusAlarm: alarm['status'],
      );
    },
  );
}
