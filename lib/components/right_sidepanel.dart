// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({
    super.key,
    this.mainTaskSubList, 
    this.onChanged, 
    this.child,
  });

  final List? mainTaskSubList;
  final Widget? child;
  final ValueChanged? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      color: Colors.blueAccent,
      padding: const EdgeInsets.all(10),
      child: child,
    );
  }
}


