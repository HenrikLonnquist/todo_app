import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NavController extends ChangeNotifier {

  int index = 2;

  bool showTaskPanel = false;

  int currentTaskID = 1;

  bool showNavPanel = true;

  void setindex(int i) {
    
    index = i;
    showTaskPanel = false; // in case right side panel is open

    notifyListeners();
  }


  void toggleRightPanel(
    {
      bool state = false,
      int taskID = 0
    }) {

      // print("panel: $showTaskPanel $state | task: $currentTaskID $taskID");

      // Open panel
      if (showTaskPanel == false) {

        if (currentTaskID != taskID) {
          currentTaskID = taskID;

        }
        showTaskPanel = state;  
        

      }
      // Close panel/Change task info
      else if (showTaskPanel == true) {

        if (currentTaskID == taskID) {
          showTaskPanel = state;
        }
        else {
          currentTaskID = taskID;
        }

      }
      
      notifyListeners();
    
  }


}

