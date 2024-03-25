// ignore_for_file: avoid_print

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/navigation_panel.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/utils/data_utils.dart';
import 'package:todo_app/utils/date_formatter.dart';

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

  DateTime now = DateTime.now();


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
                      // Expanded(
                      // EasyDateTimeLine(
                      //   initialDate: DateTime.now(),
                      //   onDateChange: (value) {
                      //     print(value);
                      //   },
                      // ),
                      Calendar(
                        //* 5 days(workdays) showing
                        // firstDate: now.subtract(Duration(days: now.weekday - 1)),
                        // lastDate: now.add(Duration(days: 5 - now.weekday + 1)),
                        //* 7 days(weekdays) showing
                        // firstDate: now.subtract(Duration(days: now.weekday - 1)),
                        // lastDate: now.add(Duration(days: 7 - now.weekday)),
                        //* 30 days showing
                        firstDate: now.subtract(Duration(days: now.day - 1)),
                        lastDate: now.add(Duration(days: DateTime(now.year, now.month + 1, 0).day - now.day + 1)),
                        focusDate: DateTime.now(),
                        datesWithTasks: tasksWithDueDate,
                        onDateChange: (value) {
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
                          var template = DataUtils.dataTemplate(
                            name: value,
                            dueDate: matchTaskWithSelectedDate
                          );
                          widget.dataList["main_tasks"].add(template);
                          setState(() {
                            DataUtils.writeJsonFile(widget.dataList);
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
                DataUtils.writeJsonFile(widget.dataList);
              });
            }, 
          ),
        ),              
      ],
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    required this.firstDate,
    required this.lastDate, 
    required this.focusDate,
    required this.onDateChange, 
    this.datesWithTasks = const {},
  });

  final DateTime firstDate, lastDate, focusDate;
  final Map datesWithTasks;
  final Function(DateTime) onDateChange;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {  
  late DateTime focusedDate = widget.focusDate;
  late String shortDay;
  late String dayName;
  late String dateNumber;
  late String monthName;

  bool isSelected = false;
  bool dateHasTasks = false;


  void changeDate(DateTime currentIndexDay) {
    shortDay = CalendarDateFormatter.shortDay(currentIndexDay);
    dayName = CalendarDateFormatter.dayName(currentIndexDay);
    dateNumber = currentIndexDay.day.toString();
    monthName = CalendarDateFormatter.monthName(currentIndexDay);
    // fullDate = CalendarDateFormatter.fullDate(currentIndexDay);
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
 
  

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: false,
        scrollDirection: Axis.horizontal,
        itemCount: daysBetween(widget.firstDate, widget.lastDate),
        itemBuilder: (context, index) {
          DateTime currentIndexDay = widget.firstDate.add(Duration(days: index));
          
          isSelected = focusedDate.day.compareTo(currentIndexDay.day) == 0;
          dateHasTasks = false;
      
          for (var i in widget.datesWithTasks.values) {
            if (currentIndexDay.toString().contains(i["due_date"])) {
              dateHasTasks = true;
            }
          }

          changeDate(currentIndexDay);

          // TODO: create an function or class for this.
          // check out the "timeline_widget.dart" file for how its done.
          return InkWell(
            onTap: () {
              setState(() {
                focusedDate = currentIndexDay;
              });
            },
            child: Container(
              width: 68.0,
              margin: const EdgeInsets.all(8.0),
              padding: dateHasTasks ? 
              const EdgeInsets.fromLTRB(8, 8, 8, 0) : 
              const  EdgeInsets.fromLTRB(8, 8, 8, 9),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.focusDate.day.compareTo(currentIndexDay.day) == 0 
                  && !isSelected 
                  ? Colors.black 
                  : Colors.black.withOpacity(0.1),
                  width: 1,
                ),
                color: isSelected ? Colors.deepPurple : null,
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
                    dateNumber,
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
                    shortDay,
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
            ),
          );
        },
      ),
    );
  }
}
