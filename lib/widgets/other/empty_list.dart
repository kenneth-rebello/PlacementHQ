import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  final String message;
  final Widget action;
  EmptyList({
    this.message = "",
    this.action,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.indigo[100]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150,
            width: 150,
            margin: const EdgeInsets.all(8),
            child: Image.asset('assets/images/logo.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "There's nothing here, yet.",
              style: TextStyle(
                fontFamily: "Merriweather",
                color: Colors.indigo[900],
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "$message",
              style: TextStyle(
                fontFamily: "Merriweather",
                color: Colors.indigo[700],
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }
}
