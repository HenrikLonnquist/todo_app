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
  int _selectedIndex = 3;

  late List<Widget> pages = <Widget>[
    MainTasksPage(
      title: "Main Tasks",
      dataList: dataList["main_page"],
      onUserUpdate: (value) {
        int index = value!["index"];

        var todayTaskID = dataList["today"]["main_tasks"].indexWhere((task) => value["task_id"] == task["task_id"]);
        var todayCompletedID = dataList["today"]["completed"].indexWhere((task) => value["task_id"] == task["task_id"]);


        if (todayTaskID != -1 || todayCompletedID != -1){

          // checks if the dates have not been changed
          if (value["due_date"] != dataList["today"]["dateToday"]){
            
            // Checks where the task is and deletes it
            if(todayTaskID != -1) {
              dataList["today"]["main_tasks"].removeAt(index);
            } else {
              dataList["today"]["completed"].removeAt(index);
            }

          // move to completed
          } else if (value["checked"]) {
            dataList["today"]["main_tasks"].removeAt(index);
            dataList["today"]["completed"].insert(index, value);
          
          // move to main_tasks
          } else {
            dataList["today"]["main_tasks"].insert(index, value);
            dataList["today"]["completed"].removeAt(index);

          }
          
        } else if (value["due_date"] == dataList["today"]["dateToday"]) {
          dataList["today"]["main_tasks"].insert(value);
        }
        
        print("main tasks: ${dataList["today"]["main_tasks"]}");
        print("completed: ${dataList["today"]["completed"]}");
        

        setState(() {
          DataUtils.writeJsonFile(dataList);
        });

      },
    ),
    TodayTasks(
      dataList: dataList,
    ),
    SchedulePage(
      database: dataList,
    ),
  ];

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
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
        onUserUpdate: (value) {

          int index = value!["index"];

          var todayTaskID = dataList["today"]["main_tasks"].indexWhere((task) => value["task_id"] == task["task_id"]);
          var todayCompletedID = dataList["today"]["completed"].indexWhere((task) => value["task_id"] == task["task_id"]);


          if (todayTaskID != -1 || todayCompletedID != -1){
            print("hello1");

            // checks if the dates have not been changed
            if (value["due_date"] != dataList["today"]["dateToday"]){
              print("hello2");
              
              // Checks where the task is and deletes it
              if(todayTaskID != -1) {
                dataList["today"]["main_tasks"].removeAt(todayTaskID);
                print("hello3");
              } else {
                dataList["today"]["completed"].removeAt(todayCompletedID);
                print("hello4");
              }

            // move to completed
            } else if (value["checked"]) {
              dataList["today"]["main_tasks"].removeAt(index);
              dataList["today"]["completed"].insert(index, value);
              print("hello5");
            
            // move to main_tasks
            } else {
              dataList["today"]["main_tasks"].insert(index, value);
              dataList["today"]["completed"].removeAt(index);
              print("hello6");

            }
            
            // if a task date got changed to todays date then add to todays list
          } else if (value["due_date"] == dataList["today"]["dateToday"]) {
            print("hello7");
            if (value["checked"]) {
              dataList["today"]["completed"].insert(0, value);

            } else {
              dataList["today"]["main_tasks"].insert(0, value);
            }
          }
          
          // print(value);

          print("main tasks: ${dataList["today"]["main_tasks"]}");
          print("completed: ${dataList["today"]["completed"]}");  


          
          setState(() {
            DataUtils.writeJsonFile(dataList);
          });

        },
      ));
    }
  }

  TextButton _pageButtons(
    {
      required int index, 
      required Function()? onPressed, 
      IconData icon = Icons.home,
      String name = "", 
      TextStyle? textStyle, 
    }
    ) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: index == _selectedIndex ? Colors.grey : Colors.white,
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        )
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
      ), 
      label: Text(
        name,
        style: textStyle,
      ),
    );
  } 

  final Map<int, List<dynamic>> mainPagesName = {
    0: ["Main Tasks", Icons.home],
    1: ["Today", Icons.sunny],
    2: ["Schedule", Icons.calendar_month],
  };

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

                for (var i = 0; i < mainPagesName.length; i++)
                _pageButtons(
                  index: i,
                  icon: mainPagesName[i]![1],
                  name: mainPagesName[i]![0],
                  onPressed: () {
                    setState(() {
                      _changePage(i);
                    });
                  },
                ),

                const Divider(thickness: 2,),
                const SizedBox(height: 10),
                
                // PageLists that the user has created.
                const Center(child: Text('User Lists')),
                const SizedBox(height: 10),

                for (var i = 0; i < dataList["user_lists"].length; i++)
                _pageButtons(
                  index: i + 3, 
                  icon: Icons.abc_sharp,
                  name: dataList["user_lists"][i]["user_list_name"],
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 3 + i;
                    });
                  },
                ),

                const SizedBox(height: 15),

                // Adding a new user list
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      int userListLength = dataList["user_lists"].length;

                      dataList["user_lists"].add(
                        {
                          "user_list_name": "New User List",
                          "id": DateTime.now().millisecondsSinceEpoch,
                          "main_tasks": [],
                          "completed": []
                        }
                      );

                      pages.add(MainTasksPage(
                        title: dataList["user_lists"][userListLength]["user_list_name"],
                        dataList: dataList["user_lists"][userListLength],
                        onUserUpdate: (value) {
                                    int index = value!["index"];

                          var todayTaskID = dataList["today"]["main_tasks"].indexWhere((task) => value["task_id"] == task["task_id"]);
                          var todayCompletedID = dataList["today"]["completed"].indexWhere((task) => value["task_id"] == task["task_id"]);

                          if (todayTaskID != -1 || todayCompletedID != -1){
                            // move to completed
                            if (value["checked"]) {
                              dataList["today"]["main_tasks"].removeAt(index);
                              dataList["today"]["completed"].insert(index, value);
                            
                            // move to main_tasks
                            } else {
                            dataList["today"]["main_tasks"].insert(index, value);
                            dataList["today"]["completed"].removeAt(index);

                            }
                            
                          }

                          setState(() {
                            DataUtils.writeJsonFile(dataList);
                          });

                        },
                      ));

                      DataUtils.writeJsonFile(dataList);

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
