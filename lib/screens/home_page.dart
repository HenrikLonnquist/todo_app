// ignore_for_file: avoid_print

// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/subtask_panel.dart';
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
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            color: Colors.purple, 
            // child: const Text('test')
          ),
          Stack(
            children: [
              // // how do I know which one it is? What index..
              // // change the 0 to a variable?
              // // setstate > 
              SubTaskPanel(
                mainTaskSubList: dataList["main_tasks"][0]["sub_tasks"],
                onChanged: (value) {
              
                  print(value.runtimeType);
              
                  // Map templateSub = {
                  //   "name": value
                  // };
                  // setState(() {
                  //   dataList["main_tasks"][0]["sub_tasks"].add(templateSub);
                  //   DataUtils().writeJsonFile(dataList);
                  // });
                },
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
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
            ],
          ),
          
        ],
      ),
    );
  }
}
