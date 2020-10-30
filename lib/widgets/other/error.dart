import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  final String message;
  final Widget action;
  final Future<void> Function() refresher;
  Error({
    this.message = "",
    this.action,
    this.refresher,
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
            child: Image.asset(
              'assets/images/repair.png',
              color: Theme.of(context).accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Oops! The page did not load properly.",
              style: TextStyle(
                fontFamily: "Merriweather",
                color: Colors.red,
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
          if (refresher != null)
            RaisedButton(
              onPressed: refresher,
              child: Text(
                "Retry",
                style: Theme.of(context).textTheme.button,
              ),
            )
        ],
      ),
    );
  }
}
