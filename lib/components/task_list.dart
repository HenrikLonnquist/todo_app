// ignore_for_file: avoid_print
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/screens/schedule.dart';

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
          //MARK: DUE DATE
          //* maybe should have used a dropdownbutton for duedate instead or 
          //* or the existing on due date as an option in the dropdownbutton.
          ElevatedButton.icon(
            onPressed: () async {

              DateTime now = DateTime.now();
              DateTime currentDate = now;
              DateTime? selectedDate;
              int selectedHour = now.hour;
              int selectedMinute = now.minute;

              // probably have to have a focusnode or focus listener to validate when
              // losing focus and such.. Can use it to validate as well, for when I press
              // enter which will cause it lose focus. Error inputdecorator doesn't seem to work.
              // I have to use globalkey for keys and maybe an form. Maybe can do without form widget.

              DateTime? tabDateTimePicker = await showDialog(
                barrierColor: Colors.transparent,
                context: context, 
                builder: (context) {
                  return Center(
                    child: Container(
                      height: 320,
                      width: 250,
                      color: Colors.orangeAccent,
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          return DefaultTabController(
                            initialIndex: 1,
                            length: 2,
                            child:  Column(
                              children: [
                                const Card(
                                  child: TabBar(
                                    tabs: [
                                      Tab(
                                        child: Text("Date"),
                                      ),
                                      Tab(
                                        child: Text("Time"),
                                      )
                                    ]
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      Column(
                                        children: [
                                          //* Optional
                                          Column(
                                            children: [
                                              Text(DateFormat("E d MMM y").format(currentDate)),
                                              Row(
                                                children: [
                                      
                                                  TextButton(
                                                    onPressed: () {
                                                      setState((){
                                                        now = DateTime(now.year, now.month - 1, 1);
                                                      });
                                                    }, 
                                                    child: const Icon(
                                                      Icons.arrow_back_ios,
                                                      size: 20,
                                                    ),
                                                  ),  
                                                  const Spacer(),
                                                  Text("${DateFormat("MMMM").format(now)} ${DateFormat("y").format(now)}"),
                                                  const Spacer(),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState((){
                                                        now = DateTime(now.year, now.month + 1, 1);
                                                      });
                                                    }, 
                                                    child: const Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 7,
                                            ), 
                                            itemCount: DateTime(now.year, now.month + 1, 0).day,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                color: now.month == currentDate.month && (index + 1) == currentDate.day ? Colors.tealAccent : null,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      currentDate = DateTime(now.year, now.month, (index + 1));
                                                    });
                                                  },
                                                  child: Center(child: Text("${index + 1}"))
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text("Enter time"),
                                          Row(
                                            children: [
                                              Card(
                                                child: SizedBox(
                                                  width: 70,
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(2),
                                                    ],
                                                    initialValue: selectedHour.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    decoration: InputDecoration(
                                                      errorStyle: const TextStyle(
                                                        height: 0,
                                                      ),
                                                      contentPadding: const EdgeInsets.all(16),
                                                      focusedErrorBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(
                                                          color: Colors.red,
                                                          width: 2,
                                                        )
                                                      ),
                                                    ),
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    validator: (value) {
                                                      try {
                                                        int hour = int.parse(value!);
                                                        if (hour > 24) {
                                                          return "";
                                                        }
                                                        return null;
                                                        
                                                      } catch (e) {
                                                        return null;
                                                      }
                                                    },
                                                    onFieldSubmitted: (value) {
                                                      selectedHour = int.parse(value);
                                                    },
                                                    
                                                  ),
                                                ),
                                              ),
                                              const Text(
                                                "  :  ",
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500,
                                                )
                                              ),
                                              Card(
                                                child: SizedBox(
                                                  width: 70,
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(2),
                                                    ],
                                                    initialValue: selectedMinute.toString().padLeft(2, "0"),
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    decoration: InputDecoration(
                                                      errorStyle: const TextStyle(
                                                        height: 0,
                                                      ),
                                                      contentPadding: const EdgeInsets.all(16),
                                                      focusedErrorBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                        borderSide: const BorderSide(
                                                          color: Colors.red,
                                                          width: 2,
                                                        )
                                                      ),
                                                    ),
                                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                                    validator: (value) {
                                                      try {
                                                        int minute = int.parse(value!);
                                                        if (minute > 24) {
                                                          return "";
                                                        }
                                                        return null;
                                                        
                                                      } catch (e) {
                                                        return null;
                                                      }
                                                    },
                                                    onFieldSubmitted: (value) {
                                                      selectedMinute = int.parse(value);
                                                    },
                                                    
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Row(
                                            children: [
                                              Text("Hour"),
                                              Text("Minute"),
                                            ],
                                          )
                                        ]
                                      ),
                                    ]
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      }, 
                                      child: const Text("Cancel")
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        selectedDate = DateTime(currentDate.year, currentDate.month, currentDate.day, selectedHour, selectedMinute);
                                        Navigator.pop(context, selectedDate);
                                      }, 
                                      child: const Text("Save")
                                    ),
                                    
                                  ]
                                )
                              ],
                            ),
                          );
                        }
                      ),
                    )
                  );
                }
              );

              print(tabDateTimePicker);

              // DateTime? selectedTime = await showDatePicker(
              //   context: context,
              //   initialDate: widget.mainTask["reminder"] != "" 
              //   ? DateTime.now()
              //   : widget.mainTask["reminder"].split(" ")[1],
              //   firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)), 
              //   lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
              // ); 
              // if (selectedTime != null && selectedTime != widget.mainTask["reminder"]) {
              //   widget.mainTask["reminder"] = selectedTime;
              //   // widget.onChanged!.call(widget.mainTask);
              // }
            },
            icon: const Icon(Icons.timer), 
            label: const Text("Remind me")
          ),
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
          //MARK: repeat feature
          //* maybe switch to a dropdownbutton or 
          //* take the dropdownbutton i made in app_blocker project
          ElevatedButton(
            onPressed: () {
            }, 
            child: const Text("Repeat task"),
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
          //* TODO: repeat: dates(daily, weekly, monthly?)
        ],
      ),
    );
  }
}