import 'dart:ffi';

import 'package:drift/drift.dart' hide Column;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:todo_app/components/add_task_field.dart';
import 'package:todo_app/components/right_sidepanel.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/navigation_panel.dart';


// TODO: need to make it faster when switching between lists/tabs. Probably because of the loading everytime.
// TODO: why does the tasks in the database need to have a list id?
// TODO: switch to riverpod later - manually passing to everywidget > riverpod

void main() async {
  final db = AppDB();
  runApp(MyApp(database: db));
  
}

class MyApp extends StatelessWidget {
  final AppDB database;

  const MyApp({super.key, required this.database});



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
  int selectedIndex = 0;

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
class RightSidePanel2 extends StatefulWidget {
  const RightSidePanel2({
    super.key,
    required this.database,
    this.showPanel = false,
    this.btnHidePanel,
    this.deleteTask,
  });

  final AppDB database;
  final bool showPanel;
  final VoidCallback? btnHidePanel;
  final VoidCallback? deleteTask;

  @override
  State<RightSidePanel2> createState() => _RightSidePanel2State();
}

class _RightSidePanel2State extends State<RightSidePanel2> {
  @override
  Widget build(BuildContext context) {
    return RightSidePanel(
      database: widget.database,
      show: widget.showPanel,
      sidePanelWidth: 340,
      bottomBar: PanelBottomBar( //! Do I need this to be a separate widget? Probably not
        hidePanel: () {
            widget.btnHidePanel!.call();

            //! THIS WORKS (Below)
            widget.database.into(widget.database.todoLists).insert(TodoListsCompanion.insert(name: Value("userTestList3")));
            
        },
        deleteTask: () { 
          //! Maybe remove this and just do this inside the file/widget, no need for a parameter.
          widget.deleteTask!.call();
        }
      ),
      child: TaskInfo(
      ),
    );
  }
}


//MARK: Nav Panel
class NavigationPanel2 extends StatefulWidget {
  const NavigationPanel2({
    super.key,
    required this.database,
    required this.currentIndex, required Null Function(int) handleTabTap,
  });

  final Function(int) currentIndex;

  final AppDB database;

  @override
  State<NavigationPanel2> createState() => _NavigationPanel2State();
}

class _NavigationPanel2State extends State<NavigationPanel2> {

  int _selectedIndex = 2;

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
                    _selectedIndex = 0;
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
                    _selectedIndex = 1;
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
                    _selectedIndex = 2;
                    widget.currentIndex(2);
                    
                  });
                },
              ),
              Divider(),
              //MARK: User Lists
              //TODO: Change to a StreamBuilder
              //! Loading too fast? Need to wait for the get_lists function to grap first before loading.
              //TODO: If !snapshot.hasData > progress indicator else.
              // if (snapshot.hasData) CircularProgressIndicator(color: Colors.white), //! Works but needs a stream to track.
              StreamBuilder(
                // stream: db.select(db.todoLists).watch(),
                stream: null,
                builder: (context, snapshot) {

                  print(snapshot.data);
                                    

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
                            _selectedIndex = userIndex;
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

  int _taskList = 5; //TODO: grap from database/navpanel? Change name as well?

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
                    _taskList += 1;
                    //TODO: Make UI changes then update database or update database then change ui.
                  });
                },
              ),
              child: Material(
                type: MaterialType.transparency,
                child: ListView.separated(
                  itemCount: _taskList,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.grey.shade900,
                      hoverColor: Colors.grey.shade800,
                      splashColor: Colors.transparent,
                      title: Text("Task $index"),
                      onTap: () {
                        setState(() {
                          // TODO: if showpanel true and tap again > close showpanel else if different task tap change taskinfo
                          // if (showPanel == true && index == )
                          showPanel = !showPanel;
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 8,);
                  },
                ),
              ),
            ),
          ),
          
          RightSidePanel2(
            database: widget.database, 
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
        ],
      ),
    );
  }
}

