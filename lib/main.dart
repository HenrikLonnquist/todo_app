import 'dart:ffi';
import 'dart:math';

import 'package:drift/drift.dart' hide Column;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/components/add_task_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/nav_controller.dart';
import 'package:todo_app/navigation_panel.dart';


// TODO: need to make it faster when switching between lists/tabs. Probably because of the loading everytime.
//!Question: why does the tasks in the database need to have a list id?
// TODO: switch to riverpod later - manually passing to everywidget > riverpod

void main() async {
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

  final bool showLeftPanel = true;
  
  // int selectedIndex = 2;


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


  dynamic commonListTile({
    required int index, 
    required int selectedIndex,
    required String title,
    GlobalKey? itemKey,
    bool isUserList = false,
    }) {

      return GestureDetector(
        key: itemKey,
        onSecondaryTapDown: !isUserList ? null : (detail) async {
          final offset = detail.globalPosition;
          
          // TODO: might wanna create something my own. Can't really customize this as much.
          //! Not able to right click another item while menu is showing. You can do this in MS Todo tho.
          showMenu(
            menuPadding: EdgeInsets.all(0),
            color: Colors.grey.shade800,
            context: context,
            position: RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              MediaQuery.of(context).size.width - offset.dx,
              MediaQuery.of(context).size.height - offset.dy,
            ),
            popUpAnimationStyle: AnimationStyle(duration: Duration(milliseconds: 5)),
            items: [
              // Rename list
              PopupMenuItem(
                mouseCursor: SystemMouseCursors.basic,
                child: Text("item 1")
              ),

              // Share List
              PopupMenuItem(
                child: Text("item 2")
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
                child: Text("item 3")
              ),
              
              // Print List
              PopupMenuItem(
                child: Text("item 4")
              ),
              
              // Email List
              PopupMenuItem(
                child: Text("item 5")
              ),
              
              // Pin start
              PopupMenuItem(
                child: Text("item 6")
              ),
              
              // Duplicate List
              PopupMenuItem(
                child: Text("item 7")
              ),
              
              // Remove List
              PopupMenuItem(
                mouseCursor: SystemMouseCursors.basic,
                onTap: () {
                  // TODO: call db - should I delete or add it to history? 
                  // Obviouisly we need a popup that asks to confirm deletion.
                  // Then a snackbar message that tells user that it got deleted, but still got a chance to 
                  // undo before the snackbar message goes away.


                },
                // child: Text("item 8")
                child: ListTile(
                  title: Text("Delete list"),
                  onTap: () async {
                    final db = context.read<AppDB>();
                    await (db.delete(db.todoLists)..where((t) => t.id.equals(index))).go();

                  },
                ),
              ),
            ],
            
          );
          
        },
        //! HIDE OR Show no info when the object is being dragged.
        child: ListTile(
          mouseCursor: SystemMouseCursors.basic,
          hoverColor: Colors.grey.shade800,
          selected: index == selectedIndex,
          splashColor: Colors.transparent,
          title: Text(
            title,
          ),
          onTap: (){
            setState(() {
              context.read<NavController>().setindex(index);
              
            });
          },
        ),
      );
    
  }


  //MARK: Nav tab
  @override
  Widget build(BuildContext context) {

    final db = context.read<AppDB>();
    final selectedIndex = context.select<NavController, int>((i) => i.index);

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
      child: SingleChildScrollView(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [

              commonListTile(title: "My Day", index: 0, selectedIndex: selectedIndex),
              commonListTile(title: "Important", index: 1, selectedIndex: selectedIndex),
              commonListTile(title: "Tasks", index: 2, selectedIndex: selectedIndex),
              
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
                      final itemKey = GlobalKey();

                      return commonListTile(
                        itemKey: itemKey,
                        title: userList.name!, 
                        index: userList.id, 
                        selectedIndex: selectedIndex,
                        isUserList: true,
                      );
                    },
                  );
                }
              ),
            ]
          ),
        ),
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

  final Function()? onTap;
  // final int selectedListIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool showPanel = false;

  int currentTask = 0;
  

  @override
  Widget build(BuildContext context) {

    final db = context.read<AppDB>();
    final navIndex = context.select<NavController, int>((i) => i.index);

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: CustomPanel(
              bgColorPanel: Colors.black,
              sidePanelWidth: null,
              topBar: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.home),
                      Text("Main Page $navIndex"), //TODO Change to titlefield
                      Spacer(),
                      Icon(Icons.swap_vert),
                      Icon(Icons.lightbulb),
                      //TODO: Very slow, how can I fix it? I guess make my own no need to make it complicated, just a window and a list of items.
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
                  if (navIndex == 0) Text("Current Date"), //TODO: Change to actual current Date and change when it's an new day
                ],
              ),
              bottomBar: AddTask(
                onSubmitted: (title) async {

                  await db.tasks.count().get().then((value) async {
                    
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
              child: StreamBuilder(
                stream: db.watchTasksByListId(navIndex),
                builder: (context, snapshot) {

                  // debugPrint(
                  //   'StreamBuilder rebuild — '
                  //   'hasData=${snapshot.hasData} '
                  //   'len=${snapshot.data?.length} '
                  //   'connectionState=${snapshot.connectionState}',
                  // );
                  
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

                  return Material(
                    type: MaterialType.transparency,
                    child: ListView.separated(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                      
                        final task = data[index];
                        final taskTitle = task.title;
                      
                        return ListTile(
                          mouseCursor: SystemMouseCursors.basic,
                          tileColor: Colors.grey.shade900,
                          hoverColor: Colors.grey.shade800,
                          splashColor: Colors.transparent,
                          title: Text(taskTitle),
                          onTap: () {
                      
                            setState(() {
                              
                              if (showPanel == true && currentTask == task.id) {
                                showPanel = false;
                              }
                              else {
                                showPanel = true;
                              }

                              //! WOuld adding this to navcontroller be too much? same for showpanel.
                              currentTask = task.id;
                      
                            });
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.dangerous),
                            onPressed: () {
                              
                              //TODO: have a popup in case of one wants to undo it. Or just add it to history list.
                              (db.delete(db.tasks)..where((t) => t.id.equals(task.id) | t.parentId.equals(task.id))).go();
                              
                            },
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 8,);
                      },
                    ),
                  );
                }
              ),
            ),
          ),
          //MARK: Right Side Panel
          //TODO: Move this to Parent Page(mark: MAIN?)
          //TODO: put this inside of 'Task Info' class? Need the task stuff from it.
          TaskInfo(
            taskId: currentTask,
            showPanel: showPanel, 
          ),
          //MARK: Suggestion Panel
          //TODO: Suggetsion Panel -- Move to parent widget(MAIN)?
          // Should I show it on top of a current panel if it's open? No, I just want it to switch between them regardless of state
          //! but they can't share the same 'showPanel' variable. I think that will conflict with each other. 
        ],
      ),
    );
  }
}

