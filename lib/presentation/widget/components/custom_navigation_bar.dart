import 'package:flashi/core/design/flashi_design.dart';
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final background = Color.alphaBlend(
      FlashiDesign.brand.withOpacity(
        baseTheme.brightness == Brightness.dark ? .86 : .94,
      ),
      baseTheme.colorScheme.surface,
    );
    final inactive = Colors.white.withOpacity(.66);

    return Theme(
      data: baseTheme.copyWith(
        navigationBarTheme: NavigationBarThemeData(
          height: 70,
          backgroundColor: background,
          indicatorColor: Colors.white.withOpacity(.15),
          elevation: 0,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white, size: 24);
            }
            return IconThemeData(color: inactive, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return baseTheme.textTheme.labelSmall?.copyWith(
              color: selected ? Colors.white : inactive,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            );
          }),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_rounded),
            label: 'Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_alt_outlined),
            selectedIcon: Icon(Icons.note_alt_rounded),
            label: 'Notes',
          ),
        ],
      ),
    );
  }
}
