// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/add_task_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/utils/data_utils.dart';

class MainTasksPage extends StatefulWidget {
  const MainTasksPage({
    super.key,
    required this.title,
    required this.dataList,
    this.onUserUpdate,
    this.userList = false,
  });

  final Function(Map?)? onUserUpdate;

  final String title;

  final bool? userList;

  final Map dataList;

  @override
  State<MainTasksPage> createState() => _MainTasksPageState();
}

class _MainTasksPageState extends State<MainTasksPage> {

  final TextEditingController _newTaskController = TextEditingController();
  
  String pageTitle = "";
  
  bool isRightPanelOpen = false;

  int mainTaskIndex = 0;

  String currentList = ""; // either completed or maintask list 

  late int prevTaskID = 0; // rename to prevOpenTaskID

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataList["user_list_name"] != null && widget.dataList["user_list_name"] != pageTitle) {
      pageTitle = widget.dataList["user_list_name"];
      isRightPanelOpen = false;
    } else {
      pageTitle = widget.title;
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            // duration: const Duration(seconds: 10),
            // curve: Curves.fastEaseInToSlowEaseOut,
            padding: const EdgeInsets.all(10),
            color: Colors.grey.shade700, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TitleField(
                    enabled: widget.userList!,
                    inputValue: pageTitle,
                    onChange: (value) {
                      widget.dataList["user_list_name"] = value;
                      widget.onUserUpdate!.call(widget.dataList);
                    },
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: TaskList(
                    dataList: widget.dataList["main_tasks"],
                    dataCompletedTasks: widget.dataList["completed"],
                    subTask: false,
                    onChanged: (value) {
                      setState(() {

                        //! FIX: TODO: need to handle in case of list reordering.
                        if (value.runtimeType == List) {
                          widget.onUserUpdate!.call(value);
                          return;
                        }

                        // print("$prevTaskID ${value["task_id"]} ${value["task_id"] == prevTaskID} $isRightPanelOpen");
                        if (prevTaskID == 0) {
                          prevTaskID = value["task_id"];
                        }


                        if (isRightPanelOpen && prevTaskID == value["task_id"]) {
                          if (value["checked"] == false){
                            print("testing1");
                            currentList = "main_tasks";
                            if (widget.dataList[currentList].isEmpty) {
                              mainTaskIndex = 0;

                            } else {
                              mainTaskIndex = int.parse(value["restore_index"]);

                            }
                          } else {
                            print("testing2");
                            currentList = "completed";
                            mainTaskIndex = 0;
                          }
                        } else if (isRightPanelOpen && prevTaskID != value["task_id"]){
                          print("testing3");
                          var newIndex = widget.dataList[currentList].indexWhere((object) => object["task_id"] == prevTaskID);

                          mainTaskIndex = newIndex;

                        }

                        //! BUG TODO: right side panel wont stay open on the correct task, but will switch to another or
                        //! give rangeError. 
                        // maybe use the taskid, save the prev task
                        // this gets called when the main task list gets update either by
                        // deletion, completed, undo complete, creation,
                        // nothing to do with side panel at the moment
                        //* need to change list depending on value state.
                        //* I need to know what task is in the right side panel from here.
                                                

                        widget.onUserUpdate!.call(value);
                        
                      });
                    },
                    onTap: (indexTask, taskList) {
                      print("hello");
                      setState(() {
                        if (isRightPanelOpen && taskList != currentList || mainTaskIndex != indexTask) {
                          mainTaskIndex = indexTask;
                          currentList = taskList;
                          prevTaskID = widget.dataList[currentList][mainTaskIndex]["task_id"];
                          return;
                        } else if (isRightPanelOpen == false || indexTask == mainTaskIndex){
                          isRightPanelOpen = !isRightPanelOpen;
                        }

                        currentList = taskList;
                        mainTaskIndex = indexTask;
                        prevTaskID = widget.dataList[currentList][mainTaskIndex]["task_id"];
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CardField(
                    onSubmitted: (value) {
                      
                      var newTask = DataUtils.newTaskTemplate(
                        name: value,
                        listID: widget.dataList["id"],
                        taskID: DateTime.now().millisecondsSinceEpoch
                      );
                      widget.dataList["main_tasks"].add(newTask);
                      
                      _newTaskController.text = "";
                      widget.onUserUpdate!.call(widget.dataList);

                    },
                  ),
                )
              ],
            ), 
          ),
        ),
        RightSidePanel(
          show: isRightPanelOpen,
          bottomChild: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.delete), 
                onPressed: (){
                  setState(() {
                    isRightPanelOpen = false;
                  });
                }, 
                label: const Text("hide")
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.hide_source),
                onPressed: (){
                  //TODO: how to call the database and remove shit
                  print(widget.dataList[currentList][mainTaskIndex]);
                  print(widget.dataList[currentList]);
                  //! Shit, my database is so messy and my code.
                  // widget.dataList.removeAt(index);
                  // widget.onChanged!.call(widget.dataList);
                }, 
                label: const Text("delete")
              ),
            ],
          ),
          child: widget.dataList[currentList] == null ? null : SubTaskList(
            title: widget.dataList[currentList][mainTaskIndex]["name"],
            mainTask: widget.dataList[currentList][mainTaskIndex],
            // title: widget.dataList[currentList].isNotEmpty 
            // ? widget.dataList[currentList][mainTaskIndex]["name"]
            // : prevTask[currentList][mainTaskIndex]["name"],
            // mainTask: widget.dataList[currentList].isNotEmpty
            // ? widget.dataList[currentList][mainTaskIndex]
            // : prevTask[currentList][mainTaskIndex],
            onChanged: (value) {
              setState(() {
                if (value.runtimeType == String) {
                  widget.dataList[currentList][mainTaskIndex]["sub_tasks"].add(DataUtils.subTaskTemplate(name: value));
                }

                widget.onUserUpdate!.call(value);
              });
              
            }, 
          ),
        ),
      ],
    );
  }
}
