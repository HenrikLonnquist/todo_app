// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/utils/data_utils.dart';

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({super.key});

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  int _navigationRailIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      // backgroundColor: ,
      selectedIndex: _navigationRailIndex,
      onDestinationSelected: (index) {
        setState(() {
          _navigationRailIndex = index;
        });
      },
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home), 
          label: Text("Home"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.schedule_rounded), 
          label: Text("Schedule"),
        )
      ],
    );
  }
}
