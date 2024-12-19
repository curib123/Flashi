import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/alarm_card_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_alarm_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
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
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Make it dynamic and with nice style
Widget _alarmBody(AlarmProvider alarmProvider) {

  // Filter alarms based on search query
  final filteredAlarms = alarmProvider.filterAlarms();

  print(filteredAlarms);

  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 60),
    itemCount: filteredAlarms.length,
    itemBuilder: (context, index) {
      final alarm = filteredAlarms[index];
      return AlarmClockCard(
        alarmName: alarm['alarmName'],
        dateCreated: alarm['dateTime'], // You can set this based on actual data
        goalTime: alarm['goalTime'], // Use the actual goal time from the alarm
        setName: alarm['setName'],   // Use the actual set name from the alarm
      );
    },
  );
}
