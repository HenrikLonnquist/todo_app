// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/utils/data_utils.dart';

class TaskList extends StatefulWidget {
  const TaskList({
    super.key,
    required this.dataList, 
  });
  
  final Map dataList;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      onReorder: ((oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final Map item = widget.dataList["main_tasks"].removeAt(oldIndex);
          widget.dataList["main_tasks"].insert(newIndex, item);

          // TODO: Need a better to send data between components and files.
          // otherwise I need to send the whole "dataList" to every file that needs
          // to write to the file(data.json).
          // Look up skeleton flutter  create. I think it had what I wanted or at least
          // something similar to it.
          DataUtils().writeJsonFile(widget.dataList);
        });
      }),
      itemCount: widget.dataList.length,
      itemBuilder: ((context, index) {
        return Card(
          key: Key("$index"),
          child: ReorderableDragStartListener(
            index: index,
            child: ListTile(
              // leading:
              title: Text("${widget.dataList["main_tasks"][index].keys}"),
              // trailing: ,
              onTap: () {
                
              },
            ),
          ),
        );
      })
    );
  }
}
