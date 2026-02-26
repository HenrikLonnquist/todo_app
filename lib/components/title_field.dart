// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class TitleField extends StatefulWidget {
  const TitleField({
    super.key,
    this.onChange,
    this.enabled = true,
    this.inputValue = "",
    this.completed = false,
    this.textSize = 26,
    this.fontWeight,
    this.labelText,
    this.labelStyle,
    this.mouseCursor,
  });

  final bool enabled;
  final MouseCursor? mouseCursor;
  final Function(String)? onChange; //TODO: rename to something more fitting
  final String inputValue;
  final bool completed;
  final double textSize;
  final String? labelText;
  final TextStyle? labelStyle;
  final FontWeight? fontWeight;

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
        autofocus: true,
        mouseCursor: widget.mouseCursor,
        enabled: widget.enabled,
        controller: _titleController,
        onSubmitted: (value) {
          _titleController.text = value;
          widget.onChange!.call(value);
        },
        style: TextStyle(
          fontSize: widget.textSize,
          fontWeight: widget.fontWeight,
          color: Colors.white,
          decoration: widget.completed ? TextDecoration.lineThrough : null,
          // fontFamily: ,                    
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true, //This fixed the gap above input line from labeltext
          labelText: widget.inputValue == "" ? widget.labelText : null,
          labelStyle: widget.labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
