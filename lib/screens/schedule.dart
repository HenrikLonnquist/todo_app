// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import "package:easy_date_timeline/easy_date_timeline.dart";

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
  
  bool isSubPanelOpen = false;

  late int mainTaskIndex;

  List tasksWithDueDate = [];

  String matchTaskWithSelectedDate = DateTime.now().toString().split(" ")[0];



  @override
  Widget build(BuildContext context) {
    tasksWithDueDate.clear();
    print(matchTaskWithSelectedDate);
    for (var i in widget.dataList["main_tasks"]) {
      var conditionCheck = i.toString();
      if (conditionCheck.contains("due_date") && conditionCheck.contains(matchTaskWithSelectedDate)) {
        tasksWithDueDate.add(i);
      }
    }
    return Row(
      children: [
        Container(
          // duration: const Duration(seconds: 10),
          // curve: Curves.fastEaseInToSlowEaseOut,
          width: isSubPanelOpen ? 
          MediaQuery.of(context).size.width * 0.5 :
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
                          });
                          // print(DateTime.now());
                        },
                      ),
                      // tasks corresponding to selected date
                      
                      // switch to a gridview.builder?
                      const Divider(
                        thickness: 1,
                      ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      Row(
                        children: [
                          for (var i = 0; i < tasksWithDueDate.length; i++) 
                          Card(
                            child: Column(
                              children: [
                                // TODO: maybe able to open an side panel for this.
                                
                                // for (var i = in)
                                Text('${widget.dataList["main_tasks"][i]["name"]}'),
                                Text('${widget.dataList["main_tasks"][i]["due_date"]}'),
                              ],
                            ),
                          ),
                        ],
                      )

                    ],
                  )
                ),
              )
            ],
          ), 
        ),
        // how do I know which one it is? What index..
        // change the 0 to a variable?
        // setstate > 
        if (isSubPanelOpen) const RightSidePanel(
        ),              
      ],
    );
  }
}
