// ignore_for_file: avoid_print
import "dart:convert";
import 'dart:io';


class DataUtils {

  final String _dataPath = "assets/data.json";

  // open Json file
  Map readJsonFile() {
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
  void writeJsonFile(Map dataList) {
    
    var spaces = " " * 4;
    var jsonString = JsonEncoder.withIndent(spaces).convert(dataList);
    
    File(_dataPath).writeAsStringSync(jsonString);
  }

  
}
