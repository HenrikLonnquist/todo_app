import 'package:flutter/material.dart';
import 'package:path/path.dart';

class NavController extends ChangeNotifier {

  int index = 2;

  bool showTaskInfoPanel = false;

  int currentTaskID = 1;

  bool showNavPanel = true;

  void setindex(int i) {
    index = i;
    notifyListeners();
  }


  void togglePanel(
    {
      bool state = false,
      String? whichPanel, 
      int taskID = 0
    }) {

      // print("$currentTaskID $taskID $showTaskInfoPanel $state");

      // Avoid unnecessary rebuilds if state hasn't changed
      if (showTaskInfoPanel == state) {
        if (taskID != currentTaskID) {
          currentTaskID = taskID;
          notifyListeners();
        } 
        return; 
      }

      //TODO: need to pre-fetch currenttaskid. Look for answer in claude chat.

      // Could've done a bool instead of a string to discern which panel to show/hide
      // in case of adding more. I think this setup is better.
      if (whichPanel == "left") {
        showNavPanel = state;
      }
      else {
        currentTaskID = taskID;
        showTaskInfoPanel = state;
      }

      notifyListeners();
    
  }


}

