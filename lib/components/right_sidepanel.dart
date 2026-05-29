// ignore_for_file: avoid_print

import 'dart:async';

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
class TaskInfo extends StatefulWidget {
  const TaskInfo({
    super.key,
  });

  @override
  State<TaskInfo> createState() => _TaskInfoState();
}

class _TaskInfoState extends State<TaskInfo> {

  final List<String> customRepeatList = ["daily", "weekdays", "weekly", "monthly", "yearly", "custom: datetime"];

  final MenuController _reminderMenuController = MenuController();
  final MenuController _dueDateMenuController = MenuController();
  final MenuController _repeatMenuController = MenuController();

  final OverlayPortalController _reminderCalendarController = OverlayPortalController();
  final OverlayPortalController _dueDateCalendarController = OverlayPortalController();
  final OverlayPortalController _repeatCustomController = OverlayPortalController();


  final _reminderAnchorKey = GlobalKey();
  final _dueDateAnchorKey = GlobalKey();
  final _repeatAnchorKey = GlobalKey();

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

  


  @override
  Widget build(BuildContext context) {

    final db = context.read<AppDB>();
    final taskID = context.watch<NavController>().currentTaskID;
    final isPanelOpen = context.watch<NavController>().showTaskPanel;

    final now = DateTime.now();


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
                        onChange: (subTaskTitle) async {
                          
                          // Adding a new sub task to database
                          await db.insertTask(
                            parentID: parentTask.id,
                            listID: parentTask.listsId!,
                            title: subTaskTitle,
                            position: 0,
                          );
                          
                        },
                        // inputValue: subTask!.isEmpty ? "Add step" : "Next Step"
                      ),
                    ),
                    SizedBox(height: 10),

                    // MARK: Add To My Day
                    CustomTileTaskInfo(
                      title: (parentTask.addedToMyDay ?? false) ? "Added in My Day" : "Add to My Day",
                      currentTask: parentTask,
                      tileOnPressedStayEnabledAfter: parentTask.addedToMyDay == true ? false : true,
                      addedToMyDay: parentTask.addedToMyDay,
                    ),

                    SizedBox(height: 10),

                    // MARK: REMINDER
                    MenuAnchor(
                      controller: _reminderMenuController,
                      key: _reminderAnchorKey,
                      consumeOutsideTap: true, // similar to "Barrier" in showdialog, i think
                      style: MenuStyle(
                        backgroundColor: WidgetStateProperty.fromMap({WidgetState.any: Colors.grey.shade800}),
                      ),
                      builder: (context, controller, child) {

                        return CustomCalendarPicker(
                          controller: _reminderCalendarController,
                          anchorKey: _reminderAnchorKey,
                          hasDate: parentTask.reminder,
                          onDateTimeChanged: (value) async {
                            await db.updateTask(
                              parentTask.id,
                              reminder: Value(value),
                            );
                          },
                          showTime: true,
                          child: CustomTileTaskInfo(
                            title: parentTask.reminder != null 
                            ? "Remind me at ${DateFormat("Hm").format(parentTask.reminder!)}"
                            :  "Remind me",
                            subTitle: parentTask.reminder != null
                            ? DateFormat("EEE, d MMM y").format(parentTask.reminder!)
                            : null,
                            currentTask: parentTask,
                            reminder: parentTask.reminder,
                            tileOnPressed: () {
                          
                              _reminderMenuController.isOpen ? controller.close() : controller.open();
                          
                            },
                          ),
                        );
                      },
                      menuChildren: [

                        //TODO: make the text a little smaller, 2-5 smaller
                        CustomTileTaskInfo(
                          //TODO: increment time.now with +3
                          title: "Later today at N:00",
                          currentTask: parentTask,
                          tileOnPressed: () {

                            // Adds 3 hours to current itme
                            final DateTime today = DateTime.now();
                            final DateTime laterTodayAtN = today.add(Duration(hours: 3));

                            //TODO: update db with new value
                            
                          },
                        ),
                        CustomTileTaskInfo(
                          title: "Tomorrow - 9:00 ",
                          currentTask: parentTask,
                          tileOnPressed: () {

                            final today = DateTime.now();
                            final tomorrowAt9 = DateTime.utc(today.year, today.month, (today.day + 1), 9, 00,);

                            return tomorrowAt9;
                            
                          },
                        ),

                        CustomTileTaskInfo(
                          title: "Next Monday - 9am?",
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
                          title: "Next Week -- (same weekday)",
                          currentTask: parentTask,
                          tileOnPressed: () {

                            // if today isnt past 9:00 then set task reminder to 9:00
                            final today = DateTime.now();
                            final nextSameWeekDay = today.add(Duration(days: 7));

                            return nextSameWeekDay;
                            
                          },
                        ),
                        
                        CustomTileTaskInfo(
                          title: "Choose",
                          currentTask: parentTask,
                          tileOnPressed: () async {
                        
                            _reminderMenuController.close();
                            _reminderCalendarController.show();
                        
                          },
                        ),
                      ],
                    ),

                    // MARK: DUE DATE
                    MenuAnchor(
                      controller: _dueDateMenuController,
                      key: _dueDateAnchorKey,
                      consumeOutsideTap: true,
                      style: MenuStyle(
                        backgroundColor: WidgetStateProperty.fromMap({WidgetState.any: Colors.grey.shade800}),
                      ),
                      builder: (context, controller, child) {
                        return CustomCalendarPicker(
                          controller: _dueDateCalendarController,
                          anchorKey: _dueDateAnchorKey,
                          hasDate: parentTask.dueDate,
                          showTime: false,
                          onDateTimeChanged: (value) async {
                            await db.updateTask(
                              parentTask.id,
                              dueDate: Value(value),
                            );
                          },
                          child: CustomTileTaskInfo(
                            currentTask: parentTask,
                            dueDate: parentTask.dueDate,
                            title: parentTask.dueDate != null 
                            ? "Due ${DateFormat("EEE, d MMM y").format(parentTask.dueDate!)}"
                            : "Add due date",
                            tileOnPressed: () {
                              _dueDateMenuController.isOpen ? _dueDateMenuController.close() : _dueDateMenuController.open();
                            },
                          ),
                        );
                      },
                      menuChildren: [
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Due Today - ${DateFormat("EEE").format(now)}",
                          tileOnPressed: () async {
                            _dueDateMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              dueDate: Value(now),
                            );
                          },
                        ),
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Due Tomorrow - ${DateFormat("EEE").format(now.add(Duration(days: 1)))}",
                          tileOnPressed: () async {
                            _dueDateMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              dueDate: Value(now.add(Duration(days: 1))),
                            );
                          },
                        ),
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Due Next Week - ${DateFormat("EEE").format(now.add(Duration(days: 7)))}",
                          tileOnPressed: () async {
                            _dueDateMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              dueDate: Value(now.add(Duration(days: 7))),
                            );
                          },
                        ),
                        //* Updating db happens in the menu anchor builder
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Choose",
                          tileOnPressed: () {
                            _dueDateCalendarController.show();
                          },
                        ),
                      ],
                    ),
                    // ListTile(
                    //   title:Text("Due Date"),
                    //   tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
                    // ),

                    // MARK: REPEAT
                    MenuAnchor(
                      controller: _repeatMenuController,
                      key: _repeatAnchorKey,
                      consumeOutsideTap: true,
                      style: MenuStyle(
                        backgroundColor: WidgetStateProperty.fromMap({WidgetState.any: Colors.grey.shade800}),
                      ),
                      builder: (context, controller, child) {
                        //TODO: create an custom class for selecting custom repeat date
                        return OverlayPortal(
                          controller: _repeatCustomController,
                          overlayChildBuilder: (context) {

                            final box = _repeatAnchorKey.currentContext!.findRenderObject() as RenderBox;
                            final size = box.size;
                            final offset = box.localToGlobal(Offset.zero);

                            final repeatCustomOffset = Offset(offset.dx, offset.dy + size.height);

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      _repeatCustomController.hide();
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: repeatCustomOffset.dy,
                                  left: repeatCustomOffset.dx,
                                  child: Container(
                                    color: Colors.grey.shade800,
                                    child: Column(
                                      children: [
                                        Text("Repeat every.."),
                                        Row(
                                          children: [
                                            // TextField
                                            // TextField(),

                                            // Dropdownmenu
                                            DropdownButton(
                                              value: parentTask.repeat,
                                              onChanged: (value) {},
                                              items: customRepeatList.map<DropdownMenuItem>((String value) {
                                                return DropdownMenuItem();
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children:[
                                            // Cancel
                                            TextButton(
                                              onPressed: () {
                                                _repeatCustomController.hide();
                                              },
                                              style: ButtonStyle(),
                                              child: Text("Cancel")
                                            ),

                                            // Save
                                            TextButton(
                                              onPressed: () {
                                                _repeatCustomController.hide();
                                                // convert selected to string
                                                // update db task repeat 
                                              },
                                              style: ButtonStyle(),
                                              child: Text("Save")
                                            ),
                                          ]
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );

                          }, 
                          child: CustomTileTaskInfo(
                            currentTask: parentTask,
                            repeat: parentTask.repeat,
                            title: parentTask.repeat ?? "Repeat",
                            tileOnPressed: () {
                              _repeatMenuController.isOpen ? _repeatMenuController.close() : _repeatMenuController.open();
                            },
                          ),
                        );
                      },
                      menuChildren: [
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Daily",
                          tileOnPressed: () async {

                            _repeatMenuController.close();
                            
                            //! this should update duedate as well, which we will use to add on.
                            //! Need to create an new task with an new duedate if this is completed.
                            await db.updateTask(
                              parentTask.id,
                              repeat: Value("daily"),
                              dueDate: Value(DateTime.now()),
                            );
                          },
                        ),
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Weekdays",
                          tileOnPressed: () async {

                            _repeatMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              repeat: Value("weekdays"),
                              dueDate: Value(DateTime.now()),
                            );
                          },
                        ),
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Weekly",
                          tileOnPressed: () async {

                            _repeatMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              repeat: Value("weekly"),
                              dueDate: Value(DateTime.now()),
                            );
                          },
                        ),
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Monthly",
                          tileOnPressed: () async {

                            _repeatMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              repeat: Value("monthly"),
                              dueDate: Value(DateTime.now()),
                            );
                          },
                        ),
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Yearly",
                          tileOnPressed: () async {

                            _repeatMenuController.close();
                            await db.updateTask(
                              parentTask.id,
                              repeat: Value("yearly"),
                              dueDate: Value(DateTime.now()),
                            );
                          },
                        ),
                        Divider(height: 0, thickness: 1,),
                        
                        CustomTileTaskInfo(
                          currentTask: parentTask,
                          title: "Custom",
                          tileOnPressed: () async {
                        
                            _repeatMenuController.close();
                            _repeatCustomController.show();
                            // open custom selection of repeat date
                        
                            // await db.updateTask(
                            //   parentTask.id,
                            //   repeat: Value(""), //! this might actually need to be an datetime
                            //   dueDate: Value(DateTime.now()),
                            // );
                          }
                        ),
                      ],
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

//MARK: CustomOverlayRepeatDate
class CustomOverlayRepeatDate extends StatefulWidget {
  const CustomOverlayRepeatDate({
    super.key,
    required this.child,
  });

  final Widget? child;

  @override
  State<CustomOverlayRepeatDate> createState() => _CustomOverlayRepeatDateState();
}

class _CustomOverlayRepeatDateState extends State<CustomOverlayRepeatDate> {

  final OverlayPortalController _controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _controller,
      overlayChildBuilder: (context) {
        return Container(
          width: 50,
          height: 50,
          color: Colors.red,
        );
      },
      child: widget.child,
    );
  }
}

//MARK: CustomTile - options
class CustomTileTaskInfo extends StatelessWidget {
  const CustomTileTaskInfo({
    super.key,
    this.title,
    this.subTitle,
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
  
  final String? title;
  final String? subTitle;
  final Task currentTask;

  final bool tileOnPressedStayEnabledAfter;
  
  final Function()? tileOnPressed;
  final Function()? buttonOnPressed; //! what is this for?

  final bool? addedToMyDay;
  final DateTime? reminder;
  final DateTime? dueDate;
  final String? repeat;
  final String? notes;
  

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDB>();

    //TODO: rename variable to something more fitting, because its being used not only for trailingbutton.
    final bool enableTrailingButton = (addedToMyDay != null && addedToMyDay == true) ||
      reminder != null || 
      dueDate != null ||
      repeat != null ||
      notes != null;

    return Row(
      children: [
        //TODO: make it more "visible", something that highlights that its in my day
        Expanded(
          child: ListTile(
            title: title != null ? Text(title!) : null,
            subtitle: subTitle != null ? Text(subTitle!) :  null,
            subtitleTextStyle: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
            //TODO: change color to red if its past due
            //* using "enableTrailingButton" variable to also determine if any of the options that is using this is non-null/has value.
            textColor: enableTrailingButton ? const Color.fromARGB(255, 119, 178, 226) : Colors.white,
            hoverColor: Colors.grey.shade700.withValues(alpha: 0.1),
            splashColor: Colors.transparent,
            tileColor: Colors.grey.shade800.withValues(alpha: 0.2),
            onTap: tileOnPressedStayEnabledAfter ? tileOnPressed : null,
          ),
        ),
        Visibility(
          visible: enableTrailingButton,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsetsDirectional.symmetric(vertical: subTitle != null 
              ? 27
              : 19),
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
                reminder: reminder != null ? Value(null) : const Value.absent(),
                dueDate: dueDate != null ? Value(null) : const Value.absent(),
                repeat: repeat != null ? Value(null) : const Value.absent(),
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

//MARK: Calendar - date
class CustomCalendarPicker extends StatefulWidget {
  const CustomCalendarPicker({
    super.key,
    this.showTime = false,
    this.hasDate,
    required this.controller,
    required this.anchorKey,
    required this.child,
    required this.onDateTimeChanged,
  });

  final bool showTime;
  final DateTime? hasDate;
  final Widget child;
  final OverlayPortalController controller;
  final GlobalKey anchorKey;
  final Function(DateTime?) onDateTimeChanged; 



  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {

  final now = DateTime.now();
  late DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.hasDate ?? now;
  }


  @override
  Widget build(BuildContext context) {


    //! why is this running twice?
    print("hello calendar show please");


    return OverlayPortal(
      controller: widget.controller,
      overlayChildBuilder: (context) {

        final renderBox = widget.anchorKey.currentContext!.findRenderObject() as RenderBox;
        final size = renderBox.size;
        final offset = renderBox.localToGlobal(Offset.zero);

        // e.g. position the calendar directly below the anchor widget
        final calendarOffset = Offset(offset.dx, offset.dy + size.height);


        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  widget.controller.hide();
                  //! causes error on tap outisde. do I even need this?
                  // completer!.complete(null);
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CalendarDatePicker(
                        initialDate: widget.hasDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        onDateChanged: (date) {
                          
                          //! explain
                          setState(()  => selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            selectedDate?.hour ?? widget.hasDate?.hour ?? now.hour,
                            selectedDate?.minute ?? widget.hasDate?.minute ?? now.minute,
                          ));
                          
                        },
                      ),
                      if (widget.showTime)
                        TimePicker(
                          dateTime: widget.hasDate,
                          onTimeChanged: (time) {
                            
                            setState(() {
                              //! explain
                              selectedDate = DateTime(
                                selectedDate?.year ?? widget.hasDate?.year ?? now.year,
                                selectedDate?.month ?? widget.hasDate?.month ?? now.month,
                                selectedDate?.day ?? widget.hasDate?.day ?? now.day,
                                time.hour,
                                time.minute,

                              );
                            });
                          },

                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                        
                              widget.controller.hide();
                              
                            },
                            child: Text("Cancel")
                          ),
                          TextButton(
                            onPressed: () async {
                        
                              widget.controller.hide();
                              widget.onDateTimeChanged.call(selectedDate);
                          
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
        );
      },
      child: widget.child,
    );
  }
}


// MARK: Timepicker
class TimePicker extends StatefulWidget {
  const TimePicker({
    super.key,
    this.dateTime,
    required this.onTimeChanged
  });

  final DateTime? dateTime;
  final void Function(DateTime) onTimeChanged;

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {

  final DateTime now = DateTime.now(); 

  int? hourSelected;
  int? minuteSelected;
  
  //TODO: better naming
  late int currentHour;
  late int currentMinute;

  final MenuController menuTimeController = MenuController();

  late FixedExtentScrollController hourScrollController;
  late FixedExtentScrollController minuteScrollController;

  @override
  void initState() {
    super.initState();

    currentHour = widget.dateTime != null ? widget.dateTime!.hour : now.hour;
    currentMinute = widget.dateTime != null ? widget.dateTime!.minute : now.minute;

    hourScrollController = FixedExtentScrollController(initialItem: currentHour);
    minuteScrollController = FixedExtentScrollController(initialItem: currentMinute);

  }


  @override
  void dispose() {
    
    hourScrollController.dispose();
    minuteScrollController.dispose();

    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: menuTimeController,
      alignmentOffset: Offset.fromDirection(1, 20),
      style: MenuStyle(
        alignment: Alignment.centerLeft,
      ),
      builder: (context, controller, child) {
        return TextButton(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          child: SizedBox(
            height: 20,
            child: Row(
              children: [
                Expanded(child: Text("$currentHour".padLeft(2, "0"), textAlign: TextAlign.center,)), 
                VerticalDivider(color: Colors.black, thickness: 1, ), 
                Expanded(child: Text("$currentMinute".padLeft(2, "0"), textAlign: TextAlign.center,)), 
              ],
            ),
          )
        );
      },
      menuChildren: [
        SizedBox(
          height: 240,
          width: 230,
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: IgnorePointer(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      itemExtent: 48,
                      controller: hourScrollController,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => hourSelected = index % 24);
                      },
                      childDelegate: ListWheelChildLoopingListDelegate(
                      children: [
                          for ( var index = 0; index < 24; index++)
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    hourScrollController.animateToItem(
                                      index, 
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.bounceIn,
                                    );
                                  });
                                },
                                child: Text("$index".padLeft(2, "0")),
                              ),
                            ),
                        ],
                      ), 
                    ),
                  ],
                ),
              ),
    
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: IgnorePointer(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    ListWheelScrollView.useDelegate(
                      itemExtent: 48,
                      controller: minuteScrollController,
                      physics: FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => minuteSelected = index % 60);
                      },
                      childDelegate: ListWheelChildLoopingListDelegate(
                      children: [
                          for ( var index = 0; index < 60; index++)
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    minuteScrollController.animateToItem(
                                      index, 
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.bounceIn,
                                    );
                                  });
                                },
                                child: Text("$index".padLeft(2, "0")),
                              ),
                            ),
                        ],
                      ), 
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0),
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {
                  // callback function to return the selected minute and hour
                  menuTimeController.close();
                  setState(() {

                    currentHour = hourSelected ?? currentHour;
                    currentMinute = minuteSelected ?? currentMinute;

                    widget.onTimeChanged.call(DateTime(
                      widget.dateTime?.year ?? now.year,
                      widget.dateTime?.month ?? now.month,
                      widget.dateTime?.day ?? now.day,
                      currentHour,
                      currentMinute,
                    ));

                  });
                },
                child: Icon(Icons.check)
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
                  menuTimeController.close();
                },
                child: Icon(Icons.close)
              ),
            ),
          ],
        ),
      ],
    );
  }
}