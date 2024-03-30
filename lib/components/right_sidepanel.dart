// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({
    super.key,
    this.child, 
    required this.show,
  });

  final bool show;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return show 
    ? Expanded(
      child: Container(
        color: Colors.blueAccent,
        padding: const EdgeInsets.all(10),
        child: child,
      ),
    )
    : const SizedBox(height: 0);
  }
}


