import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutText extends StatelessWidget {
  final String text;
  AboutText(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.orange[300],
          fontFamily: "Ubuntu",
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
