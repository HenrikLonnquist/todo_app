// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class TitleField extends StatefulWidget {
  const TitleField({
    super.key,
    this.onChange,
    this.enabled = true,
    this.inputValue = "",
  });

  final bool enabled;
  final Function(String)? onChange;
  final String inputValue;

  @override
  State<TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends State<TitleField> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.inputValue;
    return IntrinsicWidth(
      child: TextField(
        enabled: widget.enabled,
        controller: _titleController,
        onSubmitted: (value) {
          _titleController.text = value;
          widget.onChange!.call(value);
        },
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          // fontFamily: ,                    
        ),
        cursorColor: Colors.black,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
