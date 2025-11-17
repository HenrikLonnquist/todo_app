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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavigationPanel2(
            database: widget.database,
            currentIndex: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          MainPage(
            database: widget.database,
            selectedIndex: selectedIndex,
          ),
          RightSidePanel2(database: widget.database),

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
  });

  final AppDB database;
  final bool showPanel;

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
      bottomBar: PanelBottomBar( //! Do I need this to be a separate widget? 
        hidePanel: () {
          setState(() {
            //TODO: this doesnt work because its controlled by the parent widget(MainPage).
            // widget.showPanel = false;
          });
        },
        deleteTask: () {
    
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
    required this.currentIndex,
  });

  final Function(int) currentIndex;

  final AppDB database;

  @override
  State<NavigationPanel2> createState() => _NavigationPanel2State();
}

class _NavigationPanel2State extends State<NavigationPanel2> {

  int _selectedIndex = 0;

  int _userListCount = 5; //TODO: grap from database

  @override
  Widget build(BuildContext context) {
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
            //TODO: Create a new user list and add to database
            setState(() {
              _userListCount += 1;
              //TODO: add to database
            });
          },
        ),
      ),
      child: SingleChildScrollView(
        child: Material(
          type: MaterialType.transparency,
          //TODO: initialize database - try to get the database
          child: StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        hoverColor: Colors.grey.shade800,
                        selected: index == _selectedIndex,
                        splashColor: Colors.transparent,
                        title: Text(
                          "test$index",
                        ),
                        onTap: (){
                          setState(() {
                            _selectedIndex = index;
                            widget.currentIndex(index);
                            
                          });
                        },
                      );
                    },
                  ),
                  Divider(),
                  //MARK: User Lists
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _userListCount + 3,
                    itemBuilder: (context, index) {
                      final userIndex = 3 + index;
                            
                      return ListTile(
                        hoverColor: Colors.grey.shade800,
                        selected: userIndex == _selectedIndex,
                        splashColor: Colors.transparent,
                        title: Text(
                          "test$userIndex",
                        ),
                        onTap: (){
                          setState(() {
                            _selectedIndex = userIndex;
                            widget.currentIndex(userIndex);
                          });
                        },
                      ); 
                    },
                  ),
                ]
              );
            }
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
                      Icon(Icons.lightbulb)
                    ],
                  ),
                  // Text("Current Date"), //TODO: If it's 'My Day' tab. show this
                ],
              ),
              bottomBar: AddTask(
                // TODO: Add task to database
              ),
              child: Material(
                type: MaterialType.transparency,
                child: ListView.separated(
                  itemCount: 20,
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
                          print(index);
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
          
          RightSidePanel2(database: widget.database, showPanel: showPanel)
        ],
      ),
    );
  }
}

