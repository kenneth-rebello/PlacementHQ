import 'package:flutter/material.dart';
import 'package:placementhq/models/offer.dart';
import 'package:placementhq/providers/drives.dart';
import 'package:placementhq/res/constants.dart';
import 'package:placementhq/widgets/input/input.dart';
import 'package:provider/provider.dart';

class OfferEditor extends StatefulWidget {
  final Offer offer;
  final void Function() close;
  final String batch;
  OfferEditor(
    this.offer,
    this.close,
    this.batch,
  );
  @override
  _OfferEditorState createState() => _OfferEditorState();
}

class _OfferEditorState extends State<OfferEditor> {
  final _form = GlobalKey<FormState>();
  bool _loading = false;
  Map<String, dynamic> values = {
    "ctc": 0.0,
    "category": "",
  };

  @override
  void initState() {
    values = {
      "category": widget.offer.category,
      "ctc": widget.offer.ctc,
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SimpleDialog(
              title: Text(
                "Edit Offer",
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.left,
              ),
              contentPadding: EdgeInsets.all(15),
              children: [
                Input(
                  initialValue: values["ctc"].toString(),
                  label: "CTC",
                  type: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      values["ctc"] = double.parse(val);
                    });
                  },
                  requiredField: true,
                ),
                DropdownButton(
                  value: values["category"],
                  items: Constants.driveCategories
                      .map<DropdownMenuItem>(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      values["category"] = val;
                    });
                  },
                ),
                RaisedButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                    });
                    Provider.of<Drives>(context, listen: false)
                        .editOffer(values, widget.offer.id, widget.batch)
                        .then((value) {
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("Edited Successfully!")));
                      widget.close();
                    }).catchError((e) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Operation Failed"),
                        ),
                      );
                    });
                  },
                  child: Text(
                    "OK",
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                RaisedButton(
                  onPressed: widget.close,
                  color: Colors.red,
                  child: Text(
                    "Cancel",
                    style: Theme.of(context).textTheme.button,
                  ),
                )
              ],
            ),
    );
  }
}
