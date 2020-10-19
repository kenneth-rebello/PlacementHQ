import 'package:flutter/material.dart';

class CheckListItem extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;

  CheckListItem({this.label, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }
}
