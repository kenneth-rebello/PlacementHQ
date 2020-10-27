import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/models/notice.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeItem extends StatelessWidget {
  final Notice notice;
  NoticeItem(this.notice);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Card(
        color: Colors.orange[200],
        child: Container(
          height: 160,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Notice for ${notice.companyName} candidates",
                style: TextStyle(
                  fontFamily: 'Merriweather',
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontSize: 17,
                ),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      barrierColor: Colors.orange[50],
                      builder: (ctx) => SimpleDialog(
                            backgroundColor: Colors.orange[200],
                            contentPadding: EdgeInsets.all(10),
                            title: Text(
                              "Notice for ${notice.companyName} candidates",
                              style: TextStyle(
                                fontFamily: 'Merriweather',
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontSize: 17,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            children: [
                              Text(
                                notice.notice,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Source',
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ));
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Text(
                    notice.notice,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Source',
                      fontSize: 16,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              if (notice.fileUrl != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: "Attachements",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue[900],
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              if (await canLaunch(notice.fileUrl)) {
                                await launch(notice.fileUrl);
                              }
                            })
                    ]),
                  ),
                ),
              Text(
                "Issued by: ${notice.issuedBy}",
                textAlign: TextAlign.right,
              )
            ],
          ),
        ),
      ),
    );
  }
}
