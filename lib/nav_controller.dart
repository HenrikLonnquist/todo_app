import 'package:flutter/material.dart';

class NavController extends ChangeNotifier {
  int index = 2;

  bool showRightSidePanel = false;

  bool showLeftSidePanel = true;

  void setindex(int i) {
    index = i;
    notifyListeners();
  }

  void setRightPanel(bool state, String whichPanel) {

    // Could've done a bool instead of a string to discern which panel to show/hide
    if (whichPanel == "left") 

    // if (right == true) 

    notifyListeners();
    
  }


}

