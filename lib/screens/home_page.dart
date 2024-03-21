// ignore_for_file: avoid_print

// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/navigation_panel.dart';
import 'package:todo_app/components/subtask_panel.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/utils/data_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {

  Map dataList = {};
  
  final TextEditingController _newTaskController = TextEditingController();
  
  bool isSubPanelOpen = false;

  late int mainTaskIndex;


  @override
  void initState() {
    super.initState();
    dataList = DataUtils().readJsonFile();

  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.purple,
            child: const NavigationPanel(),
          ),
          Row(
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
                    Expanded(
                      child: TaskList(
                        dataList: dataList["main_tasks"],
                        subTask: false,
                        onChanged: (value) {
                          setState(() {
                            DataUtils().writeJsonFile(dataList);
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
                          dataList["main_tasks"].add(template);
                          
                          setState(() {
                            _newTaskController.text = "";
                            DataUtils().writeJsonFile(dataList);
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
              if (isSubPanelOpen) SubTaskPanel(
                mainTaskSubList: dataList["main_tasks"][mainTaskIndex]["sub_tasks"],
                onChanged: (value) {
                  if (value.runtimeType == String) {
                    Map templateSub = {
                      "name": value
                    };
                    dataList["main_tasks"][mainTaskIndex]["sub_tasks"].add(templateSub);
                  }
                  setState(() {
                    DataUtils().writeJsonFile(dataList);
                  });
                },
              ),              
            ],
          ),
          
        ],
      ),
    );
  }
}
