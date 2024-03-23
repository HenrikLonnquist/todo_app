// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import "package:easy_date_timeline/easy_date_timeline.dart";
import 'package:todo_app/components/task_list.dart';
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
    var dataTask = widget.dataList["main_tasks"];
    for (var i = 0; i < dataTask.length; i++) {
      // var taskCheck = dataTask[i].toString();
      //  && taskCheck.contains(matchTaskWithSelectedDate)
      if (dataTask[i]["due_date"] != "") {
        tasksWithDueDate[i] = dataTask[i];
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
                          // print(selectedDate);
                          setState(() {
                            matchTaskWithSelectedDate = selectedDate.toString().split(" ")[0];
                            isRightPanelOpen = false;
                          });
                        },
                        itemBuilder: (context, dayNumber, dayName, monthName, fullDate, isSelected) {
                          String today = DateFormat("y-MM-d").format(DateTime.now());
                          bool imToday = fullDate.toString().contains(today);
                          bool dateHasTasks = false;

                          for (var i in tasksWithDueDate.values) {
                            if (fullDate.toString().contains(i["due_date"])) {
                              dateHasTasks = true;
                            }
                          }

                          return Container(
                            width: 56.0,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: imToday && !isSelected ? Colors.black : Colors.black.withOpacity(0.1),
                                width: 1,
                              ),
                              color: isSelected ? Colors.purple : null,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  monthName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : const Color(0xff6D5D6E),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  dayNumber,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : const Color(0xff393646),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8.0,
                                ),
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : const Color(0xff6D5D6E),
                                  ),
                                ),
                                if (dateHasTasks) const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // TODO: switch to a gridview.builder?
                      const Divider(
                        thickness: 1,
                      ),
                      Row(
                        children: [
                          for (var task in tasksWithDueDate.keys) 
                          if (tasksWithDueDate[task]["due_date"].contains(matchTaskWithSelectedDate)) InkWell(
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
                          var template = DataUtils().dataTemplate(
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
            mainTask: widget.dataList["main_tasks"][pressedTask], 
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
