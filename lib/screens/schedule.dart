// ignore_for_file: avoid_print

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
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
                        onDateChange: (value) {
                          print(value);
                        },
                      ),
                      Calendar(
                        firstDate: DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
                        lastDate: DateTime.now().add(Duration(days: DateTime.now().weekday - 6)),
                        focusDate: DateTime.now(),
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
    required this.onDateChange
  });

  final DateTime firstDate, lastDate, focusDate;
  final Function(DateTime) onDateChange;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {  
  DateTime dateNow = DateTime.now();
  late ValueNotifier<DateTime?> _focusedDateListener;
  
  late String shortDay;
  late String dayName;
  late String dateNumber;
  late String monthName;
  // late DateTime fullDate;
  bool isSelected = false;
  bool dateHasTasks = false;

  Map tasksWithDueDate = {};

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

  void _onFocusedDateChange(DateTime date) {
    _focusedDateListener.value = date;
    widget.onDateChange.call(date);
  }

  @override
  void dispose() {
    _focusedDateListener.dispose();
    super.dispose();
  }
  
  void _onDayChanged(bool isSelected, DateTime currentDate){
    widget.onDateChange.call(currentDate);
  }

  @override
  void initState() {
    super.initState();
    _focusedDateListener = ValueNotifier(widget.focusDate);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: _focusedDateListener,
        builder: (context, focusedDate, child) {
          return ListView.builder(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            itemCount: daysBetween(widget.firstDate, widget.lastDate),
            itemBuilder: (context, index) {
              DateTime currentIndexDay = widget.firstDate.add(Duration(days: index));
              bool imToday = widget.focusDate.day.compareTo(currentIndexDay.day) == 0;

              for (var i in tasksWithDueDate.values) {
                if (currentIndexDay.toString().contains(i["due_date"])) {
                  dateHasTasks = true;
                }
              }
              
              changeDate(currentIndexDay);
              print(isSelected);
          
              if (imToday && !isSelected) {
                isSelected = true;
              }
          
              // TODO: create an function or class for this.
              // check out the "timeline_widget.dart" file for how its done.
              return DayWidget(
                shortDay: shortDay,
                dateNumber: dateNumber,
                monthName: monthName,
                // TODO: above put it inside of daywidget class later
                date: currentIndexDay,
                isSelected: isSelected,
                onDayPressed: () {
                  setState(() {
                    // isSelected = !isSelected;
                    // // isSelected = !isSelected;
                    // _onDayChanged(isSelected, currentIndexDay);
                  });
                  // print("$isSelected $currentIndexDay");
                  // print(focusedDate);
                  // _onFocusedDateChange(currentIndexDay);
                  // widget.onDateChange.call(currentIndexDay);
                },
              );
            },
          );
        }
      ),
    );
  }
}


class DayWidget extends StatelessWidget {
  const DayWidget({
    super.key, 
    required this.date, 
    required this.isSelected, 
    required this.onDayPressed,
    // required this.child,
    this.dateHasTasks = false, 
    required this.shortDay, 
    required this.dateNumber, 
    required this.monthName,
  });

  final DateTime date;
  final String shortDay;
  final String dateNumber;
  final String monthName;
  final bool isSelected;
  final VoidCallback onDayPressed;
  final bool dateHasTasks;
  
  // final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onDayPressed,
      child: Container(
        width: 68.0,
        margin: const EdgeInsets.all(8.0),
        padding: dateHasTasks ? 
        const EdgeInsets.fromLTRB(8, 8, 8, 0) : 
        const  EdgeInsets.fromLTRB(8, 8, 8, 9),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.black.withOpacity(0.1),
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
  }
}
