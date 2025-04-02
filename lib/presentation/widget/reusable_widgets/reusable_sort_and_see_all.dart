import 'package:flutter/material.dart';

class ReusableSortAndSeeAll extends StatelessWidget {
  final String dropdownValue;
  final List<String> sortOptions;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onSeeAllPressed;
  final bool isShowSeeAllLink;
  final bool isShowReviewLink;
  final VoidCallback onShowReviewLink;


  const ReusableSortAndSeeAll({
    super.key,
    required this.dropdownValue,
    required this.sortOptions,
    required this.onSortChanged,
    required this.onSeeAllPressed,
    required this.isShowSeeAllLink,
    required this.isShowReviewLink,
    required this.onShowReviewLink,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dropdown for sorting
          DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
            style: TextStyle(color: colorScheme.primary),
            underline: Container(
              height: 2,
              color: colorScheme.primary,
            ),
            items: sortOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onSortChanged,
          ),


          // "See All" button
          isShowSeeAllLink
              ? TextButton(
            style: ButtonStyle(
              elevation:const WidgetStatePropertyAll(5),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              shadowColor: WidgetStatePropertyAll(colorScheme.tertiaryContainer),
              backgroundColor: WidgetStatePropertyAll(colorScheme.primary.withOpacity(0.8)),
            ),
            onPressed: onSeeAllPressed,
            child:const Text(
              "VIEW ALL",
              style: TextStyle(
                color: Colors.white, // Assuming a contrasting text color
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : isShowReviewLink ? ElevatedButton.icon(
            style: ButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
              shape:WidgetStatePropertyAll( RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
            onPressed: onShowReviewLink ,
            icon: Icon(Icons.rate_review,color: colorScheme.onPrimary,),
            label: Text(
              "Quiz Mode",
              style: TextStyle(
                color: colorScheme.onPrimary, // Assuming a contrasting text color
                fontWeight: FontWeight.bold,
              ),
            ),
          ) : Text(
            "All",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}
