// ignore_for_file: avoid_print

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
    this.onUserListUpdate,
  });

  final Function()? onUserListUpdate;

  final String title;

  final Map dataList;

  @override
  State<MainTasksPage> createState() => _MainTasksPageState();
}

class _MainTasksPageState extends State<MainTasksPage> {

  final TextEditingController _newTaskController = TextEditingController();
  
  bool isRightPanelOpen = false;

  int mainTaskIndex = 0;


  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Title(
                  color: Colors.black, 
                  child: Text(
                    widget.title,
                    style: const TextStyle(
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
                      if(widget.onUserListUpdate != null) {
                        widget.onUserListUpdate!.call();
                        return;
                      }
                      DataUtils.writeJsonFile(widget.dataList);
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
              setState(() {
                DataUtils.writeJsonFile(widget.dataList);
              });
            }, 
          ),
        ),              
      ],
    );
  }
}
