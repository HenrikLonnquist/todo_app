import 'package:flutter/material.dart';
// import 'package:path/path.dart';

class NavController extends ChangeNotifier {

  //! Should probably make them not hard-coded. Then what?
  int navIndex = 3; // start index - corresponds to todo_lists id in DB.
  String navListName = "Tasks"; // Needs to match navIndex title/name in DB.

  bool showTaskPanel = false;

  int currentTaskID = 1; 

  // bool showNavPanel = true; // feature for later

  
  void setListName(String name, {
    // In-case we want to let the current state be, 
    // like when we're changing the navlist name we can set the.
    bool showPanel = false, 
    }) {

    if (navListName == name) return;

    navListName = name;
    
    showTaskPanel = showPanel; 
    

    notifyListeners();
  }

  void setNavIndex(int i) {

    if (navIndex == i) return;
    
    navIndex = i;
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

