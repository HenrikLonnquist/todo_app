// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:todo_app/components/card_field.dart';

class TaskList extends StatefulWidget {
  const TaskList({
    super.key,
    required this.dataList,
    required this.subTask, 
    this.onChanged, 
    this.onTap,
  });
  
  final bool subTask;

  final Function(int)? onTap;
  
  final List dataList;

  final ValueChanged<List>? onChanged;

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
          final Map item = widget.dataList.removeAt(oldIndex);
          widget.dataList.insert(newIndex, item);

          // TODO: Need a better way to send data between components and files.
          // otherwise I need to send the whole "dataList" to every file that needs
          // to write to the file(data.json).
          // Look up skeleton flutter  create. I think it had what I wanted or at least
          // something similar to it.
          // maybe do a onchanged and send back the results of the list. Then i would not
          // write to json here but in home page.
          // DataUtils().writeJsonFile(widget.dataList);
          widget.onChanged!.call(widget.dataList);
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
              title: Text("${widget.dataList[index]["name"]}"),
              // TODO: below change back to: widget.subTask ? ... : null
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () {
                  // sub task list
                  widget.dataList.removeAt(index);
                  widget.onChanged!.call(widget.dataList);
                },
              ),
              onTap: widget.subTask ? null : () {
                widget.onTap!.call(index);
              },
            ),
          ),
        );
      })
    );
  }
}

class SubTaskLIst extends StatelessWidget {
  const SubTaskLIst({
    super.key,
    required this.title,
    required this.mainTask,
    required this.onChanged,
  });

  final Map mainTask;
  final ValueChanged? onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    print("subtasklist: $mainTask");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Title(
            color: Colors.black, 
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                // fontFamily: ,
              ),
            ),
          ),
        ),
        Expanded(
          child: TaskList(
            dataList: mainTask["sub_tasks"],
            subTask: true,
            onChanged: (listValue) {
              onChanged!.call(listValue);
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: CardField(
            onSubmitted: (stringValue) {
              onChanged!.call(stringValue);
            },
          )
        ),
        const Divider(thickness: 2,),
        //* due dates: date
        ElevatedButton(
          onPressed: () async {

            DateTime dataDate =  DateTime.parse(mainTask["due_date"]);
            // TODO: might switch to calendar date picker 2 package later on.
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: dataDate,
              firstDate: DateTime.now().subtract(const Duration(days: 365)), 
              lastDate: DateTime.now().add(const Duration(days: 30)),
               
              
            ); 

            if (selectedDate != null && selectedDate != dataDate) {
              mainTask["due_date"] = selectedDate.toString();
              onChanged!.call(mainTask);
            }

          }, 
          child: mainTask["due_date"] != "" 
          ? Text(mainTask["due_date"].toString().split(" ")[0]) 
          : const Text("Due Date"),
        )
        // Card(
        //   color: Colors.white,
        //   child: CalendarDatePicker(
        //     initialDate: DateTime.now(),
        //     firstDate: DateTime.now(), 
        //     lastDate: DateTime.now().add(const Duration(days: 30)),
        //     onDateChanged: (selectedDate) {
        //       print("testing");
        //     }
        //   ),
        // )
        //* TODO: reminder: time + date
        //* TODO: repeat: dates(days)
        //* TODO: notes: Textfield
      ],
    );
  }
}