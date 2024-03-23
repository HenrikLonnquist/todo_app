// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import "package:easy_date_timeline/easy_date_timeline.dart";
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/model/data_model.dart';
import 'package:todo_app/utils/data_utils.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    // required this.title,
    required this.dataList,
  });

  // final String title;

  final Map dataList;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  
  bool isRightPanelOpen = false;

  late int mainTaskIndex;

  Map tasksWithDueDate = {};

  String matchTaskWithSelectedDate = DateTime.now().toString().split(" ")[0];
  
  late int pressedTask;



  @override
  Widget build(BuildContext context) {
    tasksWithDueDate.clear();
    for (var i = 0; i < widget.dataList["main_tasks"].length; i++) {
      var data = widget.dataList["main_tasks"][i];
      var conditionCheck = data.toString();
      if (conditionCheck.contains("due_date") && conditionCheck.contains(matchTaskWithSelectedDate)) {
        tasksWithDueDate[i] = data;
      }
    }
    return Row(
      children: [
        Container(
          // duration: const Duration(seconds: 10),
          // curve: Curves.fastEaseInToSlowEaseOut,
          width: isRightPanelOpen ? 
          MediaQuery.of(context).size.width * 0.55 :
          MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(10),
          color: Colors.blue, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Title(
                  color: Colors.black, 
                  child: const Text(
                    "Schedule",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      // fontFamily: ,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      EasyDateTimeLine(
                        initialDate: DateTime.now(),
                        onDateChange: (selectedDate) {
                          print(selectedDate);
                          setState(() {
                            matchTaskWithSelectedDate = selectedDate.toString().split(" ")[0];
                            isRightPanelOpen = false;
                          });
                          // print(DateTime.now());
                        },
                      ),
                      // TODO: switch to a gridview.builder?
                      const Divider(
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          for (var task in tasksWithDueDate.keys) 
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isRightPanelOpen && pressedTask != task ) {
                                  pressedTask = task;
                                  return;
                                }
                                pressedTask = task;
                                // TODO: for now have toggle, maybe change to a button later
                                isRightPanelOpen = !isRightPanelOpen;
                              });
                            },
                            child: Card(
                              child: Column(
                                children: [
                                  Text('${tasksWithDueDate[task]["name"]}'),
                                  Text('${tasksWithDueDate[task]["due_date"]}'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                      CardField(
                        onSubmitted: (value) {
                          var template = dataTemplate(
                            name: value,
                            dueDate: matchTaskWithSelectedDate
                          );
                          widget.dataList["main_tasks"].add(template);
                          setState(() {
                            DataUtils().writeJsonFile(widget.dataList);
                          });
                        },
                      ),
                    ],
                  )
                ),
              )
            ],
          ), 
        ),
        if (isRightPanelOpen) RightSidePanel(
          child: SubTaskLIst(
            title: widget.dataList["main_tasks"][pressedTask]["name"],
            mainTaskSubList: widget.dataList["main_tasks"][pressedTask]["sub_tasks"], 
            onChanged: (value) {
              if (value.runtimeType == String) {
                Map templateSub = {
                  "name": value
                };
                widget.dataList["main_tasks"][mainTaskIndex]["sub_tasks"].add(templateSub);
              }
              setState(() {
                DataUtils().writeJsonFile(widget.dataList);
              });
            }, 
          ),
        ),              
      ],
    );
  }
}
