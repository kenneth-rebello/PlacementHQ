import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/providers/officer.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:placementhq/widgets/input/no_button.dart';
import 'package:placementhq/widgets/input/yes_button.dart';
import 'package:provider/provider.dart';

class NewNoticeScreen extends StatelessWidget {
  static const routeName = "/new_notice";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "New Notice",
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      body: NewNotice(),
    );
  }
}

class NewNotice extends StatefulWidget {
  @override
  _NewNoticeState createState() => _NewNoticeState();
}

class _NewNoticeState extends State<NewNotice> {
  bool _loading = false;
  FilePickerResult file;
  TextEditingController cont = new TextEditingController();
  Map<String, dynamic> values = {
    "driveId": "",
    "companyName": "",
    "notice": "",
    "issuedBy": "",
    "issuerId": "",
    "issuedOn": DateTime.now().toIso8601String(),
  };

  @override
  void initState() {
    _loading = true;
    final collegeId = Provider.of<Officer>(context, listen: false).collegeId;
    Provider.of<Drives>(context, listen: false).loadDrives(collegeId).then((_) {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  void _addFile() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'pdf',
        'doc',
        'xlsx',
        'csv',
        'docx',
        'jpeg',
        'png'
      ],
      allowCompression: true,
    );

    if (result != null) {
      print(result.files.single.extension);
      setState(() {
        file = result;
      });
    }
  }

  _publish() {
    if (values["companyName"] == "" || values["notice"] == "") {
      showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            "Please fill all necessary fields!",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SizedBox(
              height: 10,
            )
          ],
        ),
      );
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text("Are you sure?"),
                content: Text(
                  "Publish following notice for ${values["companyName"]}?\n\n${values["notice"]}",
                  textAlign: TextAlign.center,
                ),
                actions: [
                  NoButton(ctx),
                  YesButton(ctx),
                ],
              )).then((res) {
        if (res == true) {
          Provider.of<Officer>(context, listen: false)
              .addNewNotice(values, file)
              .then((_) {
            FilePicker.platform.clearTemporaryFiles();
            setState(() {
              values["notice"] = "";
            });
            cont.clear();
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("Published Notice")));
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final drives = Provider.of<Drives>(context).drives;
    List<String> driveCompanies = [""];
    Map<String, String> mapDriveCompanyToId = {};
    drives.forEach((drive) {
      driveCompanies.add(drive.companyName);
      mapDriveCompanyToId[drive.companyName] = drive.id;
    });

    return _loading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Container(
            margin: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 80,
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Company Name"),
                        DropdownButton(
                          value: values["companyName"],
                          items: driveCompanies
                              .map<DropdownMenuItem>(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              values["companyName"] = val;
                              values["driveId"] = mapDriveCompanyToId[val];
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Input(
                    label: "Notice",
                    controller: cont,
                    onChanged: (val) {
                      setState(() {
                        values["notice"] = val;
                      });
                    },
                    validator: (val) {
                      if (val.length < 10)
                        return "Notice should be at least 10 characters long";
                      return null;
                    },
                    minLines: 5,
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    child: RaisedButton(
                      onPressed: () {
                        _addFile();
                      },
                      child: Text(
                        "Add File",
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    child: RaisedButton(
                      onPressed: () {
                        _publish();
                      },
                      child: Text(
                        "Publish Notice",
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
