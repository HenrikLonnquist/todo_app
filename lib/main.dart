import 'package:flutter/material.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/navigation_panel.dart';


// TODO: need to make it faster when switching between lists/tabs. Probably because of the loading everytime.
// TODO: why does the tasks in the database need to have a list id?
// TODO: switch to riverpod later - manually passing to everywidget > riverpod

void main() async {
  final db = AppDb();
  runApp(MyApp(database: db));
  
}

class MyApp extends StatelessWidget {
  final AppDb database;

  const MyApp({super.key, required this.database});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.black.withValues(alpha: 0.9),
          surface: Colors.grey.shade600,
        )
      ),
      home: NavigationPanel(database: database),
    );
  }
}
