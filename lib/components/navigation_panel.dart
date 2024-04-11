// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/screens/main_tasks.dart';
import 'package:todo_app/screens/schedule.dart';
import 'package:todo_app/screens/today_tasks.dart';
import 'package:todo_app/utils/data_utils.dart';

class NavigationPanel extends StatefulWidget {
  const NavigationPanel({super.key});

  @override
  State<NavigationPanel> createState() => _NavigationPanelState();
}

class _NavigationPanelState extends State<NavigationPanel> {
  Map dataList = {};
  int _selectedIndex = 1;

  late List<Widget> pages = <Widget>[
    MainTasksPage(
      title: "Main Tasks",
      dataList: dataList,
    ),
    TodayTasks(
      dataList: dataList,
    ),
    SchedulePage(
      database: dataList,
    ),
  ];

  void _changePage(int) {
    setState(() {
      _selectedIndex = int;
    });
  }

  @override
  void initState() {
    super.initState();
    dataList = DataUtils.readJsonFile();
    
    //* Adding user lists.
    for(var i = 0; i < dataList["user_lists"].length; i++) {
      pages.add(MainTasksPage( 
        title: dataList["user_lists"][i]["user_list_name"],
        dataList: dataList["user_lists"][i],
        userList: true,
        onUserUpdate: () {
          setState(() {
            DataUtils.writeJsonFile(dataList);
          });
        },
      ));
    }
  }

  final ButtonStyle _buttonStyle = TextButton.styleFrom(
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    )
  );
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 220,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton.icon(
                  style: _buttonStyle,
                  onPressed: () {
                    _changePage(0);
                  },
                  icon: const Icon(Icons.home), 
                  label: const Text("Main Tasks"),
                ),
                TextButton.icon(
                  style: _buttonStyle,
                  onPressed: () {
                    _changePage(1);
                  },
                  icon: const Icon(Icons.sunny), 
                  label: const Text("Today"),
                ),
                TextButton.icon(
                  style: _buttonStyle,
                  onPressed: () {
                    _changePage(2);
                  },
                  icon: const Icon(Icons.schedule_rounded), 
                  label: const Text("Schedule"),
                ),
                const Divider(thickness: 2,),
                const SizedBox(height: 10),
                // PageLists that the user has created.
                const Text('User Lists'),
                const SizedBox(height: 10),
                for (var i = 0; i < dataList["user_lists"].length; i++)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3 + i;
                    });
                  }, 
                  icon: const Icon(Icons.abc_outlined),
                  label: Text(
                    "${dataList["user_lists"][i]["user_list_name"]}"
                  ),
                ),

                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      int userListLength = dataList["user_lists"].length;

                      dataList["user_lists"].add(
                        {
                          "user_list_name": "New User List",
                          "main_tasks": []
                        }
                      );

                      DataUtils.writeJsonFile(dataList);

                      pages.add(MainTasksPage(
                        title: dataList["user_lists"][userListLength]["user_list_name"],
                        dataList: dataList["user_lists"][userListLength],
                        onUserUpdate: () {
                          setState(() {
                            DataUtils.writeJsonFile(dataList);
                          });
                        },
                      ));
                    });
                  }, 
                  icon: const Icon(Icons.add),
                  label: const Text("New List")
                ),
              ],
            ),
          ),
          Expanded(
            child: pages.elementAt(_selectedIndex),
          )
        ],
      ),
    );
  }
}
