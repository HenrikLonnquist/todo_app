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
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.grey.shade700.withValues(alpha: 0.5),
          selectedColor: Colors.white,
          textColor: Colors.white,
          
        )
      ),
      // home: NavigationPanel(database: database),
      //MARK: MAIN?
      home: ParentPage(),
      
    );
  }
}

//! Is this necessary? Maybe remove.
class ParentPage extends StatefulWidget {
  const ParentPage({
    super.key,
  });

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
              int lastPos = size > 0 ? size * 1000 : 1000; 
            
              await db.into(db.todoLists).insert(TodoListsCompanion.insert(name: Value("Untitled list ${size + 1}"), position: Value(lastPos)));

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
          
                  NavListTile(title: "My Day", index: 1, selectedTabIndex: selectedTabIndex, taskCount: listTaskCount[1]),
                  NavListTile(title: "Important", index: 2, selectedTabIndex: selectedTabIndex, taskCount: listTaskCount[2]),
                  NavListTile(title: "Tasks", index: 3, selectedTabIndex: selectedTabIndex, taskCount: listTaskCount[3]),
                  
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
                            index: userList.id, 
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
    required this.index,
    required this.selectedTabIndex,
    required this.title,
    this.isUserList = false,
    this.taskCount = 0,
  });


  final int index; // listId
  final int? taskCount;
  final int selectedTabIndex;
  final String title;
  final bool isUserList;

  @override
  State<NavListTile> createState() => _NavListTileState();
}

class _NavListTileState extends State<NavListTile> {

  bool listRename = false;

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

    //MARK: dropdown list
    return GestureDetector(
      key: ValueKey(widget.index),

      //* Dont worry about the delay, only happens in debug mode.
      onSecondaryTapDown: (detail) {

        if (!widget.isUserList) return; 

        final Offset offset = detail.globalPosition;

        final double dx = offset.dx;
        final double dy = offset.dy;
        
        final double width = MediaQuery.of(context).size.width;
        final double height = MediaQuery.of(context).size.height;

        
        // TODO: need a good name for this.
        //! Not able to right click another item while menu is showing. You can do this in MS Todo tho.
        //! BUG: Does not appear outside of the program, constrained to the size of the app. 

        showMenu(
          menuPadding: EdgeInsets.all(0),
          color: Colors.grey.shade800,
          context: context,
          position: RelativeRect.fromLTRB(
            dx,
            dy,
            width - dx,
            height - dy,
          ),
          popUpAnimationStyle: AnimationStyle(duration: Duration(milliseconds: 5)),
          items: [
            // Rename list
            commonMenuItem(
              title: "Rename List",
              onTap: () {

                setState(() {

                  listRename = true;

                });

              },
            ),

            // Share List
            PopupMenuItem(
              child: Text("Share List")
            ),

            //DIVIDER
            PopupMenuItem(
              height: 0,
              enabled: false,
              padding: EdgeInsets.all(0),
              child: PopupMenuDivider(),
            ),

            // Move list to... >
            PopupMenuItem(
              child: Text("Move List to... >")
            ),
            
            // Print List
            PopupMenuItem(
              child: Text("Print List")
            ),
            
            // Email List
            PopupMenuItem(
              child: Text("Email List")
            ),
            
            // Pin start
            PopupMenuItem(
              child: Text("Pin Start")
            ),
            
            // Duplicate List
            PopupMenuItem(
              child: Text("Duplicate List")
            ),
            
            // Remove List
            commonMenuItem(
              title: "Delete List",
              onTap: () async {

                // TODO: call db - should I delete or add it to history? 
                // Obviouisly we need a popup that asks to confirm deletion.
                // Then a snackbar message that tells user that it got deleted, but still got a chance to 
                // undo before the snackbar message goes away.

                //Snackbar
                //.then( delete list after confirmation)

                final db = context.read<AppDB>();
                await (db.delete(db.todoLists)..where((t) => t.id.equals(widget.index))).go();
                
              },
            ),
          ],
          
        );
        
      },
      //MARK: Nav list item
      //! HIDE OR Show no info when the object is being dragged.
      child: ListTile(
        mouseCursor: SystemMouseCursors.basic,
        hoverColor: Colors.grey.shade800,
        selected: widget.index == widget.selectedTabIndex,
        splashColor: Colors.transparent,
        // TODO: need something for indicating its in "editable mode" > dotted-line border/underscore
        // something like a lighter/dakrer background color could also work.
        title: TitleField(
          disableTextEditing: !listRename,
          onTapOutside: (event) {
        
            setState(() {
              listRename = false;
            });
        
          },
          requestFocus: listRename, // Need comment this if you dont want selectall, immediately onfocus.
          selectAllOnFocus: true, // on tap only
          inputValue: widget.title,
          textSize: 16,
          onChange: (value) async {
        
            // skip if the value has not changed.
            if (value != widget.title) {
        
              final db = context.read<AppDB>();
        
              await db.updateList(
                widget.index, //listid
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
          context.read<NavController>().setNavIndex(widget.index);

          // Change nav/list name in main page
          context.read<NavController>().setListName(widget.title);
            
        },
      ),
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

  bool editName = false;

  @override
  Widget build(BuildContext context) {

    final db = context.read<AppDB>();

    final navIndex = context.select<NavController, int>((i) => i.navIndex);
    final navListName = context.select<NavController, String>((s) => s.navListName);

    final taskPanelState = context.select<NavController, bool>((b) => b.showTaskPanel);

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
                // Show this if its an user list.
                if (navIndex > 3)
                  TitleField(
                    inputValue: navListName,
                    selectAllOnFocus: true,
                    onChange: (newName) async {
                      
                      // Update NavController variable - currentListName
                      context.read<NavController>().setListName(newName, showPanel: taskPanelState);

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
              //! Will this be a problem need to test this. I dont think so and depends on how
              //! I retrieve them. Is it ordered by ID and then have to sort according to pos. That would be great.
              final size = value[0];
              final pos = size > 0 ? size * 1000 : 1000;
                
              await db.insertTask(
                title: title,
                listID: navIndex,
                position: pos,
              );
            },
            onError: (e) {
              print("Add task error: $e");
            }
            );
        
          },
        ),
        //MARK: Task List
        child: Material(
          type: MaterialType.transparency,
          child: StreamBuilder(
            stream: db.watchTasksByListId(navIndex),
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
          
              final data = snapshot.data ?? [];
          
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
          
              return ListView.separated(
                itemCount: data.length,
                itemBuilder: (context, index) {
                
                  final Task task = data[index];
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        hovered = true;
      }),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  // padding: const EdgeInsets.fromLTRB(240, 16, 0, 16),
                  child: Text(
                    widget.task.title,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
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
    );
  }
}