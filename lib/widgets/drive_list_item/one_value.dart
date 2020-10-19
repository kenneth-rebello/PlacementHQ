import 'package:flutter/material.dart';

class OneValue extends StatelessWidget {
  final String label;
  final String value;
  final double padding;

  OneValue({this.label, this.value, this.padding = 8});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: label + ": ",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
