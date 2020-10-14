import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  final fillColor = Color.fromRGBO(196, 196, 255, 0.5);
  final textColor = Color.fromRGBO(0, 0, 94, 0.8);
  final String initialValue;
  final bool enabled;
  final String label;
  final String helper;
  final void Function(String) onSaved;
  final void Function(String) onChanged;
  final String Function(String) validator;
  final TextEditingController controller;
  final TextInputType type;
  final int minLines;
  final int maxLines;
  bool requiredField;

  Input({
    this.initialValue,
    this.helper,
    this.label,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.controller,
    this.enabled,
    this.maxLines,
    this.minLines,
    this.type,
    this.requiredField,
  });

  @override
  Widget build(BuildContext context) {
    if (requiredField == null) requiredField = false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            labelText: label,
            labelStyle: TextStyle(
              color: textColor,
              fontSize: 15,
            ),
            helperText: helper,
            filled: true,
            fillColor: fillColor,
            border: InputBorder.none,
          ),
          style: TextStyle(fontSize: 16),
          onChanged: onChanged,
          onSaved: onSaved,
          validator: (val) {
            if (requiredField) {
              if (val.length < 2) {
                return "Required";
              }
            }
            if (validator != null) {
              return validator(val);
            }
          },
          maxLines: maxLines,
          minLines: minLines,
        ),
      ),
    );
  }
}
