import 'package:flutter/material.dart';

//Use together with a stack

class Modal extends StatelessWidget {
  final bool controller;
  final Widget child;
  final void Function() close;
  Modal({this.child, this.controller, this.close});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        close();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black45,
        child: GestureDetector(
          onTap: () {},
          child: child,
        ),
      ),
    );
  }
}
