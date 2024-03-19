import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_app/utils/data_utils.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Map data = {};

  @override
  void initState() {
    super.initState();
    data = readJsonFile();

  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
              flex: 8,
              child:Container(
                padding: const EdgeInsets.all(10),
                color: Colors.blue, 
                child: ReorderableListView.builder(
                  onReorder: ((oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final int item = data["list"].removeAt(oldIndex);
                      data["list"].insert(newIndex, item);
                    });
                  }),
                  itemCount: 3,
                  itemBuilder: ((context, index) {
                    return Card(
                      child: ListTile(
                        // leading:
                        title: const Text('test'),
                        // trailing: ,
                        onTap: () {},
                      ),
                    );
                  })
                ), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
