import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/providers/auth.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/providers/user.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:provider/provider.dart';

class NewMessage extends StatefulWidget {
  final String collectionPath;
  NewMessage(this.collectionPath);
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  TextEditingController msgCont = new TextEditingController();
  String message = "";
  String senderId = "";
  String senderName = "";

  @override
  void initState() {
    senderId = Provider.of<User>(context, listen: false).userId;
    final isOfficer = Provider.of<Auth>(context, listen: false).isOfficer;
    if (isOfficer) {
      senderName =
          Provider.of<Officer>(context, listen: false).profile.fullName;
    } else
      senderName = Provider.of<User>(context, listen: false).profile.fullName;
    super.initState();
  }

  void _sendMessage() async {
    if (message.trim().isEmpty) return;
    await Firestore.instance.collection(widget.collectionPath).add({
      "text": message,
      "createdAt": Timestamp.now(),
      "senderId": senderId,
      "senderName": senderName,
    });
    msgCont.clear();
    setState(() {
      message = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Input(
            controller: msgCont,
            onChanged: (val) {
              setState(() {
                message = val;
              });
            },
            action: TextInputAction.newline,
          ),
        ),
        IconButton(
          color: Colors.indigo[900],
          disabledColor: Colors.indigo[50],
          icon: Icon(Icons.send),
          onPressed: message.trim().isEmpty ? null : _sendMessage,
        )
      ],
    );
  }
}
