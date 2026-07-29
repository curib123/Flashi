import 'package:flutter/material.dart';

Widget noSetWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.30,
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Quiz Set Available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create Some Quiz Set to Retain now.",
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

Widget noNotesWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Notes available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            "Add some Notes to see them here.",
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

Widget noHistoryWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No History",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            "Generate Quiz Now",
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

Widget noCardWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.30,
    width: MediaQuery.of(context).size.width,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Cards available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create some Cards to see them here.",
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

Widget noTaskWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Center(
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
