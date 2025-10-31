// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/database.dart';

//TODO: Move it/place somewhere else, have to restart(ctrl+shift+f10) debug session instead of hot reload to an effect.
Color bgColorPanel = Colors.grey.shade900;

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({
    super.key,
    this.topBar,
    this.bottomBar,
    this.child, 
    this.show = false,
    this.sidePanelWidth = 340,
    required this.database,
  });

  final bool show;
  final Widget? child;
  final Widget? bottomBar;
  final Widget? topBar;
  final double sidePanelWidth;
  final AppDB database;


  @override
  Widget build(BuildContext context) {
    return show 
    ? Column(
      children: [
        topBar != null ? Container(
          width: sidePanelWidth,
          child: const Placeholder(),
        ) : SizedBox(width: 0, height: 0),
        Expanded(
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.95,
            width: sidePanelWidth,
            // width: MediaQuery.of(context).size.width * 0.3,
            color: bgColorPanel,
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ),
        bottomBar != null ? Container(
          // height: MediaQuery.of(context).size.height * 0.05,
          width: sidePanelWidth,
          color: bgColorPanel,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: bottomBar,
    
        ) : SizedBox(width: 0, height:0)
      ],
    )
    : const SizedBox(width: 0, height: 0);
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
        Expanded(
          child: Text(
            // TODO: GET info from Database
            "Created on Wed. 19 Jun 2025, hahahahaaah",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
            )
          ),
        ),
        ElevatedButton(
          onPressed: deleteTask,
          child: const Icon(Icons.delete),
        ),
      ],
    );
  }
}