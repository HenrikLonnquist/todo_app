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

  @override
  Widget build(BuildContext context) {
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
                          print("date");
                        },
                      ),
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
