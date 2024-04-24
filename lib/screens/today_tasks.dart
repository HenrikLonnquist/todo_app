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

  DateTime now = DateTime.now();
  late DateTime dateNow = DateTime(now.year, now.month, now.day);

  // init will be called when switching to today page
  @override
  initState(){
    

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    // todo: need notify this class when its a new day. 
    //! and when an task has been updated to then run the build.

    // todo: make an function in datautils for updating todays list
    // maybe the if else statement shoudl be made into a datautils function as well.


    // todo: adding a due date will automatically add to todays list if the date is today.
    
    //! TODO: BUG: I only want to empty them when its a new day
    //! might now need this code snippet?
    //! might just update the date in todays list where I will have the timer.periodic running.
    // ignore: dead_code
    if (false){
    // if (widget.dataList["today"]["dateToday"] != dateNow.toString()){
      widget.dataList["today"]["dateToday"] = dateNow.toString();
      widget.dataList["today"]["completed"].clear();
      widget.dataList["today"]["main_tasks"].clear();
      
      // adding together all the lists
      todaysTasks.clear();
      todaysTasks.add(widget.dataList["main_page"]);
      todaysTasks.addAll(widget.dataList["user_lists"]);

      for (var i in todaysTasks){
        if (i["main_tasks"].length != 0) {

          for(var j = 0; j < i["main_tasks"].length; j++) {
            Map task = i["main_tasks"][j];
            if(task["due_date"] != "" && DateTime.parse(task["due_date"]) == dateNow) {
              task["index"] = j;
              widget.dataList["today"]["main_tasks"].add(task);
            }
          }
        }
      }

    }

    // print(widget.dataList["today"]["main_tasks"]);


    return MainTasksPage(
      title: "Today",
      dataList: widget.dataList["today"],
      onUserUpdate: (value) {
        //! todo: I need to do this for the other pages as well,
        //! check if any task is in todays list to delete or change when
        //! changes has been made in the original list
        int index = value!["index"];
        if (widget.dataList["main_page"]["id"] == value["list_id"]) {

          // false == main_tasks, true == completed
          if (value["checked"]) {
            widget.dataList["main_page"]["completed"].insert(0, value);
            widget.dataList["main_page"]["main_tasks"].removeAt(index);

          } else {
            widget.dataList["main_page"]["main_tasks"].insert(index, value);
            var completedIndex = widget.dataList["main_page"]["completed"].indexWhere((task) => task["task_id"] == value["task_id"]);
            widget.dataList["main_page"]["completed"].removeAt(completedIndex);

          }

          setState(() {
            DataUtils.writeJsonFile(widget.dataList);
          });
          // print(widget.dataList["main_page"]["main_tasks"]);
          // print(widget.dataList["main_page"]["completed"]);
        } else {
          for (var i = 0; i < widget.dataList["user_lists"].length; i++) {
            var taskList = widget.dataList["user_lists"][i];

            if (taskList["id"] == value["list_id"]) {
              if (value["checked"]) {
                taskList["completed"].insert(0, value);
                taskList["main_tasks"].removeAt(index);

              } else {
                taskList["main_tasks"].insert(index, value);
                var completedIndex = taskList["completed"].indexWhere((task) => task["task_id"] == value["task_id"]);
                taskList["completed"].removeAt(completedIndex);
                
              }

              setState(() {
                DataUtils.writeJsonFile(widget.dataList);
              });

              return;
            }
          }
        }
                       
      },
    );
  }
}
