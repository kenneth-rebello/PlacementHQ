import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message extends StatelessWidget {
  final String message;
  final String sender;
  final String senderId;
  final Timestamp timestamp;
  final DateFormat formatter = new DateFormat("dd-MMM hh:mm");
  Message({
    @required this.message,
    @required this.sender,
    @required this.senderId,
    this.timestamp,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.indigo[600],
      ),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ListTile(
        title: Container(
          margin: EdgeInsets.all(5),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        subtitle:
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Text(
            formatter.format(timestamp.toDate()),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Ubuntu',
              fontSize: 11,
              fontWeight: FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
          Text(
            sender,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.right,
          ),
        ]),
      ),
    );
  }
}
