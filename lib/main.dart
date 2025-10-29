import 'package:flutter/material.dart';
import 'package:todo_app/database.dart';
import 'package:todo_app/navigation_panel.dart';


// TODO: need to make it faster when switching between lists/tabs. Probably because of the loading everytime.
//TODO: why does the tasks in the database need to have a list id?

void main() async {
  final db = AppDb();
  runApp(MyApp(db: db));
  
}

class MyApp extends StatelessWidget {
  final AppDb db;

  const MyApp({super.key, required this.db});

  

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
      home: const NavigationPanel(),
    );
  }
}
