import 'package:flutter/material.dart';

class SelectStateTextWidget extends StatelessWidget {
  final String? title;
  const SelectStateTextWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? "Select your state",
      style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: Color(0xff0D9D7C),
          fontFamily: "RiformaLL"),
    );
  }
}
