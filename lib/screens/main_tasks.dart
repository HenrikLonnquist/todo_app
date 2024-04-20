// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
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

  late Map prevTask = widget.dataList;



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
            color: Colors.blue, 
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
                        if (widget.dataList["main_tasks"] == null || widget.dataList["main_tasks"].isEmpty) {
                          isRightPanelOpen = false;
                        } 

                        widget.onUserUpdate!.call(value);
                        
                      });
                    },
                    onTap: (indexTask) {
                      setState(() {
                        if (isRightPanelOpen && mainTaskIndex != indexTask) {
                          mainTaskIndex = indexTask;
                          return;
                        } 
                        isRightPanelOpen = !isRightPanelOpen;
                        mainTaskIndex = indexTask;
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
        if(prevTask["main_tasks"].isNotEmpty || widget.dataList["main_tasks"].isNotEmpty)
        RightSidePanel(
          show: isRightPanelOpen,
          child: SubTaskList(
            title: widget.dataList["main_tasks"].isNotEmpty 
            ? widget.dataList["main_tasks"][mainTaskIndex]["name"]
            : prevTask["main_tasks"][mainTaskIndex]["name"],
            mainTask: widget.dataList["main_tasks"].isNotEmpty
            ? widget.dataList["main_tasks"][mainTaskIndex]
            : prevTask["main_tasks"][mainTaskIndex],
            onChanged: (value) {
              setState(() {
                if (value.runtimeType == String) {
                  widget.dataList["main_tasks"][mainTaskIndex]["sub_tasks"].add(DataUtils.subTaskTemplate(name: value));
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
