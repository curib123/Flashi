import 'package:flashlearn/presentation/widget/components/custom_drawer.dart';
import 'package:flashlearn/presentation/widget/components/custom_navigation_bar.dart';
import 'package:flashlearn/provider/bottom_navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: Container(
            padding: const EdgeInsets.only(top: 40),
            child: ExpandableFab(
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const Icon(Icons.add_circle),
                fabSize: ExpandableFabSize.small,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
              ),
              closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                child: const Icon(Icons.close),
                fabSize: ExpandableFabSize.small,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const CircleBorder(),
              ),
              type: ExpandableFabType.fan,
              overlayStyle:  ExpandableFabOverlayStyle( color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),blur: 2),
              pos: ExpandableFabPos.right,
              distance: 100,
              children: [
                FloatingActionButton.small(
                  tooltip: "Todo ",
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  heroTag: null,
                  child:  Icon(Icons.edit,color: Theme.of(context).colorScheme.onPrimary,),
                  onPressed: () {
                    print('Todo is click');
                  },
                ),
                FloatingActionButton.small(
                  tooltip: "Alarm ",
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  heroTag: null,
                  child:  Icon(Icons.alarm_add_rounded,color: Theme.of(context).colorScheme.onPrimary,),
                  onPressed: () {
                    print('alarm is click');
                  },
                ),
                FloatingActionButton.small(
                  tooltip: "share",
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  heroTag: null,
                  child:  Icon(Icons.share,color: Theme.of(context).colorScheme.onPrimary,),
                  onPressed: () {
                    print('share is click');
                  },
                ),
              ],
            ),
          )

        );
      },

    );
  }
}
