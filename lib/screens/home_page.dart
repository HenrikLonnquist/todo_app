// ignore_for_file: avoid_print

// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/utils/data_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Map dataList = {};
  
  final TextEditingController _newTaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dataList = DataUtils().readJsonFile();

  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child:Container(
              color: Colors.purple, 
              // child: const Text('test')
            )
          ),
          Expanded(
            flex: 5,
            child:Container(
              padding: const EdgeInsets.all(10),
              color: Colors.blue, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 9,
                    child: TaskList(dataList: dataList),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Card(
                        color: Colors.white,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Add new task",
                                border: InputBorder.none,
                              ),
                              controller: _newTaskController,
                              onSubmitted: (value) {
                                
                                // model
                                Map template = {
                                  value: {
                                    "sub_tasks": [],
                                    "notes": ""
                                  }
                                };
                                dataList["main_tasks"].add(template);
                                
                                setState(() {
                                  _newTaskController.text = "";
                                  DataUtils().writeJsonFile(dataList);
                                });
                              },
                            )
                          )
                        )
                      ),
                    ),
                  )
                ],
              ), 
            ),
          ),
          // This or "dataList" should be the mainTask(type map) that was
          // pressed or tapped on and trigger the sidepanel.
          SidePanel(mainTaskSubList: dataList),
        ],
      ),
    );
  }
}

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.mainTaskSubList,
  });

  final Map mainTaskSubList;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        color: Colors.blueAccent,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TaskList(
                dataList: mainTaskSubList,
              ),
            ),
            const Divider(thickness: 2,),
            // due dates
            // reminder
            // repeat
            // Textfield
          ],
        ),
      ) 
    );
  }
}
