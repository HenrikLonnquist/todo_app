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
  
  int pressedTask = 0;

  Map allTasks = {};
  List dataList = [];

  @override
  void initState() {
    dataList.addAll(widget.database["main_page"]["main_tasks"]);

    for (var i in widget.database["user_lists"]) {
      if (i["main_tasks"].length != 0) {
        dataList.addAll(i["main_tasks"]);
      }
    }

    allTasks["main_tasks"] = dataList;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            // duration: const Duration(seconds: 10),
            // curve: Curves.fastEaseInToSlowEaseOut,
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade700, 
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
                  child: Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Calendar(
                                //! TODO: rename property - initial date?
                                focusDate: DateTime(now.year, now.month, now.day),
                                database: allTasks,
                                updateDatabase: (value) {

                                  // Changing the due date of the task in the original list
                                  if (widget.database["main_page"]["id"] == value["list_id"]) {
                                    for (var i = 0; i < widget.database["main_page"]["main_tasks"].length; i++) {
                                      var taskList = widget.database["main_page"]["main_tasks"];

                                      if (taskList[i]["task_id"] == value["task_id"]) {
                                        taskList[i] = value;

                                        setState(() {
                                          DataUtils.writeJsonFile(widget.database);
                                        });
                                        return;
                                      }
                                    }
                                  } else {
                                    for (var i = 0; i < widget.database["user_lists"].length; i++) {
                                      // todo: maybe make the second for  loop an function, looks similar to
                                      // one above(if statement)
                                      var taskList = widget.database["user_lists"][i];
                                      for ( var j = 0; j < taskList["main_tasks"].length; j++) {
                                        if (taskList["main_tasks"][j]["task_id"] == value["task_id"]) {
                                          taskList["main_tasks"][j] = value;

                                          setState(() {
                                            DataUtils.writeJsonFile(widget.database);
                                          });
                                          return;
                                        }
                                      }
                                    }
                                  }
                                },
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
                            ],
                          )
                        ),
                      ),
                      CardField(
                        onSubmitted: (value) {
                          // todo: needs further refinement. Like where should the task be put in
                          // //* workday or week tab?
                          
                          // var template = DataUtils.newTaskTemplate(
                          //   // database: widget.database,
                          //   name: value,
                          //   listID: widget.database["id"],
                          //   taskID: DateTime.now().millisecondsSinceEpoch
                          //   dueDate: selectedDate.toString()
                          // );
                          // widget.database["main_tasks"].add(template);
                          // setState(() {
                          //   DataUtils.writeJsonFile(widget.database);
                          // });
                        },
                      ),
                    ],
                  ),
                )
              ],
            ), 
          ),
        ),
        RightSidePanel(
          show: isRightPanelOpen,
          child: SubTaskList(
            title: allTasks["main_tasks"][pressedTask]["name"],
            mainTask: allTasks["main_tasks"][pressedTask], 
            onChanged: (value) {
              if (value.runtimeType == String) {
                var newSubTask = DataUtils.subTaskTemplate(
                  name: value
                );
                allTasks["main_tasks"][pressedTask]["sub_tasks"].add(newSubTask);
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
    this.updateDatabase,
    this.database = const {"main_tasks": []},
    this.child,
  });

  final Widget? child;
  final Function(int)? onPressedTask;
  final ValueChanged<Map>? updateDatabase;
  final DateTime focusDate;
  final Map database;
  final Function(DateTime) onDateChange;

  @override
  State<Calendar> createState() => _CalendarState();
}


enum CalendarViewState {today, workdays, weekdays, month}

class _CalendarState extends State<Calendar> {  
  late DateTime focusedDate = widget.focusDate;
  late List dataTasks = widget.database["main_tasks"] ?? [];
  Map<CalendarViewState, int> calendarViewStateDays = {
    CalendarViewState.today: 1,
    CalendarViewState.workdays: 5,
    CalendarViewState.weekdays: 7,
  };

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

  late DateTime weekDaysDates = widget.focusDate;

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
  
    Widget viewState;
    switch (selectedViewState) {
      case CalendarViewState.month:
        viewState = MonthView(
          viewState: CalendarViewState.month,
          dateNow: focusedDate,
          today: widget.focusDate,
          days: DateTime(focusedDate.year, focusedDate.month + 1, 0).day,
          datesWithTasks: tasksWithDueDate,
          onDateChange: onDateChange,
          taskArea: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for(var task in tasksWithDueDate.keys)
              if (tasksWithDueDate[task].compareTo(focusedDate) == 0) InkWell(
                onTap: () {
                  widget.onPressedTask!.call(task);
                },
                child: Card(
                  child: Text("${dataTasks[task]["name"]}"),
                ),
              )
            ],
          ),
        );
        break;
      case CalendarViewState.weekdays:
      case CalendarViewState.workdays:
      case CalendarViewState.today:
        viewState = MonthView(
          viewState: CalendarViewState.weekdays,
          dateNow: weekDaysDates,
          today: widget.focusDate,
          days: calendarViewStateDays[selectedViewState]!,
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

                  for(var i = 0; i < calendarViewStateDays[selectedViewState]!; i++) 
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
                      child: DragTarget(
                        onAcceptWithDetails: (details) {
                          DateTime droppedDate = (weekDaysDates.subtract(Duration(days: weekDaysDates.weekday - 1))).add(Duration(days: i));
                          widget.database["main_tasks"][details.data]["due_date"] = droppedDate.toString();
                          
                          // updating the task in the original list
                          widget.updateDatabase!.call(widget.database["main_tasks"][details.data]);
                          
                        },
                        builder: (context, accepted, rejected) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 85,
                                child: Column(
                                  crossAxisAlignment: selectedViewState == CalendarViewState.today 
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: selectedViewState == CalendarViewState.today 
                                      ? const EdgeInsets.only(left: 11.0)
                                      : null,
                                      child: Column(
                                        children: [
                                          Text(
                                            selectedViewState == CalendarViewState.today
                                            ? "${weekDaysMap[weekDaysDates.weekday - 1]}"
                                            : "${weekDaysMap[i]}",
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            alignment: AlignmentDirectional.center,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: 
                                              weekDaysDates.subtract(Duration(days: (
                                                selectedViewState == CalendarViewState.today 
                                                ? 1
                                                : weekDaysDates.weekday) - 1)).add(Duration(days: i)).day
                                              == widget.focusDate.day
                                              ? Colors.deepPurple
                                              : null,
                                            ),
                                            child: Text(
                                              '${
                                                selectedViewState == CalendarViewState.today
                                                ? weekDaysDates.day 
                                                : weekDaysDates.subtract(Duration(days: (weekDaysDates.weekday) - 1)).add(Duration(days: i)).day
                                                }',
                                              style: TextStyle(
                                                fontSize: 20,
                                                // TODO: maybe make this(condition check) into a function?
                                                color: 
                                                  weekDaysDates.subtract(Duration(days: (
                                                    selectedViewState == CalendarViewState.today 
                                                    ? 1
                                                    : weekDaysDates.weekday) - 1)).add(Duration(days: i)).day
                                                  == widget.focusDate.day
                                                  ? Colors.white
                                                  : Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                child: ListView.builder(
                                  // buildDefaultDragHandles: false,
                                  // onReorder: (oldIndex, newIndex) {
                                  //   if(oldIndex < newIndex) {
                                  //     newIndex -= 1;
                                  //   }
                                    
                                  //   // Trying to match two different types, only works because taskswithduedate
                                  //   // has the key as an the list index from database.
                                  //   var matchOldIndex = tasksWithDueDate.keys.toList()[oldIndex];                             
                                  //   var matchNewIndex = tasksWithDueDate.keys.toList()[newIndex];
                                  //   final Map item = widget.database["main_tasks"].removeAt(matchOldIndex);
                                  //   widget.database["main_tasks"].insert(matchNewIndex, item);
                                    
                                  //   setState(() {
                                  //     DataUtils.writeJsonFile(widget.database);
                                  //   });
                                    
                                  // },
                                  itemCount: tasksWithDueDate.length,
                                  itemBuilder: (context, index) {
                                    var mainTaskID = tasksWithDueDate.keys.toList()[index];
                                    var mainTaskDate = tasksWithDueDate.values.toList()[index];
                                    var currentDate = weekDaysDates.subtract(Duration(days: (
                                    selectedViewState == CalendarViewState.today
                                    ? 1
                                    : weekDaysDates.weekday) - 1)).add(Duration(days: i));
                                    
                                    //! Maybe I should have used the task list component instead
                                    if ( mainTaskDate.day == currentDate.day) {
                                      return Draggable<int>(
                                        data: mainTaskID,
                                        childWhenDragging: const SizedBox(height: 0,),
                                        feedback: Card(
                                          child: SizedBox(
                                            width: 120,
                                            height: 20,
                                            child: Center(
                                              child: Text(
                                                "${dataTasks[mainTaskID]["name"]}",
                                                style: const TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          )
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            widget.onPressedTask!.call(tasksWithDueDate.keys.toList()[index]);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Card(
                                              child: Container(
                                                padding: selectedViewState == CalendarViewState.today
                                                ? const EdgeInsets.only(left: 10)
                                                : null,
                                                alignment: selectedViewState == CalendarViewState.today
                                                ? AlignmentDirectional.centerStart
                                                : AlignmentDirectional.center,
                                                child: Text(
                                                  "${dataTasks[mainTaskID]["name"]}",
                                                  style: const TextStyle(
                                                    overflow: TextOverflow.ellipsis,
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
                          );
                        }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        );
        break;
    }
    


    return Expanded(
      child: Column(
        children: [
          Row(
            children: [
              //!BUG TODO: overflow when opening right side panel
              SizedBox(
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Text(
                    selectedViewState == CalendarViewState.month
                    ? CalendarDateFormatter.dayName(focusedDate)
                    :CalendarDateFormatter.monthName(weekDaysDates),

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
                    value: CalendarViewState.today,
                    label: Text("Today"),
                  ),
                  ButtonSegment(
                    value: CalendarViewState.workdays,
                    label: Text("Workdays"),
                  ),
                  ButtonSegment(
                    value: CalendarViewState.weekdays,
                    label: Text("Weekdays"),
                  ),
                  ButtonSegment(
                    value: CalendarViewState.month,
                    label: Text("Month"),
                  )
                ],
              ),
              const Spacer(flex: 2,),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    focusedDate = DateTime(widget.focusDate.year, widget.focusDate.month, widget.focusDate.day);
                    weekDaysDates = focusedDate;
                    // if there is tasks showing
                    widget.onDateChange(focusedDate);
                  });
                },
                child: const Text(
                  "Today",
                )
              ),
              const SizedBox(width: 10),
              // CalendarViewState.month == CalendarViewState.month 
              selectedViewState == CalendarViewState.month 
              ? DropdownButton2(
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
                
              )
              : Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (selectedViewState == CalendarViewState.today) {
                            weekDaysDates =  weekDaysDates.subtract(const Duration(days: 1));
                          } else {
                            weekDaysDates = DateTime(weekDaysDates.year, weekDaysDates.month, weekDaysDates.day - (weekDaysDates.weekday + 1));
                          }
                        });
                      }, 
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 18,
                      )
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (selectedViewState == CalendarViewState.today) {
                            weekDaysDates =  weekDaysDates.add(const Duration(days: 1));
                          } else {
                            weekDaysDates = weekDaysDates.add(Duration(days: (7 - weekDaysDates.weekday) + 1));
                          }
                        });
                      }, 
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                      )
                    ),
                  ],
                ),
              ),
              
            ],
          ),
          viewState,
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
    this.taskArea,
  }) 
  : assert( child == null || taskArea == null);

  final CalendarViewState viewState;
  final Widget? child;
  final Widget? taskArea;
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
  late Map tasksWithDueDate = widget.datesWithTasks;

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
      case CalendarViewState.today:
        firstDate = now.subtract(Duration(days: now.weekday - 1));
        break;
    }
    return widget.child ?? Column(
      children: [
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.days,
            itemBuilder: (context, index) {
              DateTime currentIndexDay = firstDate.add(Duration(days: index));
              
              
              isSelected = now.day.compareTo(currentIndexDay.day) == 0;
              dateHasTasks = widget.datesWithTasks.containsValue(currentIndexDay);
          
              formattedDates = CalendarDateFormatter.parseAll(currentIndexDay);
              
              // TODO: create an function(Widget) or class for this.
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
        ),
        const Divider(
          thickness: 1,
        ),
        widget.taskArea!,
        
      ],
    );
  }
}

