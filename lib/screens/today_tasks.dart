// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/screens/main_tasks.dart';
import 'package:todo_app/utils/data_utils.dart';

class TodayTasks extends StatefulWidget {
  const TodayTasks({
    super.key,
    required this.dataList,
  });

  final Map dataList;

  @override
  State<TodayTasks> createState() => _TodayTasksState();
}

class _TodayTasksState extends State<TodayTasks> {
  List todaysTasks = [];
  late List dataUserLists = widget.dataList["user_lists"];

  DateTime now = DateTime.now();
  late DateTime dateNow = DateTime(now.year, now.month, now.day);

  @override
  initState(){

    if (true){
    // if (widget.dataList["today"]["dateToday"] != dateNow.toString()){
      widget.dataList["today"]["main_tasks"].clear();
      widget.dataList["today"]["completed"].clear();
      // dataTaskLists.add(widget.dataList["main_page"]);

      //! Try the try-catch statement.
      // because the "user_lists" value is not a map but a list.
      for (var i in widget.dataList.values){
        // print(i["main_tasks"]);
        // if (i["main_tasks"].length != 0) {
        //   todaysTasks.add(i);
        // }
      }

      // TODO: try to add or incorporate the unique keys from the different lists somewhere in todays
      // data
      // Just add the list id to every task for now. Unless I can come up with a better idea/way.
      for(var taskList in todaysTasks){
        print(taskList);
        // for(var task in taskList) {
        //   String taskDate = task["due_date"];
        //   if(taskDate != "" && DateTime.parse(taskDate) == dateNow) {
        //     task["original_listID"] = taskList["id"];
        //     widget.dataList["today"]["main_tasks"].add(task);
        //   }
        // }
      }
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return MainTasksPage(
      title: "Today",
      dataList: widget.dataList["today"],
      onUserUpdate: (value) {
        setState(() {
          //! cant delete or set the task to as completed on the original task.
          // maybe just do an lookup with same value, i guess this is where id good.
          DataUtils.writeJsonFile(widget.dataList);
        });
        
      },
    );
  }
}
