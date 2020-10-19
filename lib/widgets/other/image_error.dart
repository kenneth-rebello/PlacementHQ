import 'package:flutter/material.dart';

class ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
        color: Colors.grey[200],
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          Text(
            "No Image",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w100,
            ),
          ),
        ],
      ),
    );
  }
}
