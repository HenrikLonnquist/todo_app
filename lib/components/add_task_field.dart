// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class AddTask extends StatefulWidget {
  const AddTask({
    super.key,
    this.onSubmitted,
  });

  final Function? onSubmitted;

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  
  final TextEditingController _newTaskController = TextEditingController();

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          decoration: const InputDecoration(
            hintText: "Add new task",
            border: InputBorder.none,
          ),
          controller: _newTaskController,
          onSubmitted: (value) {
            widget.onSubmitted?.call(value);
            _newTaskController.text = "";
          },
        )
      )
    );
  }
}
