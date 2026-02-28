// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

//TODO: probably make this into a stateless one
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
    this.onTapOutside,
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
  final Function(PointerEvent)? onTapOutside;

  @override
  State<TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends State<TitleField> {
  
  final TextEditingController _titleController = TextEditingController();
  
  late FocusNode focusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    focusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    _titleController.text = widget.inputValue;

    // adds focus to textfield after first frame build/call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
      

    });


    return IntrinsicWidth(
      child: TextField(
        onTapOutside: (event) {
          
          focusNode.unfocus();
          widget.onTapOutside!.call(event);
          
        },
        focusNode: focusNode,
        mouseCursor: widget.mouseCursor,
        enabled: widget.enabled,
        controller: _titleController,
        onSubmitted: (value) {
          _titleController.text = value;
          //Todo: need to remove empty space after the text if there is any.
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
