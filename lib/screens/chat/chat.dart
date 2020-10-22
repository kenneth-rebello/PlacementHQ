import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/widgets/chat/message.dart';
import 'package:placementhq/widgets/chat/newmessage.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final driveId = ModalRoute.of(context).settings.arguments;
    final col = "chats/$driveId/messages";
    return Scaffold(
      appBar: AppBar(title: Text("Test")),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection(col)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final docs = snapshot.data.documents;
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                (docs == null || docs.length <= 0)
                    ? Container(
                        height: 150,
                        child: Center(
                          child: Text(
                            "No messages yet",
                            style: Theme.of(context).textTheme.headline3,
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemBuilder: (ctx, idx) => Container(
                            child: Message(
                              message: docs[idx]["text"],
                              sender: docs[idx]["senderName"],
                              senderId: docs[idx]["senderId"],
                              timestamp: docs[idx]["createdAt"],
                            ),
                          ),
                          itemCount: docs.length,
                          reverse: true,
                        ),
                      ),
                NewMessage(col),
              ]);
        },
      ),
    );
  }
}
