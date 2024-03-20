// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/task_list.dart';

class SubTaskPanel extends StatelessWidget {
  const SubTaskPanel({
    super.key,
    required this.mainTaskSubList, 
    this.onChanged,
  });

  final List mainTaskSubList;
  final ValueChanged? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.blueAccent,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TaskList(
              dataList: mainTaskSubList,
              subTask: true,
              onChanged: (listValue) {
                // List
                print("side panel: $listValue");
                // this is will always be a sub task list
                // and I have to send it back to main task 
    
                // onChanged!.call(listValue);
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CardField(
              onSubmitted: (stringValue) {
                // Textfield
                onChanged!.call(stringValue);
              },
            )
          ),
          const Divider(thickness: 2,),
          // due dates: date
          // reminder: time + date
          // repeat: dates(days)
          // notes: Textfield
        ],
      ),
    );
  }
}
