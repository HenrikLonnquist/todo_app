// import 'dart:ffi';

import 'package:drift/drift.dart' hide Column;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/components/add_task_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/components/title_field.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/nav_controller.dart';
import 'dart:math' as math;



class SpecialLists {
  static const int myDay = 1;
  static const int important = 2;
  static const int tasks = 3;
}


void main() async {

  //! Splash screen - cant find one for linux or desktop.
  //! There exists one for ios, android and web tho.

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDB>(
          create: (_) => AppDB(),
          dispose: (_, db) => db.close(),
          child: MyApp(),
        ),
        ChangeNotifierProvider(
          create: (_) => NavController(),
        ),
      ],
      child: MyApp(),
    ),
  );
  
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.black,
          surface: Colors.white,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(splashFactory: NoSplash.splashFactory)
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(splashFactory: NoSplash.splashFactory)
        ),
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.grey.shade700.withValues(alpha: 0.5),
          selectedColor: Colors.white,
          textColor: Colors.white,
          
        )
      ),
      // home: NavigationPanel(database: database),
      //MARK: MAIN?
      home: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavigationPanel2(
            ),
            MainPage(
            ),
            //RightSidePanel/TaskInfo
            TaskInfo( 
            ),
          ]
        )      
      )
    );
  }
}


//MARK: Nav Panel
class NavigationPanel2 extends StatefulWidget {
  const NavigationPanel2({
    super.key,
  });

  @override
  State<NavigationPanel2> createState() => _NavigationPanel2State();
}

class _NavigationPanel2State extends State<NavigationPanel2> {

  final listKey = GlobalKey();


  @override
  Widget build(BuildContext context) {

    final db = context.read<AppDB>();
    final selectedTabIndex = context.select<NavController, int>((i) => i.navIndex);


    return CustomPanel(
      sidePanelWidth: 220,
      padding: null,
      bottomBar: Material(
        type: MaterialType.transparency,
        child: ListTile(
          title: Text("New list +"),
          hoverColor: Colors.grey.shade800,
          onTap: () async {
            
            await db.todoLists.count().get().then((value) async {
              
              int size = value[0] - 3; // 3 default tabs("My day"..
              //! if there is one in the list already then the second will have the same pos. Because of "count(1) * 1000" equals 1000
              int newPosition = (size <= 1 ? size + 1 : size) * 1000; 
            
              await db.into(db.todoLists).insert(TodoListsCompanion.insert(
                name: Value("Untitled list ${size + 1}"),
                position: newPosition,
              ));

            },);

            
          },
        ),
      ),
      child: StreamBuilder(
        stream: db.watchTaskCountPerList(),
        builder: (context, snapshot) {


                    
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
          }


          final Map listTaskCount = snapshot.data ?? {};
          
          if (listTaskCount.isEmpty) {
            print("DATA is empty");
          }

          return SingleChildScrollView(
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
          
                  NavListTile(title: "My Day", listID: 1, selectedTabIndex: selectedTabIndex, taskCount: listTaskCount["myday"]),
                  NavListTile(title: "Important", listID: 2, selectedTabIndex: selectedTabIndex, taskCount: listTaskCount["starred"]),
                  NavListTile(title: "Tasks", listID: 3, selectedTabIndex: selectedTabIndex, taskCount: listTaskCount[3]),
                  
                  Divider(),
          
                  //MARK: User Lists
                  StreamBuilder(
                    stream: db.watchUserLists(),
                    builder: (context, snapshot) {
          
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.white));
                      }
          
          
                      final data = snapshot.data ?? [];
          
                      if (data.isEmpty) {
                        return Center(
                          child: Text(
                            "Add a new list",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            ),
                        );
                      }
          
                      return ListView.builder(
                        key: listKey,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: data.length, 
                        itemBuilder: (context, index) {
          
                          final userList = data[index];
          
                          return NavListTile(
                            title: userList.name!, 
                            listID: userList.id, 
                            userPos: userList.position,
                            selectedTabIndex: selectedTabIndex,
                            isUserList: true,
                            taskCount: listTaskCount[userList.id],
                          );
                        },
                      );
                    }
                  ),
                ]
              ),
            ),
          );
        }
      ),
    );
  }
}

//MARK: Nav List Tile
class NavListTile extends StatefulWidget {
  const NavListTile({
    super.key,
    required this.listID,
    required this.selectedTabIndex,
    required this.title,
    this.isUserList = false,
    this.taskCount = 0,
    this.userPos,
  });


  final int listID;
  final int? userPos;
  final int? taskCount;
  final int selectedTabIndex;
  final String title;
  final bool isUserList;

  @override
  State<NavListTile> createState() => _NavListTileState();
}

class _NavListTileState extends State<NavListTile> {

  bool listRename = false;

  final MenuController _menuController = MenuController();

  final MenuController _subMenuController = MenuController();

  final FocusNode _subMenuFocusNode = FocusNode();

  PopupMenuItem commonMenuItem({
    VoidCallback? onTap,
    required String title,
  }) {

    return PopupMenuItem(
      mouseCursor: SystemMouseCursors.basic,
      onTap: onTap,
      child: Text(title, style: TextStyle(color: Colors.white)),
    );

  }


  @override
  Widget build(BuildContext context) {

    final AppDB db = context.read<AppDB>();

    //MARK: Nav list item
    return MenuAnchor(
      controller: _menuController,
      //* Dont worry about the delay, only happens in debug mode.
      builder: (context, controller, child) {

        return GestureDetector(
          onSecondaryTapDown: (details) {
            _menuController.open(position: details.localPosition);
          },
          child: ListTile(
            mouseCursor: SystemMouseCursors.basic,
            hoverColor: widget.listID == widget.selectedTabIndex ? Colors.grey.shade700 : Colors.grey.shade800,
            selected: widget.listID == widget.selectedTabIndex,
            selectedTileColor: Colors.grey.shade700,
            splashColor: Colors.transparent,
            // TODO: need something for indicating its in "editable mode" > dotted-line border/underscore
            // something like a lighter/dakrer background color could also work.
            title: TitleField(
              disableTextEditing: !listRename,
              onTapOutside: (event) {
            
                setState(() {
                  _menuController.close();
                  listRename = false;
                });
            
              },
              // Need to comment this if you dont want selectall immediately 
              // when tapping "Rename List" from secondray tap.
              requestFocus: listRename, 
              inputValue: widget.title,
              textSize: 16,
              onChange: (value) async {
            
                // skip if the value has not changed.
                if (value != widget.title) {
            
                  await db.updateList(
                    widget.listID,
                    name: Value(value),
                  );
            
                } 
            
                setState(() {
                  listRename = false;
                });
            
              },
            ),
            trailing: Text("${widget.taskCount ?? 0}"),
            onTap: listRename ? null : (){
          
              // notify provider on tab change
              context.read<NavController>().setNavListNameAndIndex(widget.title ,widget.listID);
                
            },
          ),
        );

      },
      //MARK: dropdown list 
      menuChildren: [

        // Rename list
        MenuItemButton(
          child: Text("Rename List"),
          onPressed: () {
            setState(() {
              listRename = true;
            });
          },
        ),

        // Share List
        MenuItemButton(
          child: Text("Share List"),
          // onPressed: () {}
        ),

        Divider(),

        // Move list to... >
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) _subMenuController.close();
          },
          child: MenuAnchor(
            controller: _subMenuController,
            childFocusNode: _subMenuFocusNode,
            builder: (context, controller, child) {
          
              return MouseRegion(
                onEnter: (_) => _subMenuFocusNode.requestFocus(),
                child: TextButton(
                  focusNode: _subMenuFocusNode,
                  onPressed: () {
                    controller.isOpen ? controller.close() : controller.open();
                    
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(0)
                    ),
                    visualDensity: VisualDensity(vertical: 0.50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Move list to.."),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: const Icon(Icons.arrow_right, size: 24),
                      ),
                    ],
                  )
                ),
              );
            },
            menuChildren: [
              // List of tabs to choose from.
              MenuItemButton(
                // style: 
                child: const Text("test"),
                onPressed: () {},
              ),
              MenuItemButton(
                child: const Text("test"),
                onPressed: () {},
              ),
            ],
          ),
        ),


        // Print List
        MenuItemButton(
          child: Text("Print List"),
          // onPressed: () {}
        ),
        
        // Email List
        MenuItemButton(
          child: Text("Email List"),
          // onPressed: () {}
        ),
        
        // Pin start //! What is this gonna do?
        MenuItemButton(
          child: Text("Pin Start"),
          // onPressed: () {}
        ),
        
        // Duplicate List
        MenuItemButton(
          child: const Text("Duplicate List"),
          onPressed: () async {

            //! Could change it to somethiing like an customSelect: "SELECT TOP 1 * FROM todo_lists ORDER BY ID DESC"
            //! which will choose the last item in the db.

            // create new list
            await db.into(db.todoLists).insert(TodoListsCompanion.insert(
              name: Value("${widget.title}(copy)"),
              position: widget.userPos!, 
            ));

            // find the new list id
            final newList = await (db.select(db.todoLists)
                ..orderBy([(l) => OrderingTerm.desc(l.id)])
                ..limit(1))
                .getSingleOrNull();

            // just in case it comes back null           
            if (newList == null) return print("error: no list found");

            // call the function to copy tasks to new list id.
            await db.copyingTasksToList(
              fromListID: widget.listID,
              toListID: newList.id,
            );
            
          },
        ),


        //! DEV: Remove leftover tasks 
        // commonMenuItem(title: "DEV: Delete leftover tasks",
        // onTap: () async {
        //   await (db.delete(db.tasks)..where((task) => task.listsId.equals(33))).go();
        // }
        // ),

        //! DEV: Remove all user lists
        // commonMenuItem(
        //   title: "DEV: Delete All User Lists",
        //   onTap: () async {
        //     await (db.delete(db.todoLists)..where((list) => list.id.isBiggerThanValue(3))).go();
        //   }
        // ),

        Divider(),

        // Remove List
        MenuItemButton(
          child: Text("Delete List"),
          onPressed: () async {

            // TODO: call db - should I delete or add it to history? Undo in case you regret or change your mind. 

            showDialog(
              context: context,
              builder: (BuildContext context) {
                //! Issue: need to style it
                return AlertDialog(
                  title: Text("You want to delete: ${widget.title}?"),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5)
                        )
                      ),
                      onPressed: () async {

                        // choose to switch to nearest user list first if available if not then Tasks tab(3) 
                        final availableLists = await (db.select(db.todoLists)
                        ..where((list) => list.id.isBiggerThanValue(3))
                        ..orderBy([(list) => OrderingTerm.asc(list.id)]))
                        .get();


                        TodoList? targetTabIndex;

                        if (availableLists.isNotEmpty) {
                          final currentIndex = availableLists.indexWhere((e) => e.id == widget.listID);


                          // Picks one neighbour: prefer the one after, fall back to the one before
                          final neighbour = availableLists.elementAtOrNull(currentIndex + 1) ??
                          (currentIndex > 0 ? availableLists.elementAtOrNull(currentIndex - 1) : null);


                          if (neighbour != null) {
                            targetTabIndex = neighbour;
                          }
                        }

                        
                        // If no available tab, fall back to Tasks tab(3)
                        targetTabIndex ??= TodoList(id: 3, name: "Tasks", position: 0); 


                        // Switch to an available tab/list
                        if (!mounted) return print("not mounted");
                        context.read<NavController>().setNavListNameAndIndex(targetTabIndex.name!, targetTabIndex.id);
                        Navigator.of(context).pop();


                        // Deletes list and related tasks
                        try {
                          await (db.delete(db.todoLists)..where((list) => list.id.equals(widget.listID))).go();
                          await (db.delete(db.tasks)..where((task) => task.listsId.equals(widget.listID))).go();
                        } catch (e) {
                          print("Delete failed: $e");
                        }


                      },
                      child: Text("Delete")
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(5)
                        )
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel")
                    ),
                  ],
                );
              }
            );


          },
        ),
      ],
    );
  }
}

//MARK: Main Page
//TODO maybe rename to something else, main panel? Task panel/list?
class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    this.onTap,
  });

  final Function()? onTap; //! What is this for? Am I using it? Cant seems to find it.

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool hideCompleted = false;
  

  Stream<Map<String, List<Task>>> getTaskStream(int listID, AppDB db) {
    switch (listID) {
      case SpecialLists.myDay: return db.watchMyDayTasks().map((tasks) => tasks.separateCompleted() );
      case SpecialLists.important: return db.watchStarredTasks().map((tasks) => tasks.separateCompleted() );
      default: return db.watchTasksByListId(listID).map((tasks) => tasks.separateCompleted() );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final db = context.read<AppDB>();

    final (int, String, bool) nav = context.select<NavController, (int, String, bool)>((nav) => (nav.navIndex, nav.navListName, nav.showTaskPanel));
    
    final int navIndex = nav.$1;
    final String navListName = nav.$2;
    final bool taskPanelState = nav.$3;

  
    return Expanded(
      child: CustomPanel(
        bgColorPanel: Colors.black,
        sidePanelWidth: null,
        topBar: Column(
          children: [
            Row(
              children: [
                Icon(Icons.home),
                
                //TODO: add a onHover effect. Shows that it is selectable
                // ID from database > 3 == user lists.
                if (navIndex > 3)
                  TitleField(
                    inputValue: navListName,
                    selectAllOnFocus: true,
                    onChange: (newName) async {
                      
                      // Update NavController variable - currentListName
                      context.read<NavController>().setListName(newName);

                      // Update the db with the new list name.
                      await db.updateList(
                        navIndex,
                        name: Value(newName),
                      );

                    },
                  )
                else 
                  Text(
                    navListName,
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                


                Spacer(),
                Icon(Icons.swap_vert),
                Icon(Icons.lightbulb),
                //TODO: Very slow, how can I fix it? I guess make my own no need to make it complicated, just a window and a list of items.
                //try overriding the animation for this widget, is that even possible?
                DropdownButton2(
                  customButton: const Icon(
                    Icons.more_vert
                  ),
                  onChanged: (value) {
                    
                  },
                  items: [
                    DropdownMenuItem(
                      onTap: () {
                        setState(() {
                          //TODO: find current todoList id
                          //TODO: DELETE list from database + update ui
                          // widget.database.delete();
                        });
                      },
                      child: Text("Delete List"),
                    )
                  ],
                  //TODO: Finish the styling
                  dropdownStyleData: DropdownStyleData(
                    width: 160,
                  ),
                )
              ],
            ),
            if (navIndex == 1) Text("Current Date"), //TODO: Change to actual current Date and change when it's an new day
          ],
        ),
        bottomBar: AddTask(
          onSubmitted: (title) async {
        
            await db.tasks.count().get().then((value) async {
              
              //! Issue?: (test)position value being equal to the last item in db when adding a new one
              //! if deleting a task and then adding back again. 
              // task 1 pos 1000 | task 2 pos 2000 | task 3 pos 3000 |
              // tasks: 3 total > delete task 2 > 2 total > add > 3 total
              // task 1 pos 1000 | task 3 pos 3000 | task 4 pos 3000
              //! Will this be a problem? Need to test this. I dont think so and depends on how
              //! I retrieve them. Is it ordered by ID and then have to sort according to pos. That would be great.
              final size = value[0];
              final pos = size > 0 ? size * 1000 : 1000;
                
              await db.insertTask(
                title: title,
                listID: navIndex < SpecialLists.tasks ? SpecialLists.tasks : navIndex,
                addedToMyDay: navIndex == SpecialLists.myDay ? true : false,
                isStarred: navIndex == SpecialLists.important ? true : false,
                position: pos,
              );
            },
            onError: (e) {
              print("Add task error: $e");
            }
            );
        
          },
        ),
        //MARK: Task items
        child: Material(
          type: MaterialType.transparency,
          child: StreamBuilder(
            stream: getTaskStream(navIndex, db),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }

              final Map<String, List<Task>> data = snapshot.data ?? {};

              if (data.isEmpty) {
                return Center(
                  child: Text(
                    "No tasks found. Add tasks to the list!",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    ),
                );
              }

              final List<Task> dataTasks = data["tasks"] ?? [];
              final List<Task> dataCompletedTasks = data["completedTasks"] ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      onReorder: (oldIndex, newIndex) {
                        
                      },
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: math.max(0, dataTasks.length * 2 - 1),
                      itemBuilder: (context, index) {
                      
                        final key = GlobalKey();

                        // Separator between the tasks
                        if (index.isOdd) {
                            return SizedBox(key: key, height: 8,);
                        }

                        final itemIndex = index ~/2;
                        final Task task = dataTasks[itemIndex];
                        final bool isSelected = context.watch<NavController>().currentTaskID == task.id;


                
                        return TaskListItem(
                          key: key,
                          task: task,
                          isSelected: isSelected,
                          taskPanelState: taskPanelState,
                          db: db,
                        );
                      },

                    ),
                    //TODO: Need to remember if to hide or show completed per list. Save to user settings(will have that later)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            hideCompleted = !hideCompleted;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //! ISSUE: Remove the gap before the icon
                            Icon(hideCompleted ? Icons.keyboard_arrow_down_outlined :  Icons.keyboard_arrow_right_outlined),
                            Text("Completed ${dataCompletedTasks.length}"),
                          ],
                        ),
                      ),
                    ),
                    //! BUG: why is it flickering when unchecking tasks? (Notion:BUG)
                    Visibility(
                      visible: hideCompleted,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: dataCompletedTasks.length,
                        itemBuilder: (context, index) {
                        
                          final Task task = dataCompletedTasks[index];
                          final bool isSelected = context.watch<NavController>().currentTaskID == task.id;

                        
                          return TaskListItem(
                            task: task,
                            isSelected: isSelected, 
                            taskPanelState: taskPanelState,
                            db: db,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 8,);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}



//MARK: Task List Item
class TaskListItem extends StatefulWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.isSelected,
    required this.taskPanelState,
    required this.db,
    });

  final Task task;
  final bool isSelected;
  final bool taskPanelState;
  final AppDB db;
  

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {

  bool hovered = false;

  final MenuController _menuController = MenuController();
  
  final MenuController _moveTaskSubMenuController = MenuController();
  final MenuController _copyTaskSubMenuController = MenuController();
  
  final FocusNode _moveTaskSubMenuFocusNode = FocusNode();
  final FocusNode _copyTaskSubMenuFocusNode = FocusNode();

  List<TodoList> copyToList = [];
  List<TodoList> moveToList = [];

  @override
  Widget build(BuildContext context) {


    return MenuAnchor(
      controller: _menuController,
      builder: (context, controller, child) {
        return GestureDetector(
          onSecondaryTapDown: (details) {
            _menuController.open(position: details.localPosition);
          },
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                hovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                hovered = false;
              });
            },
            child: Container(
              color: widget.isSelected && widget.taskPanelState ? Colors.grey.shade700 : 
              hovered ? Colors.grey.shade800 : Colors.grey.shade900,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Checkbox(       
                      value: widget.task.isDone,
                      hoverColor: Colors.transparent, //! not really working for the icon inside.
                      splashRadius: 0,
                      focusColor: Colors.transparent,
                      onChanged: (value) async {
                        
                        await widget.db.updateTask(
                          widget.task.id, 
                          isDone: Value(value!),
                        );
                        
                      }
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                    
                        context.read<NavController>().toggleRightPanel(
                          state: !widget.taskPanelState,
                          taskID: widget.task.id,
                        );
                            
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          // Title
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            // padding: const EdgeInsets.fromLTRB(240, 16, 0, 16),
                            child: Text(
                              widget.task.title,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // Subtitles 
                          Row(
                            //TODO: fix the gap between the subtitles.
                            children: [
                              
                              // Nav List Name
                              Text(
                                "${widget.task.listsId}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              
                              //TODO: Need an more inituitive way to implement the divider, maybe I should use an indexbuilder.
                              //Divider
                              Icon(Icons.circle_rounded, size: 4, color: Colors.white),

                              // Subtitle - Due Date 
                              //TODO: an calendar icon as well
                              if (widget.task.dueDate != null)
                              Text(
                                "${widget.task.dueDate}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Subtitle - Repeat
                              Icon(Icons.repeat_outlined, size: 16, color: Colors.white,),
                              
                              // Subtitle - Reminder 
                              Icon(Icons.notifications_none_outlined, size: 16, color: Colors.white),

                              // Subtitle - Notes 
                              Icon(Icons.note_outlined, size: 16, color: Colors.white),

                              // Subtitle - Tags 
                            ],
                          ),
                  
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: Colors.white,
                    
                  ),
                ],
              ),
            ),
          ),
        );
      },

      //MARK: Task menuanchor - options
      menuChildren: [
        
        // Add to My day (copy task to here I guess) (If created in my day tab then copy it to Tasks as well)
        MenuItemButton(
          leadingIcon: Icon(Icons.wb_sunny_outlined),
          onPressed: () async {

            await widget.db.updateTask(
              widget.task.id, 
              addedToMyDay: Value(true)
            );

          },
          child: const Text("Add to My Day")
        ),

        // Mark as Important (copy task)
        //! Issue: Might need another column in DB for Important.
        MenuItemButton(
          leadingIcon: Icon(Icons.star_border),
          onPressed: () async {
            
            await widget.db.updateTask(
              widget.task.id,
              isStarred: Value(true),
            );
          },
          child: const Text("Mark as Important")
        ),

        // Mark as completed
        MenuItemButton(
          leadingIcon: Icon(Icons.check_circle_outline_outlined),
          onPressed: () async {
            await widget.db.updateTask(
              widget.task.id,
              isDone: Value(!widget.task.isDone!)
            );
          },
          child: Text("Mark as ${ widget.task.isDone! ?"Not Completed" : "Completed"}")
        ),
        
        Divider(),
        
        // Due Today - Add todays date and add to myday
        MenuItemButton(
          leadingIcon: Icon(Icons.today_outlined),
          onPressed: () async {

            final taskDate = widget.task.dueDate;
            final today = DateTime.now();
            
            if (taskDate != null && taskDate.day == today.day) return;

            await widget.db.updateTask(
              widget.task.id,
              addedToMyDay: Value(true),
              dueDate: Value(today),
            );
            
          },
          child: const Text("Due Today")
        ),

        // Due Tomorrow - Add tomorrows date
        MenuItemButton(
          leadingIcon: Icon(Icons.next_week_outlined),
          onPressed: () async {

            final taskDate = widget.task.dueDate;
            final DateTime tomorrow = DateTime.now().add(Duration(days: 1));

            if (taskDate != null && taskDate.day == tomorrow.day) return;

            await widget.db.updateTask(
              widget.task.id,
              dueDate: Value(tomorrow),
            );
          },
          child: const Text("Due Tomorrow")
        ),

        // Remove Due Date - show if due date exist
        if (widget.task.dueDate != null)
        MenuItemButton(
          leadingIcon: Icon(Icons.event_busy_outlined),
          onPressed: () async {
            
            final taskDate = widget.task.dueDate;
            final today = DateTime.now();

            // remove from myday if due date is today else leave it
            final removeFromMyDay = taskDate!.day == today.day ? Value(false) : null;

            //! what kind of behaviour do I want?
            /*
            * Remove it regardless?
            * (For now) Remove it from myday only if the due date is the same as today.
            * Popup that ask if you want to remove it from myday as well if its in there.
            */


            await widget.db.updateTask(
              widget.task.id,
              addedToMyDay: removeFromMyDay,
              dueDate: Value(null)
            );

          },
          child: const Text("Remove Due Date")
        ),

        
        Divider(),
        
        // Create new list from this task - create new list then move the task to it.
        MenuItemButton(
          leadingIcon: Icon(Icons.format_list_bulleted_add),
          onPressed: () {},
          child: const Text("Create new list from this task")
        ),

        // Move task to..  - show a list of lists to move to.
        //TODO: on hover and hold for 3-5 seconds open list.
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) _moveTaskSubMenuController.close();
          },
          child: MenuAnchor(
            controller: _moveTaskSubMenuController,
            childFocusNode: _moveTaskSubMenuFocusNode,
            builder: (context, controller, child) {
              return MouseRegion(
                onEnter: (event) => _moveTaskSubMenuFocusNode.requestFocus(),
                child: TextButton(
                  focusNode: _moveTaskSubMenuFocusNode,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(0)
                    ),
                    padding: EdgeInsetsDirectional.only(start: 4, end: 8),
                    visualDensity: VisualDensity(vertical: 0.5),
                  ),
                  onPressed: () async {
                    moveToList = await (widget.db.select(widget.db.todoLists)..where((list) => list.id.isBiggerOrEqualValue(3))).get();
                    setState(() {
                      controller.isOpen ? controller.close() : _moveTaskSubMenuController.open();
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.move_up_outlined, size: 24),
                      const Text("  Move task to.. "),
                      SizedBox(width: 60),
                      const Icon(Icons.arrow_right_outlined, size: 24),
                    ],
                  ),
                ),
              );
            },
            menuChildren: [
              //TODO: populate with db lists
              // List of tabs to choose

              for (var list in moveToList) 
              if (list.id != widget.task.listsId) MenuItemButton(
                onPressed: () async {
                  
                  await widget.db.updateTask(
                    widget.task.id,
                    listID: Value(list.id),
                  );

                },
                child: Text("${list.name}"),
              ),

            ],
          ),
        ),

        // Copy task to..  - show a list of lists to copy to.
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) _copyTaskSubMenuController.close();
          },
          child: MenuAnchor(
            controller: _copyTaskSubMenuController,
            childFocusNode: _copyTaskSubMenuFocusNode,
            builder: (context, controller, child) {
              return MouseRegion(
                onEnter: (event) => _copyTaskSubMenuFocusNode.requestFocus(),
                child: TextButton(
                  focusNode: _copyTaskSubMenuFocusNode,
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(0)
                    ),
                    padding: EdgeInsetsDirectional.only(start: 4, end: 8),
                    visualDensity: VisualDensity(vertical: 0.5),
                  ),
                  onPressed: () async {

                    copyToList = await (widget.db.select(widget.db.todoLists)..where((list) => list.id.isBiggerOrEqualValue(3))).get();
                    setState(() {
                      controller.isOpen ? controller.close() : _copyTaskSubMenuController.open();
                    });
                    
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(Icons.copy, size: 24),
                      const Text("  Copy task to.. "),
                      SizedBox(width: 60),
                      const Icon(Icons.arrow_right_outlined, size: 24),
                    ],
                  ),
                ),
              );
            },
            menuChildren: [
              //TODO: populate with db lists
              // List of tabs to choose

              for (var list in copyToList) MenuItemButton(
                onPressed: () async {
                  
                  await widget.db.copyTaskToList(
                    taskID: widget.task.id,
                  );

                },
                child: Text("${list.name}"),
              ),

            ],
          ),
        ),
        
        Divider(),
        // Delete task
        MenuItemButton(
          style: ButtonStyle(
            splashFactory: NoSplash.splashFactory,
          ),
          leadingIcon: Icon(Icons.delete_outline),
          onPressed: () {
            
            //TOOD: Make this into a widget/function
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text("You want to delete: ${widget.task.title}?", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.grey.shade900,
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(4)
                        ),
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        final AppDB db = widget.db;

                        context.read<NavController>().toggleRightPanel(
                          state: false,
                        );

                        Navigator.of(context).pop();
                        
                        try {
                          await (db.delete(db.tasks)..where((task) => task.id.equals(widget.task.id))).go();
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(4)
                        ),
                        backgroundColor: Colors.grey
                      ),
                      onPressed: () {

                        Navigator.of(context).pop();

                      },
                      child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                    ),
                  ],
                );
              }
            );

          },
          child: Text("Delete Task")
        ),
      ],
    );
  }
}