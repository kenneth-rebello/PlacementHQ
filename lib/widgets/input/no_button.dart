import 'package:flutter/material.dart';

class NoButton extends StatelessWidget {
  final BuildContext dialogContext;
  NoButton(this.dialogContext);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(dialogContext).pop(false);
      },
      child: Text(
        "No",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}
