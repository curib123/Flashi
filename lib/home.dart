import 'package:flashlearn/presentation/widget/components/custom_drawer.dart';
import 'package:flashlearn/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context,bottomNavigationProvider,child) {
        return Scaffold(
          body: bottomNavigationProvider.getScreen(),
          drawer: const CustomDrawer(),
          bottomNavigationBar: CustomNavigationBar(
            currentIndex: bottomNavigationProvider.currentIndex,
            onTap: (index) {
              bottomNavigationProvider.toogleNavigation(index);
            },
          ),
        );
      },

    );
  }
}
