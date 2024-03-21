// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/utils/data_utils.dart';

class MainContent extends StatefulWidget {
  const MainContent({
    super.key,
    required this.title,
    required this.dataList,
  });

  final String title;

  final Map dataList;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {

  final TextEditingController _newTaskController = TextEditingController();
  
  bool isSubPanelOpen = false;

  late int mainTaskIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          // duration: const Duration(seconds: 10),
          // curve: Curves.fastEaseInToSlowEaseOut,
          width: isSubPanelOpen ? 
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
                      DataUtils().writeJsonFile(widget.dataList);
                    });
                  },
                  onTap: (indexTask) {
                    setState(() {
                      if (isSubPanelOpen && mainTaskIndex != indexTask) {
                        mainTaskIndex = indexTask;
                        return;
                      } 
                      isSubPanelOpen = !isSubPanelOpen;
                      mainTaskIndex = indexTask;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: CardField(
                  onSubmitted: (value) {
                    // model
                    Map template = {
                      "name": value,
                      // "id": int //time?
                      "sub_tasks": [],
                      "notes": ""
                    };
                    widget.dataList["main_tasks"].add(template);
                    
                    setState(() {
                      _newTaskController.text = "";
                      DataUtils().writeJsonFile(widget.dataList);
                    });
                  },
                ),
              )
            ],
          ), 
        ),
        // how do I know which one it is? What index..
        // change the 0 to a variable?
        // setstate > 
        if (isSubPanelOpen) RightSidePanel(
          child: SubTaskLIst(
            mainTaskSubList: widget.dataList["main_tasks"][mainTaskIndex]["sub_tasks"],
            onChanged: (value) {
              if (value.runtimeType == String) {
                Map templateSub = {
                  "name": value
                };
                widget.dataList["main_tasks"][mainTaskIndex]["sub_tasks"].add(templateSub);
              }
              // setState(() {
              //   DataUtils().writeJsonFile(dataList);
              // });
            }, 
          ),
        ),              
      ],
    );
  }
}
