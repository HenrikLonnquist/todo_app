// ignore_for_file: avoid_print

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/database.dart';

//TODO: Move it/place somewhere else, have to restart(ctrl+shift+f10) debug session instead of hot reload to get an effect.

//MARK: Panel
class RightSidePanel extends StatelessWidget {
  const RightSidePanel({
    super.key,
    this.topBar,
    this.bottomBar,
    this.child, 
    this.show = true,
    this.sidePanelWidth = 340,
    this.database,
    this.padding,
    this.bottomPadding,
    // this.topBarColor = const Color(0xffffffff),
    this.topBarColor,
    // this.bgColorPanel = const Color(0xFF212121),
    this.bgColorPanel,
  });

  final bool show;
  final Widget? child;
  final Widget? bottomBar;
  final Widget? topBar;
  final double? sidePanelWidth;
  final AppDB? database;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? bottomPadding;
  final Color? topBarColor;
  final Color? bgColorPanel;


  @override
  Widget build(BuildContext context) {
    return show 
    ? Column(
      children: [
        topBar != null ? Container(
          color: topBarColor ?? Colors.grey,
          width: sidePanelWidth ?? double.infinity,
          child: topBar,
        ) : SizedBox(width: 0, height: 0),
        Expanded(
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.95,
            width: sidePanelWidth ?? double.infinity,
            // width: MediaQuery.of(context).size.width * 0.3,
            color: bgColorPanel ?? Colors.grey.shade900,
            padding: padding != null ? const EdgeInsets.all(10) : padding,
            child: child,
          ),
        ),
        bottomBar != null ? Container(
          // height: MediaQuery.of(context).size.height * 0.05,
          decoration: BoxDecoration(
            color: bgColorPanel ?? Colors.grey.shade900,
            border: Border(
              top: BorderSide(color: Colors.grey.shade500, width: 0.5),
            ),
          ),
          width: sidePanelWidth ?? double.infinity,
          padding: bottomPadding != null ?  EdgeInsets.fromLTRB(10, 0, 10, 0) : bottomPadding,
          child: bottomBar,
            
        ) : SizedBox(width: 0, height:0)
      ],
    )
    : const SizedBox(width: 0, height: 0);
  }
}

//MARK: Task Info
class TaskInfo extends StatefulWidget {
  const TaskInfo({
    super.key, 
    required this.task,
    this.subTask,
  });

  final Map task;
  final List? subTask;

  @override
  State<TaskInfo> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {

  Map get task => widget.task;

  List? get subTask => widget.subTask;

  bool get isChecked => task["is_done"] == 0 ? false : true;

  TextStyle subTaskTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.5), 
    fontSize: 15
  );

  bool inputNewSubTask = false;

  TitleField taskTitle = TitleField(
    textSize: 20,
    fontWeight: FontWeight.bold,
    completed: false,
    // inputValue: subTask ?? "Add step",
    onChange: (value) {
      //TODO: update database
    },
  );

  @override
  Widget build(BuildContext context) {

    //TODO: Need to send over subtasks aswell if there is any.
    
    // print("same: $task"); //! Seems to be printing twice for some reason. Look into it.
    print("subtask: $subTask");

    return SingleChildScrollView(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            //TODO:
                // subtasks
                // button for adding to 'My Day' list
                // reminder
                // Due date
                // repeat rule
                // notes
            ListTile(
              splashColor: Colors.transparent,
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
              // hoverColor: Colors.grey.shade800,
              leading: Checkbox(
                value: isChecked,
                //TODO: Change color of the checkbox, to white
                onChanged: (value){
                  setState(() {
                    //TODO: update database
                    // Maybe need to use stream here or something similar. Otherwise I need to call the database either way.
                    // isChecked = !isChecked;
                  });
                },
              ),
              title: TitleField(
                fontWeight: FontWeight.bold,
                completed: false,
                inputValue: task["title"] ?? "Failed to grap",
                onChange: (value) {
                  //TODO: update database
                },
              ),
            ),
            //TODO: is there any sub tasks > populate
            // db.subtask > 0 ? : 
            // !What is this? Is it to populate the subtask ui after?
            if (subTask == null) 
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(
                  splashColor: Colors.transparent,
                  tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                  // hoverColor: Colors.grey.shade800,
                  //TODO: Change color of the checkbox, to white
                  //! might not need this. maybe Do this in titleField.
                  leading: Checkbox(
                    value: isChecked,
                    onChanged: (value){
                      setState(() {
                        // isChecked = !isChecked;
                      });
                    },
                  ),
                  title: TitleField(
                    textSize: 20,
                    labelText: "Add step", //TODO: this should be subTask["title"]
                    completed: false, // TODO: needs to be "connected" with isChecked variable
                    inputValue: "subtest", //If no subtask >
                    onChange: (value) {
                      //TODO: update database and update listview.builder above - itemcount
                    },
                  ),
                );
              },
            ),
            ListTile(
              splashColor: Colors.transparent,
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
              leading: Icon(Icons.add, size: 25), //TODO: Change to a diffrent icon when inputting new task
              title: TitleField(
                textSize: 15,
                // inputValue: subTask["title"],
                labelText: "Add step",
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), 
                  fontSize: 15
                  ),
                onChange: (value) {
                  //TODO: add to database + update ui
                },
                // inputValue: subTask!.isEmpty ? "Add step" : "Next Step"
              ),
              // title: inputNewSubTask ? taskTitle :
              //   subTask!.isEmpty ? Text("Add step", style: subTaskTextStyle) : Text("Next Step", style: subTaskTextStyle,), //! Titlefield - take from above in listview
            ),
            SizedBox(height: 10),
            ListTile(
              title:Text("Add to My Day"),
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            ),
            SizedBox(height: 10),
            ListTile(
              title:Text("Remind Me"),
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            ),
            ListTile(
              title:Text("Due Date"),
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            ),
            ListTile(
              title:Text("Repeat"),
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            ),
            SizedBox(height: 10,),
            ListTile(
              title:Text("Notes"),
              tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            ),
          ]
        ),
      ),
    );
  }
}


// MARK: BottomBar
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