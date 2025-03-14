
import 'package:flashi/presentation/screen/authentication/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget noSetWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.30,
    width: MediaQuery.of(context).size.width,
    child:   Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            "No Flashcards Set Available",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Create Some Flashcards Set to See Them Here.",
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

Widget isOfflineOrNotSignIn(ColorScheme colorScheme, BuildContext context) {
  return Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Icon(Icons.cloud_off, size: 100, color: Colors.grey[400]),
          ),
          SizedBox(height: 10),

          // Five Responsive Shimmer Boxes
          ...List.generate(5, (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // Responsive width
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          )),

          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to sign-in screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Sign in to learn & earn",
              style: TextStyle(color: colorScheme.onPrimary),
            ),
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
    child:   Center(
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

Widget noCardWidget(BuildContext context) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.30,
    width: MediaQuery.of(context).size.width,
    child:   Center(
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
