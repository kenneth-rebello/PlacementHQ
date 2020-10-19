import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final String value;
  final String label;
  final bool flexibleHeight;
  final double ratio;
  final bool shrink;
  final TextAlign labelAlign;
  final TextAlign valueAlign;

  ListItem({
    @required this.label,
    @required this.value,
    this.flexibleHeight = false,
    this.ratio = 1 / 3,
    this.shrink = false,
    this.labelAlign = TextAlign.left,
    this.valueAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final widthTotal = shrink ? 0.6 : 0.9;
    final labelWidth = ratio * widthTotal;
    final valueWidth = widthTotal - labelWidth;
    return value == null || value == "" || value == "null"
        ? SizedBox(height: 1)
        : Container(
            height: flexibleHeight ? null : 50,
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Column(children: [
              Divider(),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: labelWidth * deviceWidth,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: labelAlign,
                      ),
                    ),
                    Container(
                      width: valueWidth * deviceWidth,
                      child: Text(
                        value,
                        textAlign: valueAlign,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    )
                  ],
                ),
              ),
            ]),
          );
  }
}
