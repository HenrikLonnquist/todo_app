import 'package:flutter/material.dart';
import 'package:todo_app/navigation_panel.dart';


// TODO: need to make it faster when switching between lists/tabs. Probably because of the loading everytime.

void main() async {
  runApp(const MyApp());
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
          primary: Colors.black.withOpacity(0.9),
          surface: Colors.grey.shade600,
        )
      ),
      home: const NavigationPanel(),
    );
  }
}
