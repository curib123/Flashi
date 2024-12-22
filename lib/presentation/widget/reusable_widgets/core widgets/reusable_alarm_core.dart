
import 'package:flashlearn/provider/alarm_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:provider/provider.dart';
class ReusableAlarmCore extends StatefulWidget {
  final DateTime dateCreated;
  final DateTime goalTime;
  final String setName;
  final String statusAlarm;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReusableAlarmCore({
    Key? key,
    required this.dateCreated,
    required this.goalTime,
    required this.setName,
    required this.statusAlarm,
    required this.onEdit,
    required this.onDelete,
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
    return days > 0 ? '$days:$hours:$minutes:$seconds' : '$hours:$minutes:$seconds';
  }


  String formatTime(DateTime time) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(time);
  }

  @override
  void initState() {
    super.initState();
    // Start a timer to refresh the widget every second
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (remainingTime.isNegative) {
          _timer.cancel(); // Cancel the timer when the time is completed
        } else if (widget.statusAlarm != status) {
          final alarmProvider = Provider.of<AlarmProvider>(context, listen: false);
          alarmProvider.updateAlarmStatus();
        }
      });
    });
  }




  @override
  void dispose() {
    _timer.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              Text(
                remainingTime.isNegative
                    ? "00:00:00"
                    : formatDuration(remainingTime),
                style: TextStyle(
                  decoration: remainingTime.isNegative ? TextDecoration.lineThrough : TextDecoration.none,
                  color: remainingTime.isNegative ? colorScheme.error :colorScheme.secondary,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              PopupMenuButton<String>(
                color: colorScheme.onPrimary,
                iconColor: colorScheme.primary,
                onSelected: (String value) {
                  switch (value) {
                    case 'Edit':
                    // Handle Edit action
                      widget.onEdit();
                      break;
                    case 'Delete':
                    // Handle Delete action
                      widget.onDelete();
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