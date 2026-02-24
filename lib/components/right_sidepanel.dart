// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/database.dart';

//MARK: Panel
class CustomPanel extends StatelessWidget {
  const CustomPanel({
    super.key,
    this.topBar,
    this.bottomBar,
    this.child, 
    this.sidePanelWidth = 360,
    this.padding,
    this.bottomPadding,
    // this.topBarColor = const Color(0xffffffff),
    this.topBarColor,
    // this.bgColorPanel = const Color(0xFF212121),
    this.bgColorPanel,
  });

  final Widget? child;
  final Widget? bottomBar;
  final Widget? topBar;
  final double? sidePanelWidth;
  
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? bottomPadding;
  final Color? topBarColor;
  final Color? bgColorPanel;


  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

//MARK: Task Info
class TaskInfo extends StatefulWidget {
  const TaskInfo({
    super.key, 
    required this.taskId,
    required this.showPanel,
  });

  final int taskId;
  final bool showPanel;
  
  @override
  State<TaskInfo> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {

  int get taskId => widget.taskId;

  bool isChecked = false;

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

    final db = context.read<AppDB>();

    return widget.showPanel ? StreamBuilder(
      stream: db.watchTaskByIdWithSubTasks(taskId),
      builder: (context, snapshot) {
    
        // print('Connection: ${snapshot.connectionState}');
        // print('Has data: ${snapshot.hasData}');
        // print('Data: ${snapshot.data}');
        // print('taskid: ${widget.taskId}');
    
        if (!snapshot.hasData) {
          // return CustomPanel(sidePanelWidth: 340, show: true, child: CircularProgressIndicator()); //! can use this for being empty and error
          //! Maybe return a snackbar or popup if there is an error or something or if it couldn't grap anything from db(empty).
          return SizedBox(width: 0, height: 0);
        }
          
        final task = snapshot.data!;
    
        final parentTask = task[0];
        
        final subTasks = snapshot.data!.where((t) => t.parentId == parentTask.id).toList();
    
        return CustomPanel(
          bottomBar: PanelBottomBar(
            taskDateLastModified: parentTask.updatedAt,
            deleteTask: () {},
            hidePanel: () {},
          ),
          child: SingleChildScrollView(
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
          
                  //MARK: MAIN TASK NAME
                  ListTile(
                    splashColor: Colors.transparent,
                    tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                    // hoverColor: Colors.grey.shade800,
                    leading: Checkbox(
                      value: parentTask.isDone,
                      //TODO: Change color of the checkbox, to white
                      onChanged: (isDone) {
                        // isChecked = value;
              
                        if (isDone != null) {
                          db.updateTask(
                            taskId, 
                            isDone: Value(isDone),
                          );
                        }
              
                        
                      },
                    ),
                    title: TitleField(
                      fontWeight: FontWeight.bold,
                      completed: parentTask.isDone!,
                      inputValue: parentTask.title,
                      onChange: (value) {
                        //TODO: update database
                        // Now would be a good use of a stream, no? instead of sending the database manually to here.
                        // task["title"] = value;
                        
                      },
                    ),
                  ),
                  //MARK: SUBTASK
                  if (subTasks.isNotEmpty)
                  //TODO: Make this into a separate class?
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: subTasks.length,
                    itemBuilder: (context, index) {
              
                      final subTask = subTasks[index];
              
                      return ListTile(
                        splashColor: Colors.transparent,
                        tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                        // hoverColor: Colors.grey.shade800,
                        //TODO: Change color of the checkbox, to white
                        //! might not need this. maybe Do this in titleField.
                        leading: Checkbox(
                          value: subTask.isDone,
                          onChanged: (isDone) async {
              
                            await db.updateTask(
                              subTask.id,
                              isDone: Value(isDone!),
                              parentID: parentTask.id //updating parent task - updated_at
                            );
                            
                          },
                        ),
                        title: TitleField(
                          textSize: 15,
                          completed: subTask.isDone!,
                          inputValue: subTask.title,
                          onChange: (title) async {
              
                            await db.updateTask(
                              subTask.id,
                              title: Value(title),
                              parentID: parentTask.id, //Updating parent task - updated_at
                            );
              
                          },
                        ),
                      );
                    },
                  ),
                  //! Show if there is no subtasks  
                  ListTile(
                    splashColor: Colors.transparent,
                    tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                    leading: Icon(Icons.add, size: 25), //TODO: Change to a diffrent icon when inputting new task
                    title: TitleField(
                      textSize: 15,
                      labelText: subTasks.isNotEmpty ? "Next step" : "Add step",
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5), 
                        fontSize: 15
                        ),
                      onChange: (subTitle) async {
                        
                        // Adding a new sub task to database
                        await db.insertTask(
                          parentID: parentTask.id,
                          listID: parentTask.listsId!,
                          title: subTitle,
                          position: 0,
                        );
                        
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
          ),
        );
      }
    ) : SizedBox(height: 0, width: 0,);
  }
}


// MARK: BottomBar
class PanelBottomBar extends StatelessWidget {

  const PanelBottomBar({
    super.key, 
    required this.hidePanel,
    required this.deleteTask,
    this.taskDateLastModified,
    
    });

  final VoidCallback? hidePanel;   
  final VoidCallback? deleteTask;   
  final DateTime? taskDateLastModified;

  //TODO: Maybe use this in 'Task Info' instead of 'Main Page'

  @override
  Widget build(BuildContext context) {
    final date = taskDateLastModified;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: hidePanel,
          child: const Icon(Icons.arrow_forward_ios), 
        ),
        Expanded(
          child: Center(
            child: Text(
              // "Created on Wed. 19 Jun 2025",
              "Created on "
              "${DateFormat("E").format(date!)}. "
              "${date.day} "
              "${DateFormat("MMM").format(date)} "
              "${date.year}",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
              )
            ),
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