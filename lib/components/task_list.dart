// ignore_for_file: avoid_print
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/card_field.dart';
import 'package:todo_app/components/title_field.dart';

class TaskList extends StatefulWidget {
  const TaskList({
    super.key,
    required this.dataList,
    this.dataCompletedTasks = const [],
    required this.subTask, 
    this.onChanged, 
    this.onTap,
  });
  
  final bool subTask;

  final List dataCompletedTasks;

  final Function(int)? onTap;
  
  final List dataList;

  final ValueChanged? onChanged;

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  bool showCompleted = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
              // todo: add left click options for windows or long press for android
              return ReorderableDragStartListener(
                key: ObjectKey(widget.dataList[index]),
                index: index,
                child: Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: false,
                      onChanged: (value) {
                        widget.dataList[index]["checked"] = true;
                        if (!widget.subTask) {
                          widget.dataCompletedTasks.insert(0, widget.dataList[index]);
                          widget.dataCompletedTasks[0]["restore_index"] = "$index";

                          var item = widget.dataList.removeAt(index);
                          widget.onChanged!.call(item);

                        } else {
                          widget.onChanged!.call(widget.dataList);

                        }
                      },
                    ),
                    title: Text(
                      "${widget.dataList[index]["name"]}",
                    ),
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
          ),
          if (showCompleted && !widget.subTask && widget.dataCompletedTasks.isNotEmpty) ... [
            const Divider(thickness: 1,),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // show list of completed tasks
                  showCompleted = !showCompleted;
                });
              }, 
              label: Text("Completed   ${widget.dataCompletedTasks.length}"),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            //MARK: COMPLETED
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.dataCompletedTasks.length,
              itemBuilder: ((context, index) {
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: true,
                      onChanged: (value) {
                        widget.dataCompletedTasks[index]["checked"] = false;
                        var restoreIndex = int.parse(widget.dataCompletedTasks[index]["restore_index"]);
                        try {
                          widget.dataList.insert(restoreIndex, widget.dataCompletedTasks[index]);
                          
                        } catch (e) {
                          widget.dataList.add(widget.dataCompletedTasks[index]);
                        }
                        widget.dataCompletedTasks[index]["restore_index"] = "";
                        var item = widget.dataCompletedTasks.removeAt(index);

                        widget.onChanged!.call(item);
                      },
                    ),
                    title: Text(
                      "${widget.dataCompletedTasks[index]["name"]}",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.highlight_remove_rounded,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        widget.dataCompletedTasks.removeAt(index);
                        widget.onChanged!.call(widget.dataCompletedTasks);
                      },
                    ),
                    onTap: widget.subTask ? null : () {
                      widget.onTap!.call(index);
                    },
                  ),
                );
              })
            ),
          ],
        ],
      ),
    );
  }
}

class SubTaskList extends StatefulWidget {
  const SubTaskList({
    super.key,
    required this.title,
    required this.mainTask,
    required this.onChanged,
  });

  final Map mainTask;
  final ValueChanged? onChanged;
  final String title;

  @override
  State<SubTaskList> createState() => _SubTaskListState();
}

class _SubTaskListState extends State<SubTaskList> {

  final FocusNode _notesFocus = FocusNode();
  final TextEditingController _notesController = TextEditingController();
  
  final List items = [
    "Daily",
    "Weekly",
    "Monthly",
    "Custom",
  ];
  
  Object? selectedDropItem;

  @override
  void initState() {
    super.initState();
    selectedDropItem = widget.mainTask["repeat"].isEmpty ? null : widget.mainTask["repeat"];
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
    _notesController.dispose();
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
          //MARK: REMINDER
          //* maybe should have used a dropdownbutton for duedate instead or 
          //* or the existing on due date as an option in the dropdownbutton.
          ElevatedButton.icon(
            onPressed: () async {

              var reminder = widget.mainTask["reminder"];
              try {
                reminder = DateTime.parse(reminder);
              } catch (e) {
              // ignore: empty_catches
              }

              DateTime? tabDateTimePicker = await showDialog(
                barrierColor: Colors.transparent,
                context: context, 
                builder: (context) {
                  return ReminderDialog(
                    reminder: reminder,
                  );
                }
              );

              if (tabDateTimePicker != null && tabDateTimePicker != widget.mainTask["reminder"]) {
                widget.mainTask["reminder"] = tabDateTimePicker.toString();
                widget.onChanged!.call(widget.mainTask);
              }
            },
            icon: const Icon(Icons.timer), 
            label: widget.mainTask["reminder"].isEmpty 
            ? const Text("Remind me") 
            : Text(widget.mainTask["reminder"]),
          ),
    
          //MARK: DUE DATE
          ElevatedButton(
            onPressed: () async {
              DateTime dataDate = widget.mainTask["due_date"].isEmpty ? DateTime.now() : DateTime.parse(widget.mainTask["due_date"]);
              // TODO: might switch to calendar date picker 2 package later on.
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: dataDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)), 
                lastDate: DateTime.now().add(const Duration(days: 365)),
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
          const SizedBox(height: 1,),

          // TODO: make this into a class.
          //MARK: Repeat task
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: DropdownButton2(
                  isExpanded: true,
                  underline: const SizedBox(height: 0,),
                  hint: selectedDropItem != null ? null : const Text("Repeat task"),
                  value: selectedDropItem,
                  items: items.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {

                    // TODO: make task repeatable
                    /**
                     * dropdownmenu on "custom", look in app_blocker project
                     *  - n days
                     *  - n weeks
                     *  - n months
                     * Daily, Weekly, Monthly
                     * how does monthly work on 31? <- this will just be last date of the month
                     * removing due date, will also remove repeat value, but not vice versa
                     * 
                     */

                    // no need for switch case statement here,
                    // only need to do the calculation when the task is completed.
                    widget.mainTask["repeating_tasks"] = value;
                        

                    setState(() {
                      selectedDropItem = value;
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                    )
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDropItem = null;
                  });
                }, 
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(8),
                    )
                  )
                ),
                child: const Icon(Icons.highlight_remove_sharp),
              ),
            ],
          ),
          //MARK: NOTES
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
        ],
      ),
    );
  }
}

class ReminderDialog extends StatefulWidget {
  const ReminderDialog({
    super.key,
    required this.reminder,
  });

  final dynamic reminder;

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  DateTime now = DateTime.now();
  late DateTime currentDate = widget.reminder.toString().isEmpty ? now : widget.reminder;
  DateTime? selectedDate;
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  
  @override
  void initState() {
    hourController.text = widget.reminder.toString().isEmpty ? now.hour.toString() : widget.reminder.hour.toString();
    minuteController.text = widget.reminder.toString().isEmpty ? now.minute.toString().padLeft(2, "0") : widget.reminder.minute.toString();
    super.initState();
  }

  @override
  void dispose(){
    hourController.dispose();
    minuteController.dispose();
    super.dispose();
  }

  bool isFormValid = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 320,
        width: 250,
        color: Colors.orangeAccent,
        child: DefaultTabController(
          initialIndex: 1,
          length: 2,
          child:  Form(
            key: formKey,
            child: Column(
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
                                    controller: hourController,
                                    autofocus: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        )
                                      ),
                                    ),
                                    autovalidateMode: AutovalidateMode.always,
                                    validator: (value) {
                                      try {
                                        int hour = int.parse(value!);
                                        if (hour > 24) {
                                          return "";
                                        }
                                        return null;
                                        
                                      } catch (e) {
                                        return "";
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        isFormValid = formKey.currentState!.validate();
                                      });
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
                                    controller: minuteController,
                                    autofocus: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
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
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        )
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        )
                                      ),
                                    ),
                                    autovalidateMode: AutovalidateMode.always,
                                    validator: (value) {
                                      try {
                                        int minute = int.parse(value!);
                                        if (minute > 59) {
                                          return "";
                                        }
                                        return null;
                                      } catch (e) {
                                        return "";
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        isFormValid = formKey.currentState!.validate();
                                      });
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
                    //* TODO: Tho I still want to be able to null the onpressed property
                    //* when the input is empty.
                    ElevatedButton(
                      onPressed: isFormValid ? () {
                        // validate check before submitting/updating database
                        if (!formKey.currentState!.validate()) {
                          // maybe an snackbar something like that to notify the user.
                          return ;
                        }
                        try {
                          int selectedHour = int.parse(hourController.text);
                          int selectedMinute = int.parse(minuteController.text);
            
                          selectedDate = DateTime(currentDate.year, currentDate.month, currentDate.day, selectedHour, selectedMinute);
                          Navigator.pop(context, selectedDate);
                        } catch (e) {
                          Navigator.pop(context, null);
                        }
                      } : null, 
                      child: const Text("Save")
                    ),
                    
                  ]
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}