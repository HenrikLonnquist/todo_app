// ignore_for_file: avoid_print
import "dart:convert";
import 'dart:io';

const String _dataPath = "assets/data.json";

class DataUtils {

  const DataUtils._();

  // TODO: functions for adding main+subtasks, changing date, renaming

  // NEW MAIN TASK
  static Map dataTemplate( 
  {
    required String name,
    String dueDate = "", 
    List subList = const [], 
    String notes = "", 
  }) {
    return {
      "name": name,
      // "id": int //time?
      "due_date": dueDate,
      "sub_tasks": subList,
      "notes": notes,
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
