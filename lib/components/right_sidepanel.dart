// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({
    super.key,
    this.bottomBar,
    this.child, 
    this.show = false,
  });

  final bool show;
  final Widget? child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    return show 
    ? Column(
      children: [
        Flexible(
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.95,
            width: 380,
            // width: MediaQuery.of(context).size.width * 0.3,
            color: Colors.grey,
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ),
        Container(
          // height: MediaQuery.of(context).size.height * 0.05,
          width: 380,
          color: Colors.grey.shade800,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: bottomBar,

        )
      ],
    )
    : const SizedBox(height: 0);
  }
}


class TaskInfo extends StatefulWidget {
  const TaskInfo({
    super.key,
    });

  @override
  State<TaskInfo> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (value){
                setState(() {
                  isChecked = !isChecked;
                });
              },
            ),
            const Text(
              "Hello",
            )
          ]
        ),
      ],
    );
  }
}



class PanelBottomBar extends StatelessWidget {

  const PanelBottomBar({
    super.key, 
    required this.hidePanel,
    required this.deleteTask,
    
    });

  final VoidCallback hidePanel;   
  final VoidCallback deleteTask;   

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: hidePanel,
          child: const Icon(Icons.arrow_forward_ios), 
        ),
        Text(
          // TODO: GET info from Database
          "Created on Wed. 19 Jun 2025",
          style: TextStyle(
            color: Colors.white,
          )
        ),
        ElevatedButton(
          onPressed: deleteTask,
          child: const Icon(Icons.delete),
        ),
      ],
    );
  }
}