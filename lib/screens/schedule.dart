// ignore_for_file: avoid_print


import "package:dropdown_button2/dropdown_button2.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:todo_app/components/card_field.dart";
import "package:todo_app/components/right_sidepanel.dart";
import "package:todo_app/components/task_list.dart";
import "package:todo_app/utils/data_utils.dart";
import "package:todo_app/utils/date_formatter.dart";

class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    required this.database,
  });

  final Map database;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  
  bool isRightPanelOpen = false;

  

  DateTime now = DateTime.now();

  late DateTime selectedDate = DateTime(now.year, now.month, now.day);
  
  late int pressedTask;

  late List dataList = widget.database["main_tasks"];


  @override
  Widget build(BuildContext context) {

    

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
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
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
                        database: widget.database,
                        onPressedTask: (value) {
                          setState(() {
                            if (isRightPanelOpen && pressedTask != value) {
                              pressedTask = value;
                              return;
                            }
                            pressedTask = value;
                            isRightPanelOpen = !isRightPanelOpen;
                          });
                        },
                        onDateChange: (value) {
                          setState(() {
                            selectedDate = value;
                          });
                        },
                      ),
                      // TODO: if there is no date in the txt then add today or selected date.
                      CardField(
                        onSubmitted: (value) {
                          var template = DataUtils.dataTemplate(
                            name: value,
                            dueDate: selectedDate.toString()
                          );
                          widget.database["main_tasks"].add(template);
                          setState(() {
                            DataUtils.writeJsonFile(widget.database);
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
            title: dataList[pressedTask]["name"],
            mainTask: dataList[pressedTask], 
            onChanged: (value) {
              if (value.runtimeType == String) {
                Map templateSub = {
                  "name": value
                };
                dataList[pressedTask]["sub_tasks"].add(templateSub);
              }
              setState(() {
                DataUtils.writeJsonFile(widget.database);
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
    this.onPressedTask,
    required this.database ,
    this.child,
  });

  final Widget? child;
  final Function(int)? onPressedTask;
  final DateTime focusDate;
  final Map database;
  final Function(DateTime) onDateChange;

  @override
  State<Calendar> createState() => _CalendarState();
}


enum CalendarViewState {workdays, weekdays, month}

class _CalendarState extends State<Calendar> {  
  late DateTime focusedDate = widget.focusDate;
  late List dataTasks = widget.database["main_tasks"];

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
  
  List weekDaysMap = [
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
    "Sun",
  ];

  late String? selectedValue = monthMap.keys.toList()[widget.focusDate.month - 1];

  CalendarViewState selectedViewState = CalendarViewState.weekdays;

  Map tasksWithDueDate = {};

  void onDateChange(DateTime value){
    setState(() {
      focusedDate = value;
      widget.onDateChange.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    tasksWithDueDate.clear();
    for (var i = 0; i < dataTasks.length; i++) {
      if (dataTasks[i]["due_date"] != "") {
        var parsedDate = DateTime.parse(dataTasks[i]["due_date"]);
        tasksWithDueDate[i] = parsedDate;
      }
    }
    print("calendar: $selectedViewState");
    Map<CalendarViewState, Widget> viewState = {
      CalendarViewState.workdays: const Placeholder(),
      // CalendarViewState.weekdays: WeekDaysView(),
      CalendarViewState.weekdays: MonthView(
        viewState: CalendarViewState.weekdays,
        dateNow: focusedDate,
        today: widget.focusDate,
        days: 7,
        datesWithTasks: tasksWithDueDate,
        onDateChange: onDateChange,
        child: Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                for(var i = 0; i < weekDaysMap.length; i++) 
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Colors.black,
                          width: 1,
                        )
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 85,
                          child: Column(
                            children: [
                              Text(
                                '${weekDaysMap[i]}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  // color: 
                                  //   focusedDate.subtract(Duration(days: focusedDate.weekday - 1)).add(Duration(days: i)).day
                                  //   == focusedDate.day
                                  //   ? Colors.white
                                  //   : Colors.black,
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                alignment: AlignmentDirectional.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: 
                                  focusedDate.subtract(Duration(days: focusedDate.weekday - 1)).add(Duration(days: i)).day
                                  == focusedDate.day
                                  ? Colors.deepPurple
                                  : null,
                                ),
                                child: Text(
                                  '${
                                      focusedDate.subtract(Duration(days: focusedDate.weekday - 1)).add(Duration(days: i)).day
                                    }',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: 
                                      focusedDate.subtract(Duration(days: focusedDate.weekday - 1)).add(Duration(days: i)).day
                                      == focusedDate.day
                                      ? Colors.white
                                      : Colors.black,
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            onReorder: (oldIndex, newIndex) {
                              if(oldIndex < newIndex) {
                                newIndex -= 1;
                              }

                              // Trying to match two different types, only works because taskswithduedate
                              // has the key as an the list index from database.
                              var matchOldIndex = tasksWithDueDate.keys.toList()[oldIndex];                             
                              var matchNewIndex = tasksWithDueDate.keys.toList()[newIndex];
                              final Map item = widget.database["main_tasks"].removeAt(matchOldIndex);
                              widget.database["main_tasks"].insert(matchNewIndex, item);
                              // print(dataTasks);
                              // print(widget.database);

                              setState(() {
                                DataUtils.writeJsonFile(widget.database);
                              });

                            },
                            itemCount: tasksWithDueDate.length,
                            itemBuilder: (context, index) {
                              var mainTaskID = tasksWithDueDate.keys.toList()[index];
                              var mainTaskDate = tasksWithDueDate.values.toList()[index];
                              var currentDate = focusedDate.subtract(Duration(days: focusedDate.weekday - 1)).add(Duration(days: i));

                              if ( mainTaskDate.day == currentDate.day) {
                                return ReorderableDragStartListener(
                                  key: Key("$index"),
                                  index: index,
                                  child: InkWell(
                                    onTap: () {
                                      widget.onPressedTask!.call(tasksWithDueDate.keys.toList()[index]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Card(
                                        child: Center(
                                          child: Text(
                                            "${dataTasks[mainTaskID]["name"]}",
                                            style: const TextStyle(
                                            ),
                                          ),
                                        )
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  key: Key("$index"),
                                );
                              }
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
      CalendarViewState.month: MonthView(
        viewState: CalendarViewState.month,
        dateNow: focusedDate,
        today: widget.focusDate,
        days: DateTime(focusedDate.year, focusedDate.month + 1, 0).day,
        datesWithTasks: tasksWithDueDate,
        onDateChange: onDateChange,
      ),
      // "7-day": WeekDaysView(),
      // "Workdays": WorkDaysView(),
    };

    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    selectedViewState == CalendarViewState.month
                    ? CalendarDateFormatter.dayName(focusedDate)
                    :CalendarDateFormatter.monthName(focusedDate),

                    style: TextStyle(
                      fontSize: 
                      selectedViewState == CalendarViewState.month
                      ? 18
                      : 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                    value: CalendarViewState.workdays,
                    label: Text("Workdays"),
                    // enabled: selectedViewState != CalendarViewState.workdays 
                    // icon:
                  ),
                  ButtonSegment(
                    value: CalendarViewState.weekdays,
                    label: Text("Weekdays"),
                    // enabled: selectedViewState != CalendarViewState.weekdays 
                    // icon:
                  ),
                  ButtonSegment(
                    value: CalendarViewState.month,
                    label: Text("Month"),
                    // enabled: selectedViewState != CalendarViewState.month 
                    // icon:
                  )
                ],
              ),
              const Spacer(flex: 2,),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    focusedDate = DateTime(widget.focusDate.year, widget.focusDate.month, widget.focusDate.day);
                    // selectedValue = focusedDate.month;
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
                value: monthMap.keys.toList()[focusedDate.month - 1],
                items: monthMap.keys.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: monthMap[value]! == focusedDate.month
                        ? Colors.purple
                        : null,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
      
                    focusedDate = DateTime(focusedDate.year, monthMap[value]!, 15);
      
                    widget.onDateChange.call(focusedDate);
      
                  });
                },
                
              ),
              
            ],
          ),
          viewState[selectedViewState]!,
          //! Remove the if condition? or change it to something else for
          //! the other view states. 
          /**
           * Weekdays and workdays, need a verical view of tasks.
           */
          // if (selectedViewState == CalendarViewState.month)
          // const Divider(
          //   thickness: 1,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     for(var task in tasksWithDueDate.keys) 
          //     if (tasksWithDueDate[task].compareTo(focusedDate) == 0) InkWell(
          //       onTap: () {
          //         widget.onPressedTask!.call(task);
          //       },
          //       child: Card(
          //         child: Text("${dataTasks[task]["name"]}"),
          //       ),
          //     )
          //   ],
          // )
          
        ],
      ),
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
    required this.viewState,
    this.child,
    this.onTap,
  });

  final CalendarViewState viewState;
  final Widget? child;
  final Function()? onTap;
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
  late CalendarViewState viewState;
  late DateTime firstDate;
  late DateTime imToday = widget.today;
  late Map<String, String> formattedDates;

  late bool dateHasTasks;
  late bool isSelected;
  
  @override
  Widget build(BuildContext context) {
    now = widget.dateNow;
    viewState = widget.viewState;
    switch (viewState) {
      case CalendarViewState.month:
        firstDate = now.subtract(Duration(days: now.day - 1));
        break;
      case CalendarViewState.weekdays:
      case CalendarViewState.workdays:
        firstDate = now.subtract(Duration(days: now.weekday - 1));
        break;
    }
    return widget.child ?? SizedBox(
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

class WeekDaysView extends StatefulWidget {
  const WeekDaysView({
    super.key, 
    // required this.onDateChange, 
    // required this.datesWithTasks, 
    // required this.days, 
    // required this.dateNow, 
    // required this.today,
  });

  // final Function(DateTime) onDateChange;
  // final Map datesWithTasks;
  // final int days;
  // final DateTime dateNow, today;

  @override
  State<WeekDaysView> createState() => _WeekDaysViewState();
}

class _WeekDaysViewState extends State<WeekDaysView> {
  // late DateTime now = widget.dateNow;
  //* 7 days(weekdays) showing
  // firstDate: now.subtract(Duration(days: now.weekday - 1)),
  // lastDate: firstDate.add(Duration(days: 6)),
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        
        itemCount: 7,
        itemBuilder: ((context, index) {
          
        })
      )
    );
  }
}
