import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  final bool showRightPanel = false;
  final bool showLeftPanel = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.black,
          surface: Colors.black,
        ),
        listTileTheme: ListTileThemeData(
          selectedTileColor: Colors.grey.shade700.withValues(alpha: 0.5),
          selectedColor: Colors.white,
          textColor: Colors.white,
        )
      ),
      // home: NavigationPanel(database: database),
      // home: NavigationPanel2(database: database),
      home: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavigationPanel2(database: database),
            MainPage(database: database),
            RightSidePanel(
              database: database,
              show: true,
              sidePanelWidth: 340,
              bottomBar: PanelBottomBar(
                hidePanel: () {
                  // TODO: need to make this an stateful but to use setstate.
                },
                deleteTask: () {

                }
              ),
              child: TaskInfo(
              ),
            ),

          ]
        )
      ),
    );
  }
}


class NavigationPanel2 extends StatefulWidget {
  const NavigationPanel2({
    super.key,
    required this.database,
  });

  final AppDB database;

  @override
  State<NavigationPanel2> createState() => _NavigationPanel2State();
}

class _NavigationPanel2State extends State<NavigationPanel2> {

  int _selectedIndex = 0;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RightSidePanel(
      database: widget.database,
      show: true,
      sidePanelWidth: 220,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Material(
              type: MaterialType.transparency,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    // selected: ,  // show the correct page corresponding to the id/index in the database
                    selected: index == _selectedIndex,
                    splashColor: Colors.transparent,
                    title: Text(
                      "test$index",
                    ),
                    onTap: (){
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
            Divider(),
            //MARK: User Lists
            Material(
              type: MaterialType.transparency,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3 + 3,
                itemBuilder: (context, index) {
                  final userIndex = 3 + index;

                  return ListTile(
                    // selected: ,  // show the correct page corresponding to the id/index in the database
                    selected: userIndex == _selectedIndex,
                    splashColor: Colors.transparent,
                    title: Text(
                      "test$userIndex",
                    ),
                    onTap: (){
                      setState(() {
                        _selectedIndex = userIndex;
                      });
                    },
                  ); 
                },
              ),
            )
          ]
        ),
      ),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
    required this.database,
  });

  final AppDB database;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: const Text("hello"),
        ),
      ],
    );
  }
}

