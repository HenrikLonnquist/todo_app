// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/utils/data_utils.dart';

class MainTasksPage extends StatefulWidget {
  const MainTasksPage({
    super.key,
    required this.title,
    required this.dataList,
    this.onUserUpdate,
    this.userList = false,
  });

  final Function()? onUserUpdate;

  final String title;

  final bool? userList;

  final Map dataList;

  @override
  State<MainTasksPage> createState() => _MainTasksPageState();
}

class _MainTasksPageState extends State<MainTasksPage> {

  final TextEditingController _newTaskController = TextEditingController();
  
  final TextEditingController _titleController  = TextEditingController();

  late String pageTitle = widget.title;
  
  bool isRightPanelOpen = false;

  int mainTaskIndex = 0;

  @override
  void initState() {
    _titleController.text = widget.title;
    super.initState();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataList["user_list_name"] != null) {
      _titleController.text = widget.dataList["user_list_name"];
    } else {
      _titleController.text = widget.title;
    }

    return Row(
      children: [
        Container(
          // duration: const Duration(seconds: 10),
          // curve: Curves.fastEaseInToSlowEaseOut,
          width: isRightPanelOpen ? 
          MediaQuery.of(context).size.width * 0.5 :
          MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(10),
          color: Colors.blue, 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IntrinsicWidth(
                  child: TextField(
                    enabled: widget.userList! ? true : false,
                    controller: _titleController,
                    onSubmitted: (value) {
                      setState(() {
                        // TODO: title wont change
                        _titleController.text = value;
                        print(_titleController.text);
                        widget.dataList["user_list_name"] = value;
                        widget.onUserUpdate!.call();
                      });
                    },
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      // fontFamily: ,                    
                    ),
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 8.0),
              //   child: Title(
              //     color: Colors.black, 
              //     child: Text(
              //       widget.title,
              //       style: const TextStyle(
              //         fontSize: 26,
              //         fontWeight: FontWeight.bold,
              //         // fontFamily: ,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TaskList(
                  dataList: widget.dataList["main_tasks"],
                  subTask: false,
                  onChanged: (value) {
                    setState(() {
                      if (widget.dataList["main_tasks"].isEmpty) {
                        isRightPanelOpen = false;
                      }
                      DataUtils.writeJsonFile(widget.dataList);
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
                    
                    var template = DataUtils.dataTemplate(
                      name: value,
                    );
                    widget.dataList["main_tasks"].add(template);
                    
                    setState(() {
                      _newTaskController.text = "";
                      if(widget.onUserUpdate != null) {
                        widget.onUserUpdate!.call();
                        return;
                      }
                      print("${widget.dataList}");
                      // DataUtils.writeJsonFile(widget.dataList);
                    });
                  },
                ),
              )
            ],
          ), 
        ),
        if (widget.dataList["main_tasks"].isNotEmpty) RightSidePanel(
          show: isRightPanelOpen,
          child: SubTaskLIst(
            title: widget.dataList["main_tasks"][mainTaskIndex]["name"],
            mainTask: widget.dataList["main_tasks"][mainTaskIndex],
            onChanged: (value) {
              if (value.runtimeType == String) {
                Map templateSub = {
                  "name": value
                };
                widget.dataList["main_tasks"][mainTaskIndex]["sub_tasks"].add(templateSub);
              }
              //! BUG: When changing a tasks due date it will remove that task from todays list
              //! and show another task. Which is not what I want, I want the same task(that i switched date on)
              //! to stay in rightpanel while the todays list updates and removes the task.
              widget.onUserUpdate!.call();
              print(widget.dataList);
            }, 
          ),
        ),              
      ],
    );
  }
}
