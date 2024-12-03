import 'package:flutter/material.dart';

class ReusableSortAndSeeAll extends StatelessWidget {
  final String dropdownValue;
  final List<String> sortOptions;
  final ValueChanged<String?> onSortChanged;
  final VoidCallback onSeeAllPressed;
  final bool isShowSeeAllLink;


  const ReusableSortAndSeeAll({
    super.key,
    required this.dropdownValue,
    required this.sortOptions,
    required this.onSortChanged,
    required this.onSeeAllPressed,
    required this.isShowSeeAllLink,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
            ),
            onPressed: onSeeAllPressed,
            child: Text(
              "SEE ALL SETS",
              style: TextStyle(
                color: Colors.white, // Assuming a contrasting text color
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : Text(
            "All",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    );
  }
}
