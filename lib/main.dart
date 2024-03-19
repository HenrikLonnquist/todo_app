import 'package:flutter/material.dart';
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

  Map dataList = {};

  @override
  void initState() {
    super.initState();
    dataList = DataUtils().readJsonFile();

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
                  buildDefaultDragHandles: false,
                  onReorder: ((oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final String item = dataList["list"].removeAt(oldIndex);
                      dataList["list"].insert(newIndex, item);

                      DataUtils().writeJsonFile(dataList);
                    });
                  }),
                  itemCount: dataList["list"].length,
                  itemBuilder: ((context, index) {
                    return Card(
                      key: Key("$index"),
                      child: ReorderableDragStartListener(
                        index: index,
                        child: ListTile(
                          // leading:
                          title: Text("${dataList["list"][index]}"),
                          // trailing: ,
                          onTap: () {},
                        ),
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
