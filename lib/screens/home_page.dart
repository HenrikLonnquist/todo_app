// ignore_for_file: avoid_print

// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:todo_app/components/card_field.dart';
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
                    child: TaskList(
                      onChanged: (value) {
                        setState(() {
                          DataUtils().writeJsonFile(dataList);
                        });
                      },
                      dataList: dataList["main_tasks"],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
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
                    ),
                  )
                ],
              ), 
            ),
          ),
          // how do I know which one it is? What index..
          // change the 0 to a variable?
          // setstate > 
          SidePanel(
            mainTaskSubList: dataList["main_tasks"][0]["sub_tasks"],
            onChanged: (value) {
              Map templateSub = {
                "name": value
              };
              setState(() {
                dataList["main_tasks"][0]["sub_tasks"].add(templateSub);
                DataUtils().writeJsonFile(dataList);
              });
            },
          ),
        ],
      ),
    );
  }
}

class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.mainTaskSubList, 
    this.onChanged,
  });

  final List mainTaskSubList;
  final ValueChanged? onChanged;

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
            // TODO: able to add a new sub task to the list
            Align(
              alignment: Alignment.bottomCenter,
              child: CardField(
                onSubmitted: (value) {
                  // TODO: how do I clear the texteditingcontroller from here?
                  onChanged!.call(value);
                },
              )
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
