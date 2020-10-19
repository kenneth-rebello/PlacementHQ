import 'package:flutter/material.dart';

class TwoValues extends StatelessWidget {
  final String label1;
  final String label2;
  final String value1;
  final String value2;

  TwoValues({this.label1, this.label2, this.value1, this.value2});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: label1 + ": ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value1),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black),
              children: <TextSpan>[
                TextSpan(
                  text: label2 + ": ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: value2,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}