// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class CardField extends StatefulWidget {
  const CardField({
    super.key,
    this.onSubmitted,
  });

  final Function(String)? onSubmitted;

  @override
  State<CardField> createState() => _CardFieldState();
}

class _CardFieldState extends State<CardField> {
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
          onSubmitted: widget.onSubmitted,
        )
      )
    );
  }
}
