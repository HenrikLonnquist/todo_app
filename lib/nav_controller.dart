import 'package:flutter/material.dart';

class NavController extends ChangeNotifier {
  int index = 2;

  void setindex(int i) {
    index = i;
    notifyListeners();
  }  
}