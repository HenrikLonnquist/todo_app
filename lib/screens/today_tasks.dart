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

    // todo: need notify this class when its a new day. 
    
    // if (true){
    if (widget.dataList["today"]["dateToday"] != dateNow.toString()){
      widget.dataList["today"]["main_tasks"].clear();
      widget.dataList["today"]["completed"].clear();
      todaysTasks.addAll(widget.dataList["main_page"]["main_tasks"]);

      for (var i in widget.dataList["user_lists"]){
        if (i["main_tasks"].length != 0) {
          todaysTasks.addAll(i["main_tasks"]);
        }
      }

      for(var task in todaysTasks) {
        String taskDate = task["due_date"];
        if(taskDate != "" && DateTime.parse(taskDate) == dateNow) {
          widget.dataList["today"]["main_tasks"].add(task);
        }
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
          DataUtils.writeJsonFile(widget.dataList);
        });
        
      },
    );
  }
}
