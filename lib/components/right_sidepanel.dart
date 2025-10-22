// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class RightSidePanel extends StatelessWidget {
  const RightSidePanel({
    super.key,
    this.bottomChild,
    this.child, 
    required this.show,
  });

  final bool show;
  final Widget? child;
  final Widget? bottomChild;

  @override
  Widget build(BuildContext context) {
    return show 
    ? Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.95,
          width: 380,
          // width: MediaQuery.of(context).size.width * 0.3,
          color: Colors.grey,
          padding: const EdgeInsets.all(10),
          child: child,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.05,
          width: 380,
          color: Colors.grey.shade800,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: bottomChild,

        )
      ],
    )
    : const SizedBox(height: 0);
  }
}


