import 'package:flashlearn/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ReusableAlarmCore extends StatefulWidget {
  final DateTime dateCreated;
  final DateTime goalTime;
  final String setName;
  final String statusAlarm;

  const ReusableAlarmCore({
    Key? key,
    required this.dateCreated,
    required this.goalTime,
    required this.setName,
    required this.statusAlarm,
  }) : super(key: key);

  @override
  _ReusableAlarmCoreState createState() => _ReusableAlarmCoreState();
}

class _ReusableAlarmCoreState extends State<ReusableAlarmCore> {
  late Timer _timer;

  Duration get remainingTime => widget.goalTime.difference(DateTime.now());

  String get status {
    if (remainingTime.isNegative) {
      return "Completed";
    } else if (remainingTime.inDays > 0) {
      return "Upcoming";
    } else {
      return "Today";
    }
  }

  String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = (duration.inHours % 24).toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    if (days > 0) {
      return '$days:$hours:$minutes:$seconds';
    } else {
      return '$hours:$minutes:$seconds';
    }
  }


  String formatTime(DateTime time) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(time);
  }

  @override
  void initState() {
    super.initState();
    // Start the timer to update the remaining time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {}); // Refresh the widget every second
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Stop the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final alarmProvider = Provider.of<AlarmProvider>(context);


    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [colorScheme.tertiaryContainer, colorScheme.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remaining Time Display
              Text(
                remainingTime.isNegative
                    ? "Completed"
                    : formatDuration(remainingTime),
                style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    overflow: TextOverflow.ellipsis
                ),
              ),
              PopupMenuButton<String>(
                color: colorScheme.onPrimary,
                iconColor: colorScheme.primary,
                onSelected: (String value) {
                  // Handle the selected option here
                  switch (value) {
                    case 'Edit':
                    // Handle Edit action
                      break;
                    case 'Delete':
                    // Handle Delete action
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'Edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          Text(
            "Study Time: ${formatTime(widget.goalTime)}",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.tertiary,
            ),
          ),
          const SizedBox(height: 5),
          // Alarm Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.setName,
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Status",
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Date Created
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Created On",
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.tertiary,
                ),
              ),
              Text(
                DateFormat.yMMMd().format(widget.dateCreated),
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.red;
      case "Today":
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
