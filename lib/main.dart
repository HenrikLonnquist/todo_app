import 'package:drift/drift.dart' hide Column;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/components/add_task_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/navigation_panel.dart';


// TODO: need to make it faster when switching between lists/tabs. Probably because of the loading everytime.
// TODO: why does the tasks in the database need to have a list id?
// TODO: switch to riverpod later - manually passing to everywidget > riverpod

void main() async {
  runApp(
    Provider<AppDB>(
      create: (_) => AppDB(),
      dispose: (_, db) => db.close(),
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
      home: ParentPage(
        database: database,
      ),
    );
  }
}

class ParentPage extends StatefulWidget {
  const ParentPage({
    super.key,
    required this.database,
  });

  final AppDB database;

  @override
  State<ParentPage> createState() => _ParentPageState();
}

class _ParentPageState extends State<ParentPage> {

  final bool showLeftPanel = true;
  int selectedIndex = 2; 

  AppDB get db => widget.database;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavigationPanel2(
            //! Better to handle the updates and changes here, no need to send widget.database to it.
            database: widget.database,
            selectedIndex: selectedIndex,
            handleTabTap: (tabId) {
              //TODo: what tap was pressed and then send the info to mainpage

              // db.select().get();


            },
            currentIndex: (index) {
              // 0 = Myday
              // 1 = Important
              // 2 = Tasks
              // db.      

              setState(() {
                selectedIndex = index;
              });
            },
          ),
          MainPage(
            database: widget.database, //TODO: replace/change to the current selected NavPanel(list > Myday,Tasks..) 
            selectedIndex: selectedIndex,
          ),
        ]
      )
    );
  }
}


//MARK: true right sidepanel
//! Why did I do this?
//TODO: Can I remove or refactor
class RightSidePanel2 extends StatefulWidget {
  const RightSidePanel2({
    super.key,
    required this.task,
    this.subTask,
    this.showPanel = false,
    this.btnHidePanel,
    this.deleteTask,
  });

  final Map task;
  final List? subTask;
  final bool showPanel;
  final VoidCallback? btnHidePanel;
  final VoidCallback? deleteTask;

  @override
  State<RightSidePanel2> createState() => _RightSidePanel2State();
}

class _RightSidePanel2State extends State<RightSidePanel2> {
  @override
  Widget build(BuildContext context) {

    // print("right: ${widget.subTask}");

    // TODO: Merge this with TaskInfo Class?
    return RightSidePanel(
      show: widget.showPanel,
      sidePanelWidth: 340,
      bottomBar: PanelBottomBar( //! Do I need this to be a separate widget? Probably not
        hidePanel: () {
            widget.btnHidePanel!.call();
              
            widget.task;
            
        },
        deleteTask: () { 
          //! Maybe remove this and just do this inside the file/widget, no need for a parameter.
          widget.deleteTask!.call();
        }
      ),
      child: TaskInfo(
        task: widget.task,
        subTask: widget.subTask,
      ),
    );
  }
}


//MARK: Nav Panel
class NavigationPanel2 extends StatefulWidget {
  const NavigationPanel2({
    super.key,
    required this.database,
    required this.currentIndex, 
    required Null Function(int) handleTabTap,
    required this.selectedIndex,
  });

  final int selectedIndex;
  final Function(int) currentIndex;

  final AppDB database;

  @override
  State<NavigationPanel2> createState() => _NavigationPanel2State();
}

class _NavigationPanel2State extends State<NavigationPanel2> {

  int get _selectedIndex => widget.selectedIndex;

  // List _userList = []; //TODO: Dont forget to change.
  int _userListCount = 0;


  //TODO: grap database todoLists
  AppDB get db => widget.database;

  void get_Lists() async {

    final query = await db.select(db.todoLists).get();

    //! INSERT, UPDATE, DELETE ---> Use 'custom...'/raw sql | but when SELECT(returning values/graping) use .select drift
    // db.customStatement("DELETE FROM todo_lists WHERE id = ?", [7]);

    _userListCount = (query.length - 1).abs() ;
    print(_userListCount);

    for (final row in query) {
      print("Has row $row");
    }

  }  

  @override
  Widget build(BuildContext context) {

    // get_Lists();

    return RightSidePanel(
      database: widget.database,
      show: true, // TODO: have a button if you want to hide/show the panel
      sidePanelWidth: 220,
      padding: null,
      bottomBar: Material(
        type: MaterialType.transparency,
        child: ListTile(
          title: Text("New list +"),
          hoverColor: Colors.grey.shade800,
          onTap: () {
            //TODO: Have the parent handle this. Or where its called/used.
            //TODO: Create a new user list and add to database
            
              db.into(db.todoLists).insert(TodoListsCompanion.insert(name: Value("Untitled list")));
            
          },
        ),
      ),
      child: SingleChildScrollView(
        child: Material(
          type: MaterialType.transparency,
          //TODO: initialize database - try to get the database
          child: Column(
            children: [
              ListTile(
                hoverColor: Colors.grey.shade800,
                selected: 0 == _selectedIndex,
                splashColor: Colors.transparent,
                title: Text(
                  "My Day",
                ),
                onTap: (){
                  setState(() {
                    // _selectedIndex = 0;
                    widget.currentIndex(0);
                    
                  });
                },
              ),
              ListTile(
                hoverColor: Colors.grey.shade800,
                selected: 1 == _selectedIndex,
                splashColor: Colors.transparent,
                title: Text(
                  "Important",
                ),
                onTap: (){
                  setState(() {
                    // _selectedIndex = 1;
                    widget.currentIndex(1);
                    
                  });
                },
              ),
              ListTile(
                hoverColor: Colors.grey.shade800,
                selected: 2 == _selectedIndex,
                splashColor: Colors.transparent,
                title: Text(
                  "Tasks",
                ),
                onTap: (){
                  setState(() {
                    // _selectedIndex = 2;
                    widget.currentIndex(2);
                    
                  });
                },
              ),
              Divider(),
              //MARK: User Lists
              //TODO: Change to a StreamBuilder or FutureBuilder(?, same as in Main Page Class)
              //TODO: Look up how to use StreamBUilder.
              //! Loading too fast? Need to wait for the get_lists function to grap first before loading.
              //TODO: If !snapshot.hasData > progress indicator else.
              // if (snapshot.hasData) CircularProgressIndicator(color: Colors.white), //! Works but needs a stream to track.
              StreamBuilder(
                // stream: db.select(db.todoLists).watch(),
                stream: null,
                builder: (context, snapshot) {

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _userListCount, 
                    itemBuilder: (context, index) {
                      
                      final userIndex = 3 + index; // 3 = default lists(MyDay, Important, Tasks)

                      return ListTile(
                        hoverColor: Colors.grey.shade800,
                        selected: userIndex == _selectedIndex,
                        splashColor: Colors.transparent,
                        title: Text(
                          "test$index",
                        ),
                        onTap: (){
                          setState(() {
                            // _selectedIndex = userIndex;
                            widget.currentIndex(userIndex);
                          });
                        },
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
    required this.database,
    this.onTap,
    required this.selectedIndex,
  });

  final AppDB database;
  final Function()? onTap;
  final int selectedIndex;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  bool showPanel = false;

  int get _taskList => widget.selectedIndex; //TODO: grap from database/navpanel? Change name as well?
  AppDB get db => widget.database;
  // SimpleSelectStatement<Tasks, Task> get currentTabTasks => db.select(db.tasks)..where((tbl) => tbl.listsId.equals(widget.selectedIndex));
  Future<List<QueryRow>> get currentTabTask => db.customSelect("SELECT * FROM tasks WHERE lists_id = ? AND parent_id IS null", 
    variables: [
      Variable.withInt(widget.selectedIndex),
    ], 
    readsFrom: {db.tasks}).get();
  
  
  Map currentTask = {};
  List currentSubTask = [];


  Future<List<QueryRow>> getSubTasks(int parentId) {

    return db.customSelect("SELECT * from tasks WHERE parent_id = ?",
    variables: [
      Variable.withInt(parentId),
    ],
    readsFrom: {db.tasks}).get();

  } 

  //TODO: Task-tile is flickers when pressed.
  //! could be because of the refreshing the UI from setstate. Which means I might need to 
  //! separate from them to only refresh that class. Can't be in the same class/widget.

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RightSidePanel(
              database: widget.database,
              bgColorPanel: Colors.black,
              sidePanelWidth: null,
              topBar: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.home),
                      Text("Main Page ${widget.selectedIndex}"),
                      Spacer(),
                      Icon(Icons.swap_vert),
                      Icon(Icons.lightbulb),
                      //! Very slow, how can I fix it?
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
                  // Text("Current Date"), //TODO: If it's 'My Day' tab. show this
                ],
              ),
              bottomBar: AddTask(
                onSubmitted: (value) {
                  setState(() {
                    // _taskList += 1;
                    
                    db.customInsert("INSERT INTO tasks(lists_id, title, position) VALUES (?, ?, ?)", 
                    variables: [
                      Variable.withInt(widget.selectedIndex), 
                      Variable.withString(value), 
                      Variable.withInt(0)
                    ]);
    
                    //TODO: Make UI changes then update database or update database then change ui.
                  });
                },
              ),
              child: FutureBuilder(
                future: currentTabTask,
                builder: (context, snapshot) {
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                  }

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
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                      
                        // TODO: Need a if/else statement to filter out subtasks.
                        final task = snapshot.data![index].data;
                        final taskTitle = task["title"];
                        // print("Listview(TASKS) $task");
                        // print(taskTitle);
                      

                      
                        return ListTile(
                          tileColor: Colors.grey.shade900,
                          hoverColor: Colors.grey.shade800,
                          splashColor: Colors.transparent,
                          title: Text(taskTitle),
                          onTap: () async {
                      
                            currentSubTask = await getSubTasks(task["id"]); //! Is this bad? Why is it bad?
                      
                            setState(() {
                              // TODO: if showpanel true and tap again > close showpanel else if different task tap change taskinfo
                              
                              if (showPanel == true && currentTask["id"] == task["id"]) {
                                showPanel = false;
                              }
                              else {
                                showPanel = true;
                                
                              }
                              currentTask = task;
                              
                      
                            });
                          },
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
          //TODO: Maybe move this to parent Widget(MAIN). WHy? Because I need to hide this when I open a new "Tab"/List
          RightSidePanel2(
            task: currentTask, 
            subTask: currentSubTask,
            showPanel: showPanel,
            btnHidePanel: () {
              setState(() {
                showPanel = false;
              });
            },
            deleteTask: () {
              // widget.database.into(widget.database.tasks);
    
            },
          ),
          //MARK: Suggestion Panel
          //TODO: Suggetsion Panel -- Move to parent widget(MAIN)?
        ],
      ),
    );
  }
}

