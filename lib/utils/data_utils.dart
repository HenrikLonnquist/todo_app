// ignore_for_file: avoid_print
import "dart:convert";
import 'dart:io';
import 'package:flutter/material.dart';


const String _dataPath = "assets/data.json";

class DataUtils {

  const DataUtils._();

  // TODO: functions for adding main+subtasks, changing date, renaming


  // New sub task
  static Map subTaskTemplate({required String name}) {
    return {
      "name": name,
      "checked": false
    };
  }

  // New main task
  static Map newTaskTemplate( 
  {
    required String name,
    required int listID,
    required int taskID,
    String reminder = "",
    String dueDate = "", 
    String repeat = "", 
    List subList = const [], 
    String notes = "", 
  }) {
    return {
      "name": name,
      "list_id": listID,
      "task_id": taskID,
      "reminder": reminder,
      "due_date": dueDate,
      "repeat": repeat,
      "sub_tasks": subList,
      "notes": notes,
      "checked": false,
      "created": DateTime.now().toString(),
    };
  }

  // open Json file
  static Map readJsonFile() {
    try {
      final fileContent = File(_dataPath).readAsStringSync();
      final jsonData = json.decode(fileContent);
      return jsonData;
    } catch (e) {
          print('Error reading JSON file: $e');
      return {};
    }
  }

  // save to Json file
  static void writeJsonFile(Map dataList) {
    
    var spaces = " " * 4;
    var jsonString = JsonEncoder.withIndent(spaces).convert(dataList);
    
    File(_dataPath).writeAsStringSync(jsonString);
  }

  
}
