// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/nav_controller.dart';

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
class TaskInfo extends StatelessWidget {
  TaskInfo({
    super.key,
  });

  final bool isChecked = false;

  final TextStyle subTaskTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.5), 
    fontSize: 15
  );

  final bool inputNewSubTask = false;

  final TitleField taskTitle = TitleField(
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
    final taskID = context.watch<NavController>().currentTaskID;
    final isPanelOpen = context.watch<NavController>().showTaskPanel;


    return StreamBuilder(
      stream: db.watchTaskByIdWithSubTasks(taskID),
      builder: (context, snapshot) {

        if (!snapshot.hasData) return SizedBox.shrink();

        if (snapshot.data!.isEmpty) return SizedBox.shrink();

        if (snapshot.hasError) {
          return CustomPanel(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      //TODO: refresh streambuilder. class?
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          );
        }


        final task = snapshot.data;
    
        final parentTask = task![0];
        
        final subTasks = snapshot.data!.where((t) => t.parentId == parentTask.id).toList();
    
        return Visibility(
          visible: isPanelOpen,
          maintainState: true,
          maintainAnimation: true,
          child: CustomPanel(
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
                        //// subtasks
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
                        onChanged: (isDone) async {
                          
                          //! Why would it be null? Is this check even needed? There are only two states it
                          //! can have, no?
                          if (isDone != null) {
                            await db.updateTask(
                              taskID, 
                              isDone: Value(isDone),
                            );
                          }
                
                          
                        },
                      ),
                      title: TitleField(
                        fontWeight: FontWeight.bold,
                        completed: parentTask.isDone!,
                        inputValue: parentTask.title,
                        onChange: (newTitle) async {

                          await db.updateTask(
                            parentTask.id,
                            title: Value(newTitle),
                          );
                          
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
                                parentID: parentTask.id, //Updating parent task - updated_at "TIME"
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
          ),
        );
      }
    );
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // Close panel
            ElevatedButton(
              onPressed: () {

                context.read<NavController>().toggleRightPanel();

              },
              child: const Icon(Icons.arrow_forward_ios)
            ),
            
            // Delete Task and close panel
            ElevatedButton(
              onPressed: () async {
                
                final db = context.read<AppDB>();
                final taskID = context.read<NavController>().currentTaskID;

                context.read<NavController>().toggleRightPanel();

                await (db.delete(db.tasks)..where((t) => t.id.equals(taskID))).go().then((value){
                  

                });
                
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              ),
              child: const Text(
                "Delete Task"
              ),
            ),
        
          ],
        ),
        Center(
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
      ],
    );
  }
}