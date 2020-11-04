import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Error extends StatefulWidget {
  final String message;
  final Widget action;
  final Future<void> Function() refresher;
  Error({
    this.message = "",
    this.action,
    this.refresher,
  });

  @override
  _ErrorState createState() => _ErrorState();
}

class _ErrorState extends State<Error> {
  bool _connected = true;

  @override
  void initState() {
    http.get("https://www.google.com/").then((res) {}).catchError((e) {
      if (e.runtimeType == SocketException) {
        setState(() {
          _connected = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.indigo[50]),
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
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _connected
              ? SizedBox(height: 1)
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Icon(
                    Icons.wifi_off,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          _connected
              ? SizedBox(height: 1)
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Please check your internet connection",
                    style: TextStyle(
                      fontFamily: "Merriweather",
                      color: Colors.indigo[700],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "${widget.message}",
              style: TextStyle(
                fontFamily: "Merriweather",
                color: Colors.indigo[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.action != null) widget.action,
          if (widget.refresher != null)
            RaisedButton(
              onPressed: widget.refresher,
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
