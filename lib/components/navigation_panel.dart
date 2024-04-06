// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  int _selectedIndex = 2;

  // TODO: maybe create a new list for users; have the 
  // constant pages and user pages separate
  late List<Widget> pages = <Widget>[
    MainTasksPage(
      title: "Main Tasks",
      dataList: dataList,
    ),
    SchedulePage(
      database: dataList
    ),
    TodayTasks(dataList: dataList),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            // TODO: change it to a fixed width. Just like MS Todo
            width: MediaQuery.of(context).size.width * 0.2,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _changePage(0);
                  },
                  icon: const Icon(Icons.home), 
                  label: const Text("Main Tasks"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _changePage(2);
                  },
                  icon: const Icon(Icons.sunny), 
                  label: const Text("Today"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _changePage(1);
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

class TodayTasks extends StatelessWidget {
  TodayTasks({
    super.key,
    required this.dataList,
  });

  final Map dataList;

  @override
  Widget build(BuildContext context) {
    Map todaysTasks = {"main_tasks": []};  
    var dataTaskLists = [];
    dataTaskLists.add(dataList["main_tasks"]);
    var dataUserList = dataList["user_lists"];

    DateTime now = DateTime.now();
    DateTime dateNow = DateTime(now.year, now.month, now.day);

    for(var i in dataUserList){
      if(i["main_tasks"].length != 0) {
        dataTaskLists.add(i["main_tasks"]);
      }
    }

    for(var taskList in dataTaskLists){
      for(var task in taskList) {
        var taskDate = task["due_date"];
        if(taskDate != "" && DateTime.parse(taskDate) == dateNow) {
          todaysTasks["main_tasks"].add(task);
        }
      }
    }

    return MainTasksPage(
      title: "Today",
      dataList: todaysTasks
    );
  }
}
