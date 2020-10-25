import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final fillColor = Color.fromRGBO(196, 196, 255, 0.5);
  final textColor = Color.fromRGBO(0, 0, 94, 0.8);
  final double fixedWidth;
  final String initialValue;
  final bool enabled;
  final String label;
  final String helper;
  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final void Function(String) onFieldSubmitted;
  final String Function(String) validator;
  final TextEditingController controller;
  final TextInputType type;
  final TextInputAction action;
  final FocusNode node;
  final int minLines;
  final int maxLines;
  final int helperLines;
  final bool requiredField;
  final bool disabled;

  Input({
    this.initialValue,
    this.helper,
    this.label,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.validator,
    this.fixedWidth,
    this.controller,
    this.enabled,
    this.maxLines,
    this.minLines,
    this.helperLines,
    this.type,
    this.action,
    this.node,
    this.requiredField = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: fixedWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          controller: controller,
          keyboardType: type,
          textInputAction: action,
          focusNode: node,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            labelText: label,
            labelStyle: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
            helperText: helper,
            helperMaxLines: helperLines,
            filled: true,
            fillColor: fillColor,
            focusColor: Colors.orange[900],
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 16),
          onChanged: onChanged,
          onSaved: onSaved,
          onFieldSubmitted: onFieldSubmitted,
          validator: (val) {
            if (requiredField) {
              if (val.length < 2) {
                return "Required";
              }
            }
            if (validator != null) {
              return validator(val);
            }
            return null;
          },
          maxLines: maxLines,
          minLines: minLines,
          readOnly: disabled,
        ),
      ),
    );
  }
}
