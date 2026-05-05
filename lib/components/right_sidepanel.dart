// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:todo_app/components/task_list.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/nav_controller.dart';

//MARK: Panel
class CustomPanel extends StatelessWidget {
  const CustomPanel({
    super.key,
    this.topBar,
    this.bottomBar,
    this.child, 
    this.sidePanelWidth = 360,
    this.padding,
    this.bottomPadding,
    // this.topBarColor = const Color(0xffffffff),
    this.topBarColor,
    // this.bgColorPanel = const Color(0xFF212121),
    this.bgColorPanel,
  });

  final Widget? child;
  final Widget? bottomBar;
  final Widget? topBar;
  final double? sidePanelWidth;
  
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? bottomPadding;
  final Color? topBarColor;
  final Color? bgColorPanel;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        topBar != null ? Container(
          color: topBarColor ?? Colors.grey,
          width: sidePanelWidth ?? double.infinity,
          child: topBar,
        ) : SizedBox(width: 0, height: 0),
        Expanded(
          child: Container(
            // height: MediaQuery.of(context).size.height * 0.95,
            width: sidePanelWidth ?? double.infinity,
            // width: MediaQuery.of(context).size.width * 0.3,
            color: bgColorPanel ?? Colors.grey.shade900,
            padding: padding != null ? const EdgeInsets.all(10) : padding,
            child: child,
          ),
        ),
        bottomBar != null ? Container(
          // height: MediaQuery.of(context).size.height * 0.05,
          decoration: BoxDecoration(
            color: bgColorPanel ?? Colors.grey.shade900,
            border: Border(
              top: BorderSide(color: Colors.grey.shade500, width: 0.5),
            ),
          ),
          width: sidePanelWidth ?? double.infinity,
          padding: bottomPadding != null ?  EdgeInsets.fromLTRB(10, 0, 10, 0) : bottomPadding,
          child: bottomBar,
        ) : SizedBox(width: 0, height:0)
      ],
    );
  }
}

//MARK: Task Info
class TaskInfo extends StatelessWidget {
  TaskInfo({
    super.key,
  });

  final MenuController _reminderMenuController = MenuController();
  final MenuController _dueDateMenuController = MenuController();
  final MenuController _repeatMenuController = MenuController();

  final _anchorKey = GlobalKey();
  
  final bool isChecked = false;

  final bool inputNewSubTask = false;

    final TextStyle subTaskTextStyle = TextStyle(
    color: Colors.white.withValues(alpha: 0.5), 
    fontSize: 15
  );

  final TitleField taskTitle = TitleField(
    textSize: 20,
    fontWeight: FontWeight.bold,
    completed: false,
    // inputValue: subTask ?? "Add step",
    onChange: (value) {
      //TODO: update database
    },
  );


   Future _openCalendar({bool showTime = false, DateTime? hasDate}) async {

    final now = DateTime.now();
    Completer? completer  = Completer<DateTime?>();
    DateTime? selectedDate = hasDate ?? now;
    int? hourSelected = now.hour;
    int? minuteSelected = now.minute;

    final MenuController menuCalendarController = MenuController();

    final renderBox = _anchorKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // e.g. position the calendar directly below the anchor widget
    final calendarOffset = Offset(offset.dx, offset.dy + size.height);

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                overlayEntry!.remove();
                overlayEntry = null;
                completer.complete(null);
              },
            ),
          ),

          Positioned(
            top: calendarOffset.dy,
            left: calendarOffset.dx,
            child: Material(
              elevation: 8,
              color: Colors.white,
              // color: Colors.grey.shade900,
              child: SizedBox(
                width: 250,
                child: Column(
                  children: [
                    CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      onDateChanged: (date) {

                        selectedDate = date;

                      },
                    ),
                    // TODO: add a time picker here.
                    MenuAnchor(
                      controller: menuCalendarController,
                      builder: (context, controller, child) {

                        return TextButton(
                          onPressed: () {
                            controller.isOpen ? controller.close() : controller.open();
                          },
                          child: SizedBox(
                            height: 20,
                            child: Row(
                              children: [
                                Expanded(child: Text("$hourSelected".padLeft(2, "0"), textAlign: TextAlign.center,)), 
                                VerticalDivider(color: Colors.black, thickness: 1, ), 
                                Expanded(child: Text("$minuteSelected".padLeft(2, "0"), textAlign: TextAlign.center,)), 
                              ],
                            ),
                          )
                        );
                      },
                      menuChildren: [
                        SizedBox(
                          height: 250,
                          width: 230,
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        // TODO: try make the scroll start at the current time
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            for ( var index = 0; index < 24; index++)
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(0),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // assign new hour value
                                                  hourSelected = index;
                                                  print(hourSelected);
                                                },
                                                child: Text("$index"),
                                              ),
                                          ]
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            for ( var index = 0; index < 24; index++) Text("$index")
                                                                  
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                      ),
                                      onPressed: () {

                                        // print("save: $hourSelected");
                                        if ( selectedDate != null ) selectedDate!.subtract(Duration(hours: selectedDate!.hour));
                                        selectedDate!.add(Duration(hours: hourSelected!));
                                        
                                        menuCalendarController.close();
                                      },
                                      child: Icon(Icons.check),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(0),
                                        ),
                                      ),
                                      onPressed: () {
                                        
                                        menuCalendarController.close();
                                      },
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                ], 
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            overlayEntry?.remove();
                            overlayEntry = null;
                            completer.complete(null);
                            
                          },
                          child: Text("Cancel")
                        ),
                        TextButton(
                          onPressed: () {
                            overlayEntry?.remove();
                            overlayEntry = null;

                            completer.complete(selectedDate);

                          },
                          child: Text("Save")
                        ),
                      ]
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );

    _reminderMenuController.close();
    Overlay.of(_anchorKey.currentContext!).insert(overlayEntry!);

    return completer.future;

  }

  
  @override
  Widget build(BuildContext context) {

    final db = context.read<AppDB>();
    final taskID = context.watch<NavController>().currentTaskID;
    final isPanelOpen = context.watch<NavController>().showTaskPanel;


    return StreamBuilder(
      stream: db.watchTaskByIdWithSubTasks(taskID),
      builder: (context, snapshot) {

        if (!snapshot.hasData) return SizedBox.shrink();

        if (snapshot.data!.isEmpty) return SizedBox.shrink();

        if (snapshot.hasError) {
          return CustomPanel(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      //TODO: refresh streambuilder. class?
                    },
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          );
        }
        
        final task = snapshot.data;
    
        final parentTask = task![0];
        
        final subTasks = snapshot.data!.where((t) => t.parentId == parentTask.id).toList();
    
        return Visibility(
          visible: isPanelOpen,
          maintainState: true,
          maintainAnimation: true,
          child: CustomPanel(
            bottomBar: PanelBottomBar(
              taskDateLastModified: parentTask.updatedAt,
              deleteTask: () async {

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Text('Do you want to delete "${parentTask.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () async {

                            context.read<NavController>().toggleRightPanel(
                              state: false,
                            );

                            Navigator.of(context).pop();
                            
                            try {
                              await (db.delete(db.tasks)..where((task) => task.id.equals(parentTask.id))).go();
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: const Text("Delete")
                        ),
                        TextButton(
                          onPressed: () {

                            Navigator.of(context).pop();

                          },
                          child: const Text("Cancel")
                        ),
                      ],
                    );
                  }
                );

              },
            ),
            child: SingleChildScrollView(
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    //TODO:
                        //// subtasks
                        // button for adding to 'My Day' list
                        // reminder
                        // Due date
                        // repeat rule
                        // notes
            
                    //MARK: MAIN TASK NAME
                    ListTile(
                      splashColor: Colors.transparent,
                      tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                      // hoverColor: Colors.grey.shade800,
                      leading: Checkbox(
                        value: parentTask.isDone,
                        //TODO: Change color of the checkbox, to white
                        onChanged: (isDone) async {
                          
                          //! Why would it be null? Is this check even needed? There are only two states it
                          //! can have, no?
                          if (isDone != null) {
                            await db.updateTask(
                              taskID, 
                              isDone: Value(isDone),
                            );
                          }
                          
                        },
                      ),
                      title: TitleField(
                        fontWeight: FontWeight.bold,
                        completed: parentTask.isDone!,
                        inputValue: parentTask.title,
                        selectAllOnFocus: false,
                        onChange: (newTitle) async {

                          await db.updateTask(
                            parentTask.id,
                            title: Value(newTitle),
                          );
                          
                        },
                      ),
                    ),
                    //MARK: SUBTASK
                    if (subTasks.isNotEmpty)
                    //TODO: Make this into a separate class?
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: subTasks.length,
                      itemBuilder: (context, index) {
                
                        final subTask = subTasks[index];
                
                        return ListTile(
                          splashColor: Colors.transparent,
                          tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                          // hoverColor: Colors.grey.shade800,
                          //TODO: Change color of the checkbox, to white
                          //! might not need this. maybe Do this in titleField.
                          leading: Checkbox(
                            value: subTask.isDone,
                            onChanged: (isDone) async {
                
                              await db.updateTask(
                                subTask.id,
                                isDone: Value(isDone!),
                                parentID: parentTask.id //updating parent task - updated_at
                              );
                              
                            },
                          ),
                          title: TitleField(
                            textSize: 15,
                            completed: subTask.isDone!,
                            inputValue: subTask.title,
                            onChange: (title) async {
                
                              await db.updateTask(
                                subTask.id,
                                title: Value(title),
                                parentID: parentTask.id, //Updating parent task - updated_at "TIME"
                              );
                
                            },
                          ),
                        );
                      },
                    ),
                    //! Show if there is no subtasks  
                    ListTile(
                      splashColor: Colors.transparent,
                      tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                      leading: Icon(Icons.add, size: 25), //TODO: Change to a diffrent icon when inputting new task
                      title: TitleField(
                        textSize: 15,
                        labelText: subTasks.isNotEmpty ? "Next step" : "Add step",
                        labelStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5), 
                          fontSize: 15
                          ),
                        onChange: (subTitle) async {
                          
                          // Adding a new sub task to database
                          await db.insertTask(
                            parentID: parentTask.id,
                            listID: parentTask.listsId!,
                            title: subTitle,
                            position: 0,
                          );
                          
                        },
                        // inputValue: subTask!.isEmpty ? "Add step" : "Next Step"
                      ),
                      // title: inputNewSubTask ? taskTitle :
                      //   subTask!.isEmpty ? Text("Add step", style: subTaskTextStyle) : Text("Next Step", style: subTaskTextStyle,), //! Titlefield - take from above in listview
                    ),
                    SizedBox(height: 10),

                    // MARK: Add To My Day
                    CustomTileTaskInfo(
                      title: Text((parentTask.addedToMyDay ?? false) ? "Added in My Day" : "Add to My Day"),
                      currentTask: parentTask,
                      tileOnPressedStayEnabledAfter: parentTask.addedToMyDay == true ? false : true,
                      addedToMyDay: parentTask.addedToMyDay,
                    ),

                    SizedBox(height: 10),

                    // MARK: REMINDER
                    MenuAnchor(
                      controller: _reminderMenuController,
                      key: _anchorKey,
                      consumeOutsideTap: true, // similar to "Barrier" in showdialog, i think
                      style: MenuStyle(
                        backgroundColor: WidgetStateProperty.fromMap({WidgetState.any: Colors.grey.shade800}),
                      ),
                      builder: (context, controller, child) {

                        return CustomTileTaskInfo(
                          title: Text( parentTask.reminder != null ? "${parentTask.reminder}" :  "Remind me"),
                          currentTask: parentTask,
                          reminder: parentTask.reminder,
                          tileOnPressed: () {

                            _reminderMenuController.isOpen ? controller.close() : controller.open();

                            //! How do I get the date selection to here? or do I have update in the menuitem button?
                            //update after selecting an option

                            // menu anchor
                              // options:
                                // Later today - Wed 15:00
                                // Tomorrow - Thu 09:00
                                // Next Wed - 09:00
                                // Next Week - Mon 09:00
                                // Choose a date and time
                            // pass the select date to customtiletaskinfo

                          },
                        );
                      },
                      menuChildren: [

                        //TODO: make the text a little smaller, 2-5 smaller
                        CustomTileTaskInfo(
                          //TODO: increment time.now with +3
                          title: Text("Later today at N:00"),
                          currentTask: parentTask,
                          tileOnPressed: () {

                            // Adds 3 hours to current itme
                            final today = DateTime.now();
                            final laterTodayAtN = today.add(Duration(hours: 3));

                            return laterTodayAtN;
                            
                          },
                        ),
                        CustomTileTaskInfo(
                          title: Text("Tomorrow - 9:00 "),
                          currentTask: parentTask,
                          tileOnPressed: () {

                            final today = DateTime.now();
                            final tomorrowAt9 = DateTime.utc(today.year, today.month, (today.day + 1), 9, 00,);

                            return tomorrowAt9;
                            
                          },
                        ),

                        CustomTileTaskInfo(
                          title: Text("Next Monday - 9am?"),
                          currentTask: parentTask,
                          tileOnPressed: () {

                            final today = DateTime.now(); 

                            if (today.weekday == 7 && today.hour == 23 && today.minute > 56) {
                              print("too late");
                              return null; 
                            }

                            // 7 - 1 + 1 = 7 | mon(1) + 7 =  mon
                            // 7 - 2 + 1 = 6 | tue(2) + 6 = mon
                            // 7 - 3 + 1 = 5 | wed(3) + 5 = mon
                            final nextMondayAt9 = today.add(Duration(days: (7 - today.weekday) + 1));

                            return nextMondayAt9;
                            
                          },
                        ),

                        CustomTileTaskInfo(
                          title: Text("Next Week -- (same weekday)"),
                          currentTask: parentTask,
                          tileOnPressed: () {

                            // if today isnt past 9:00 then set task reminder to 9:00
                            final today = DateTime.now();
                            final nextSameWeekDay = today.add(Duration(days: 7));

                            return nextSameWeekDay;
                            
                          },
                        ),

                        CustomTileTaskInfo(
                          title: Text("Choose"),
                          currentTask: parentTask,
                          tileOnPressed: () async {

                            DateTime? selectedDate = await _openCalendar();

                            print(selectedDate);

                            return selectedDate;
                        
                        
                            // TODO: close the first menuanchor and then show anthoer one with dates/calendar
                            // and in a different tab time

                            // Need position details, like in gesturedetector. Used a globalkey on the menuanchor to get 
                            // the position with currentcontext - renderbox
                            // To do what? To position the new "popup",
                            // still dont know how to do this. Like a switch to new one.. but HOW?
                            // 


                            // How to do this?
                              // children:
                                // current month + button to go back or forward in the months
                                // tables of columns and rows with dates
                                // time - able to select hh and mm separately
                                // button to cancel and save changes
                            
                          },
                        ),
                      ],
                    ),

                    // MARK: DUE DATE
                    ListTile(
                      title:Text("Due Date"),
                      tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                    ),

                    // MARK: REPEAT
                    ListTile(
                      title:Text("Repeat"),
                      tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                    ),
                    SizedBox(height: 10,),

                    // MARK: NOTES
                    ListTile(
                      title:Text("Notes"),
                      tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                    ),
                  ]
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

class CustomTileTaskInfo extends StatelessWidget {
  const CustomTileTaskInfo({
    super.key,
    this.title,
    required this.currentTask,
    this.tileOnPressed,
    this.buttonOnPressed,
    
    /// Stays clickable/actionable after having setting the option 
    /// to something(adding to my day, setting an reminder, etc..)
    this.tileOnPressedStayEnabledAfter = true, 
    
    this.addedToMyDay,
    this.reminder,
    this.dueDate,
    this.repeat,
    this.notes,
  });
  
  final Text? title;
  final Task currentTask;

  final bool tileOnPressedStayEnabledAfter;
  
  final Function()? tileOnPressed;
  final Function()? buttonOnPressed;

  final bool? addedToMyDay;
  final DateTime? reminder;
  final DateTime? dueDate;
  final String? repeat;
  final String? notes;
  

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDB>();

    final bool enableTrailingButton = addedToMyDay != null ||
      reminder != null || 
      dueDate != null ||
      repeat != null ||
      notes != null;

    return Row(
      children: [
        //TODO: make it more "visible", something that highlights that its in my day
        Expanded(
          child: ListTile(
            title: title,
            hoverColor: Colors.grey.shade700,
            splashColor: Colors.transparent,
            tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            onTap: tileOnPressedStayEnabledAfter ? () async {
              
              //! need the value from the dialog that got selected.
              
              if (tileOnPressed == null) return;

              dynamic returnValue;
              DateTime? currentDate;
              String? noteString;

              returnValue = await tileOnPressed!.call();

              print("helo: $returnValue");

              // DateTime - String

              // print("from customTile - date: $currentDate");
              // print("from customTile - notes: $noteString");

              // print("$addedToMyDay");

              db.updateTask(
                currentTask.id,
                addedToMyDay: addedToMyDay != null ? Value.absent() : Value(true),
                reminder: reminder != null ? Value.absent() : Value(currentDate),
                // dueDate: dueDate != null ? Value.absent() : Value(currentDate),
                // repeat: repeat != null ? Value.absent() : Value(),
                // notes: notes != null ? Value.absent() : Value(),
              );

            } 
            : null
          ),
        ),
        Visibility(
          visible: enableTrailingButton,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsetsDirectional.symmetric(vertical: 19),
              backgroundColor: Colors.grey.shade600.withValues(alpha: 0.3),
              overlayColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
              ),
            ),
            onPressed: () async {

              await db.updateTask(
                currentTask.id,
                addedToMyDay: addedToMyDay != null ? Value(null) : const Value.absent(),
                // reminder: reminder != null ? Value(null) : const Value.absent(),
                // dueDate: dueDate != null ? Value(null) : const Value.absent(),
                // repeat: repeat != null ? Value(null) : const Value.absent(),
                // notes: notes != null ? Value(null) : const Value.absent(),

              );
                
            },
            //TODO: can I make it thinner?
            child: Icon(Icons.close_outlined,
            color: Colors.white,
            size: 26,
            )
          ),
        ),
      ],
    );
  }
}

// MARK: BottomBar
class PanelBottomBar extends StatelessWidget {

  const PanelBottomBar({
    super.key, 
    required this.deleteTask,
    this.hidePanel,
    this.taskDateLastModified,
    
    });

  final VoidCallback? hidePanel;   
  final VoidCallback? deleteTask;   
  final DateTime? taskDateLastModified;

  //TODO: Maybe use this in 'Task Info' instead of 'Main Page'

  @override
  Widget build(BuildContext context) {
    final date = taskDateLastModified;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            // Close panel
            ElevatedButton(
              onPressed: hidePanel ?? () {

                context.read<NavController>().toggleRightPanel();

              },
              child: const Icon(Icons.arrow_forward_ios)
            ),
            
            // Delete Task and close panel
            ElevatedButton(
              onPressed: deleteTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              ),
              child: const Text(
                "Delete Task"
              ),
            ),
        
          ],
        ),
        Center(
          child: Text(
            // "Created on Wed. 19 Jun 2025",
            "Created on "
            "${DateFormat("E").format(date!)}. "
            "${date.day} "
            "${DateFormat("MMM").format(date)} "
            "${date.year}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
            )
          ),
        ),
      ],
    );
  }
}