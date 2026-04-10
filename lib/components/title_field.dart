// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

//TODO: probably make this into a stateless one
class TitleField extends StatefulWidget {
  const TitleField({
    super.key,
    this.onChange,
    this.requestFocus,
    this.inputValue = "",
    this.completed = false,
    this.textSize = 26,
    this.fontWeight,
    this.labelText,
    this.labelStyle,
    this.mouseCursor,
    this.onTapOutside,
    this.disableTextEditing = false,
    this.selectAllOnFocus = true,
    this.onTap,
  });

  final bool? requestFocus;
  final bool disableTextEditing;
  final MouseCursor? mouseCursor;
  final Function(String)? onChange; //TODO: rename to something more fitting
  final String inputValue;
  final bool completed;
  final double textSize;
  final String? labelText;
  final TextStyle? labelStyle;
  final FontWeight? fontWeight;
  final void Function(PointerEvent)? onTapOutside;
  final bool selectAllOnFocus;
  final void Function()? onTap;

  @override
  State<TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends State<TitleField> {
  
  final TextEditingController _titleController = TextEditingController();
  
  late FocusNode focusNode;

  bool _wasFocused = false;


  @override
  void initState() {
    super.initState();

    focusNode = FocusNode();

    // Properly applies selectAllOnFocus with this, without it causes a small delay
    focusNode.addListener(() {

      if (focusNode.hasFocus && widget.selectAllOnFocus) {
        _titleController.selection = TextSelection(baseOffset: 0, extentOffset: _titleController.text.length);
        _wasFocused = true;
      }
      else {
        _wasFocused = false;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    _titleController.text = widget.inputValue;

    if (widget.requestFocus ?? false) {
      
      // adds focus to textfield after first frame build/call
      WidgetsBinding.instance.addPostFrameCallback((_) {

        focusNode.requestFocus();

      });

    }


    return IntrinsicWidth(
      child: widget.disableTextEditing ?
      Text(
        widget.inputValue,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.textSize,
          overflow: TextOverflow.ellipsis,
        )
      )
      : TextField(
        onTap: () {

          // Adds focus and selects all
          if (!_wasFocused && widget.selectAllOnFocus) {
            setState(() {
              focusNode.requestFocus();
            });
          }
          widget.onTap?.call();
          
        },
        onTapOutside: (event) {
          focusNode.unfocus();
          _wasFocused = false;
          widget.onTapOutside?.call(event);
        },
        focusNode: focusNode,
        // readOnly: widget.disableTextEditing, 
        selectAllOnFocus: widget.selectAllOnFocus,
        mouseCursor: widget.mouseCursor,
        enabled: widget.requestFocus,
        controller: _titleController,
        onSubmitted: (value) {
          _titleController.text = value;
          
          //Todo: need to remove empty space after the text if there is any.
          //! might be to do the trimming right before updating db or notifying the provider.
          
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
      )
    );
  }
}
