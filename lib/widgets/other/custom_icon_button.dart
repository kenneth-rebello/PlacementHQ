import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  VoidCallback onPressed;
  double height;
  Icon icon;
  String label;
  TextStyle labelStyle = TextStyle(color: Colors.indigo[900]);

  CustomIconButton({
    @required this.onPressed,
    @required this.icon,
    @required this.label,
    this.labelStyle,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: FittedBox(child: Text(label, style: labelStyle)),
            ),
          ],
        ),
      ),
    );
  }
}
