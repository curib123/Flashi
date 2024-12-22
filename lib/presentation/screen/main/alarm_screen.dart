import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_alarm_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/core%20widgets/reusable_search_bar_core.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_alarm_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/util/helpers/modal/create_alarm_bottom_modal.dart';
import 'package:flashlearn/provider/alarm_provider.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alarmProvider = Provider.of<AlarmProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(colorScheme),
      body: Stack(
        children: [
          _alarmBody(alarmProvider, context),
          _buildSearchBar(colorScheme, alarmProvider),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
          _buildCreateAlarmButton(colorScheme, context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
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
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, AlarmProvider alarmProvider) {
    return ReusableSearchBarCore(
      colorScheme: colorScheme,
      hintText: 'Search here',
      onChanged: alarmProvider.updateSearchQuery,
      controller: alarmProvider.searchController,
    );
  }

  Widget _buildCreateAlarmButton(ColorScheme colorScheme, BuildContext context) {
    return ReusableCreateAlarmButtonPosition(
      colorScheme: colorScheme,
      name: "Add Alarm",
      onTap: () => CreateAlarmBottomModal(
        context: context,
        buttonName: 'Add',
        isCreate: true,
        title: 'Add Study Alarm',
      ),
    );
  }

  Widget _alarmBody(AlarmProvider alarmProvider, BuildContext context) {
    final filteredAlarms = alarmProvider.filterAlarms().reversed.toList();

    if (alarmProvider.searchText.isNotEmpty) {
      return _buildAlarmSearch('Search Results', filteredAlarms, alarmProvider);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAlarmSection('Upcoming', _filterByStatus(filteredAlarms, 'Upcoming'), context),
          _buildAlarmSection('Today', _filterByStatus(filteredAlarms, 'Today'), context),
          _buildAlarmSection('Completed', _filterByStatus(filteredAlarms, 'Completed'), context),
        ],
      ),
    );
  }

  Widget _buildAlarmSearch(String title, List<Map<String, dynamic>> alarms, AlarmProvider alarmProvider) {
    return alarms.isEmpty
        ? Center(child: Text('No alarms for $title'))
        : SizedBox(
      height: 400,
      child: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          return ReusableAlarmCore(
            dateCreated: alarm['dateCreated'],
            goalTime: alarm['goalTime'],
            setName: alarm['setName'],
            statusAlarm: alarm['status'],
            onEdit: () {},
            onDelete: () {},
          );
        },
      ),
    );
  }

  Widget _buildAlarmSection(String title, List<Map<String, dynamic>> alarms, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: alarms.isEmpty
              ? Center(child: Text('No alarms for $title'))
              : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              return ReusableAlarmCore(
                dateCreated: alarm['dateCreated'],
                goalTime: alarm['goalTime'],
                setName: alarm['setName'],
                statusAlarm: alarm['status'],
                onEdit: () {},
                onDelete: () {},
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  List<Map<String, dynamic>> _filterByStatus(List<Map<String, dynamic>> alarms, String status) {
    return alarms.where((alarm) => alarm['status'] == status).toList();
  }
}
