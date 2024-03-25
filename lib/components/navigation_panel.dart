// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/screens/main_tasks.dart';
import 'package:todo_app/screens/schedule.dart';
import 'package:todo_app/utils/data_utils.dart';

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({super.key});

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  Map dataList = {};
  int _navigationRailIndex = 1;

  late List<Widget> pages = <Widget>[
    MainTasksPage(
      title: "Main Tasks",
      dataList: dataList
    ),
    SchedulePage(
      dataList: dataList
    ),
    TodayTasks(dataList: dataList)
  ];

  @override
  void initState() {
    super.initState();
    dataList = DataUtils.readJsonFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            // TODO: change it to a fixed width. Just like MS Todo
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height,
            child: NavigationRail(
              // backgroundColor: ,
              selectedIndex: _navigationRailIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _navigationRailIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home), 
                  label: Text("Main Tasks"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.schedule_rounded), 
                  label: Text("Schedule"),
                ),
                
              ],
              trailing: const Column(
                children: [
                  Divider(thickness: 2,),
                  SizedBox(height: 10),
                  // PageLists that the user has created.
                  Text('User Lists')
                ],
              ),
            ),
          ),
          Expanded(
            child: pages.elementAt(_navigationRailIndex),
          )
        ],
      ),
    );
  }
}

class TodayTasks extends StatelessWidget {
  const TodayTasks({
    super.key,
    required this.dataList,
  });

  final Map dataList;

  @override
  Widget build(BuildContext context) {
    return MainTasksPage(
      title: "Today",
      dataList: dataList
    );
  }
}
