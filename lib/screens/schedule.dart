// ignore_for_file: avoid_print

import "package:dropdown_button2/dropdown_button2.dart";
import "package:easy_date_timeline/easy_date_timeline.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:intl/intl.dart";
import "package:todo_app/components/card_field.dart";
import "package:todo_app/components/navigation_panel.dart";
import "package:todo_app/components/right_sidepanel.dart";
import "package:todo_app/components/task_list.dart";
import "package:todo_app/utils/data_utils.dart";
import "package:todo_app/utils/date_formatter.dart";

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
                      // TODO: check how it scrolls to current date widget.
                      // maybe through size and when does it do it.
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
                          setState(() {
                            matchTaskWithSelectedDate = value.toString().split(" ")[0];
                            print(value);
                          });
                        },
                      ),
                      // TODO: switch to a gridview.builder?
                      const Divider(
                        thickness: 1,
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${tasksWithDueDate[task]["name"]}"),
                                    Text("${tasksWithDueDate[task]["due_date"]}"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
  late DateTime firstDate = widget.firstDate;
  late DateTime lastDate = widget.lastDate;

  late String shortDay;
  late String dateNumber;
  late String monthName;

  bool isSelected = false;
  bool dateHasTasks = false;


  void changeDate(DateTime currentIndexDay) {
    shortDay = CalendarDateFormatter.shortDay(currentIndexDay);
    dateNumber = currentIndexDay.day.toString();
    monthName = CalendarDateFormatter.monthName(currentIndexDay);
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
 
  Map<String, int> monthMap = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Aug": 8,
    "Sep": 9,
    "Oct": 10,
    "Nov": 11,
    "Dec": 12,
  };


  late String? selectedValue = monthMap.keys.toList()[widget.focusDate.month - 1];


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                CalendarDateFormatter.dayName(focusedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(flex: 2,),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  firstDate = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
                  lastDate = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
                  focusedDate = DateTime(widget.focusDate.year, widget.focusDate.month, widget.focusDate.day);

                  // widget.onDateChange.call(focusedDate);                 

                });
              },
              child: const Text(
                "Today",
              )
            ),
            const SizedBox(width: 10),
            DropdownButton2(
              value: selectedValue,
              items: monthMap.keys.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;

                  int month = monthMap[value]!;
                  
                  firstDate = DateTime(firstDate.year, month, firstDate.day);
                  lastDate = DateTime(lastDate.year, month + 1, lastDate.day);
                  focusedDate = DateTime(focusedDate.year, month, focusedDate.day);

                  // widget.onDateChange.call(focusedDate);

                });
              },
              
            ),
            
          ],
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: daysBetween(firstDate, lastDate),
            itemBuilder: (context, index) {
              DateTime currentIndexDay = firstDate.add(Duration(days: index));
              
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
                    widget.onDateChange.call(focusedDate);
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
        ),
      ],
    );
  }
}
