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
  @override
  Widget build(BuildContext context) {
    Map todaysTasks = {"main_tasks": []};  
    var dataTaskLists = [];
    var dataUserList = widget.dataList["user_lists"];

    DateTime now = DateTime.now();
    DateTime dateNow = DateTime(now.year, now.month, now.day);

    dataTaskLists.add(widget.dataList["main_tasks"]);

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
      dataList: todaysTasks,
      onUserUpdate: () {
        setState(() {
          DataUtils.writeJsonFile(widget.dataList);
        });
        
      },
    );
  }
}
