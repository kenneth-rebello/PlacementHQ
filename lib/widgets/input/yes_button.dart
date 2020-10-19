import 'package:flutter/material.dart';

class YesButton extends StatelessWidget {
  final BuildContext dialogContext;
  YesButton(this.dialogContext);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        Navigator.of(dialogContext).pop(true);
      },
      child: Text(
        "Yes",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
