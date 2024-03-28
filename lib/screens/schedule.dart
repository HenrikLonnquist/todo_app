// ignore_for_file: avoid_print

import "package:dropdown_button2/dropdown_button2.dart";
import "package:flutter/material.dart";
import "package:todo_app/components/card_field.dart";
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

  Map tasksWithDueDate = {};

  DateTime now = DateTime.now();

  late var mainTasks = widget.dataList["main_tasks"];

  late DateTime matchTaskWithSelectedDate = DateTime(now.year, now.month, now.day);
  
  late int pressedTask;



  @override
  Widget build(BuildContext context) {
    tasksWithDueDate.clear();
    var dataTask = widget.dataList["main_tasks"];
    for (var i = 0; i < dataTask.length; i++) {
      // var taskCheck = dataTask[i].toString();
      //  && taskCheck.contains(matchTaskWithSelectedDate)
      if (dataTask[i]["due_date"] != "") {
        var parsedDate = DateTime.parse(dataTask[i]["due_date"]);
        tasksWithDueDate[i] = parsedDate;
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
                      //   },
                      // ),
                      Calendar(
                        //* 5 days(workdays) showing
                        // firstDate: now.subtract(Duration(days: now.weekday - 1)),
                        // lastDate: now.add(Duration(days: 5 - now.weekday + 1)),
                        //! TODO: rename property - initial date?
                        focusDate: DateTime(now.year, now.month, now.day),
                        // viewState: workdays, weekdays, monthly,
                        datesWithTasks: tasksWithDueDate,
                        onDateChange: (value) {
                          setState(() {
                            matchTaskWithSelectedDate = value;
                          });
                        },
                      ),
                      // TODO: switch to a gridview.builder?
                      const Divider(
                        thickness: 1,
                      ),
                      // TODO: i should integrated this to calendar later on.
                      Expanded(
                        flex: 4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var task in tasksWithDueDate.keys) 
                            if (tasksWithDueDate[task].compareTo(matchTaskWithSelectedDate) == 0) InkWell(
                              onTap: () {
                                setState(() {
                                  if (isRightPanelOpen && pressedTask != task) {
                                    pressedTask = task;
                                    return;
                                  }
                                
                                  pressedTask = task;
                                  isRightPanelOpen = !isRightPanelOpen;
                                });
                              },
                              child: Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${mainTasks[task]["name"]}"),
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
                            dueDate: matchTaskWithSelectedDate.toString()
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
            title: mainTasks[pressedTask]["name"],
            mainTask: mainTasks[pressedTask], 
            onChanged: (value) {
              if (value.runtimeType == String) {
                Map templateSub = {
                  "name": value
                };
                mainTasks[pressedTask]["sub_tasks"].add(templateSub);
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
    required this.focusDate,
    required this.onDateChange, 
    this.datesWithTasks = const {},
  });

  final DateTime focusDate;
  final Map datesWithTasks;
  final Function(DateTime) onDateChange;

  @override
  State<Calendar> createState() => _CalendarState();
}


enum CalendarView {workdays, weekdays, month, year}

class _CalendarState extends State<Calendar> {  
  late DateTime focusedDate = widget.focusDate;

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
  
  Map<String, int> weekDaysMap = {
    "Mon": 1,
    "Tue": 2,
    "Wed": 3,
    "Thu": 4,
    "Fri": 5,
    "Sat": 6,
    "Sun": 7,
  };

  late String? selectedValue = monthMap.keys.toList()[widget.focusDate.month - 1];

  CalendarView selectedViewState = CalendarView.month;
  late CalendarView prevSelectedViewState = CalendarView.month;


  


  @override
  Widget build(BuildContext context) {
    
    Map<CalendarView, Widget> viewState = {
      CalendarView.workdays: const Placeholder(),
      CalendarView.weekdays: const Placeholder(),
      CalendarView.month: MonthView(
            // dateNow: prevSelectedViewState == selectedViewState 
            // // && focusedDate != 
            // ? focusedDate 
            // : widget.focusDate,
            dateNow: focusedDate,
            today: widget.focusDate,
            days: DateTime(focusedDate.year, focusedDate.month + 1, 0).day,
            datesWithTasks: widget.datesWithTasks,
            onDateChange: (value) {
              setState(() {
                focusedDate = value;
                widget.onDateChange.call(value);
              });
            },
          ),
      // "7-day": WeekDaysView(),
      // "Workdays": WorkDaysView(),
    };
    if (selectedViewState != prevSelectedViewState) {
      prevSelectedViewState = selectedViewState;
    }

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
            const Spacer(flex: 2),
            SegmentedButton(
              showSelectedIcon: false,
              selected: {selectedViewState},
              onSelectionChanged: (value) {
                setState(() {
                  selectedViewState = value.first;
                });
              },
              segments: const [
                ButtonSegment(
                  value: CalendarView.workdays,
                  label: Text("Workdays"),
                  // enabled: selectedViewState != CalendarView.workdays 
                  // icon:
                ),
                ButtonSegment(
                  value: CalendarView.weekdays,
                  label: Text("Weekdays"),
                  // enabled: selectedViewState != CalendarView.weekdays 
                  // icon:
                ),
                ButtonSegment(
                  value: CalendarView.month,
                  label: Text("Month"),
                  // enabled: selectedViewState != CalendarView.month 
                  // icon:
                )
              ],
            ),
            const Spacer(flex: 2,),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  focusedDate = DateTime(widget.focusDate.year, widget.focusDate.month, widget.focusDate.day);
                  
                  // if there is tasks showing
                  widget.onDateChange(focusedDate);
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
                  
                  focusedDate = DateTime(focusedDate.year, month, 15);

                  widget.onDateChange.call(focusedDate);

                });
              },
              
            ),
            
          ],
        ),
        viewState[selectedViewState]!
      ],
    );
  }
}

class MonthView extends StatefulWidget{
  const MonthView({
    super.key,
    required this.days,
    required this.dateNow,
    required this.today,
    required this.onDateChange,
    required this.datesWithTasks,
  });


  final Function(DateTime) onDateChange;
  final Map datesWithTasks;
  final int days;
  final DateTime dateNow, today;

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  //* 30 days showing
  late DateTime now;
  late DateTime firstDate;
  late DateTime imToday = widget.today;
  late Map<String, String> formattedDates;

  late bool dateHasTasks;
  late bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    now = widget.dateNow;
    firstDate = now.subtract(Duration(days: now.day - 1));
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.days,
        itemBuilder: (context, index) {
          DateTime currentIndexDay = firstDate.add(Duration(days: index));
          
          isSelected = now.day.compareTo(currentIndexDay.day) == 0;
          dateHasTasks = widget.datesWithTasks.containsValue(currentIndexDay);

          formattedDates = CalendarDateFormatter.parseAll(currentIndexDay);
          
          // TODO: create an function or class for this.
          // check out the "timeline_widget.dart" file for how its done.
          return InkWell(
            onTap: () {
              setState(() {
                widget.onDateChange.call(currentIndexDay);
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
                  color: imToday.compareTo(currentIndexDay) == 0 
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
                    formattedDates["monthName"]!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : const Color(0xff6D5D6E),
                    ),
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    "${currentIndexDay.day}",
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
                    formattedDates["shortDay"]!,
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

class WeekDaysView extends StatelessWidget {
  const WeekDaysView({
    super.key,
  });

  //* 7 days(weekdays) showing
  // firstDate: now.subtract(Duration(days: now.weekday - 1)),
  // lastDate: firstDate.add(Duration(days: 6)),

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
