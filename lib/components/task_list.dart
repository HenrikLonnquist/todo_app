// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/title_field.dart';

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
      shrinkWrap: true,
      physics: widget.subTask ? const NeverScrollableScrollPhysics() : null,
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
              trailing: IconButton(
                icon: const Icon(
                  Icons.highlight_remove_rounded,
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

class SubTaskLIst extends StatefulWidget {
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
  State<SubTaskLIst> createState() => _SubTaskLIstState();
}

class _SubTaskLIstState extends State<SubTaskLIst> {

  final FocusNode _notesFocus = FocusNode();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.mainTask["notes"];
    _notesFocus.addListener(() {
      if(!_notesFocus.hasFocus){
        setState(() {
          widget.mainTask["notes"] = _notesController.text; 
          widget.onChanged!.call(widget.mainTask);
        });
      } 
    });
  }

  @override
  void dispose() {
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: TitleField(
              inputValue: widget.title,
              onChange: (value) {
                widget.mainTask["name"] = value;
                widget.onChanged!.call(widget.mainTask);
              },
            ),
          ),
          TaskList(
            dataList: widget.mainTask["sub_tasks"],
            subTask: true,
            onChanged: (listValue) {
              widget.onChanged!.call(listValue);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CardField(
              onSubmitted: (stringValue) {
                widget.onChanged!.call(stringValue);
              },
            )
          ),
          const Divider(thickness: 2,),
          //* due dates: date
          ElevatedButton(
            onPressed: () async {
              DateTime dataDate =  DateTime.parse(widget.mainTask["due_date"]);
              // TODO: might switch to calendar date picker 2 package later on.
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: dataDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)), 
                lastDate: DateTime.now().add(const Duration(days: 30)),
              ); 
                
              if (selectedDate != null && selectedDate != dataDate) {
                widget.mainTask["due_date"] = selectedDate.toString();
                widget.onChanged!.call(widget.mainTask);
              }
            }, 
            child: widget.mainTask["due_date"] != "" 
            ? Text(widget.mainTask["due_date"].toString().split(" ")[0]) 
            : const Text("Due Date"),
          ),
          // TODO: need a dialog to notify that it has been saved
          // TODO: need to keyboardlistener for escape and shift+enter to save text.
          Card(
            child: TextFormField(
              focusNode: _notesFocus,
              controller: _notesController,
              maxLines: null,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.only(left: 8),
                hintText: "Notes",
                border: InputBorder.none,
              ),
            ),
          ),
          //* TODO: reminder: time + date
          //* TODO: repeat: dates(days)
        ],
      ),
    );
  }
}